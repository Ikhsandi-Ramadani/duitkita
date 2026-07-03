import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/format.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../ui/widgets/app_sheet.dart';
import '../../ui/widgets/app_toast.dart';
import '../../ui/widgets/cat_icon.dart';
import '../../ui/widgets/member_avatar.dart';
import '../../ui/widgets/segmented_control.dart';
import '../../ui/widgets/tx_type_meta.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  // Form state
  String _type = 'expense';
  int _amount = 0; // raw digits entered (for adjustment: target balance)
  Wallet? _wallet;
  Wallet? _targetWallet;
  Category? _category;
  List<Member> _spentBy = [];
  String _note = '';
  bool _loading = false;
  bool _initialized = false;

  // Edit mode: original transaction
  Transaction? _editingTx;

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final wallets = ref.read(walletsProvider).value ?? [];
    final userId = ref.read(currentUserIdProvider).value;

    // Read query params from router
    final routerState = GoRouterState.of(context);
    final editClientId = routerState.uri.queryParameters['edit'];
    final preset = routerState.uri.queryParameters['preset'];
    final scanAmount = routerState.uri.queryParameters['amount'];
    final scanNote = routerState.uri.queryParameters['note'];

    if (editClientId != null && editClientId.isNotEmpty) {
      final db = ref.read(dbProvider);
      final tx = await (db.select(db.transactions)
            ..where((t) => t.clientId.equals(editClientId)))
          .getSingleOrNull();
      if (tx != null && mounted) {
        final cats = ref.read(categoriesProvider).value ?? [];
        setState(() {
          _editingTx = tx;
          _type = tx.type;
          _amount = tx.amount.abs();
          _wallet = wallets.firstWhereOrNull((w) => w.id == tx.walletId);
          _targetWallet = tx.targetWalletId != null
              ? wallets.firstWhereOrNull((w) => w.id == tx.targetWalletId)
              : null;
          _category = tx.categoryId != null
              ? cats.firstWhereOrNull((c) => c.id == tx.categoryId)
              : null;
          _note = tx.note ?? '';
          _initialized = true;
        });
        return;
      }
    }

    // Presets
    String type = 'expense';
    Wallet? wallet;
    Wallet? targetWallet;

    if (preset == 'topup-shared') {
      type = 'transfer';
      // source = current user's first personal wallet
      if (userId != null) {
        wallet = wallets.firstWhereOrNull(
            (w) => w.scope == 'personal' && w.ownerUserId == userId);
      }
      // target = Kas Belanja (first shared cash wallet)
      targetWallet = wallets.firstWhereOrNull(
          (w) => w.scope == 'shared' && w.type == 'cash');
    } else if (preset == 'transfer') {
      type = 'transfer';
      if (userId != null) {
        wallet = wallets.firstWhereOrNull(
            (w) => w.scope == 'personal' && w.ownerUserId == userId);
      }
    } else if (preset == 'income') {
      type = 'income';
      if (userId != null) {
        wallet = wallets.firstWhereOrNull(
            (w) => w.scope == 'personal' && w.ownerUserId == userId);
      }
    } else {
      // default expense: pick first own personal wallet
      if (userId != null) {
        wallet = wallets.firstWhereOrNull(
            (w) => w.scope == 'personal' && w.ownerUserId == userId);
      }
    }

    if (mounted) {
      setState(() {
        _type = type;
        _wallet = wallet;
        _targetWallet = targetWallet;
        // Pre-fill from Scan Struk if provided
        if (scanAmount != null) {
          final parsed = int.tryParse(scanAmount);
          if (parsed != null && parsed > 0) _amount = parsed;
        }
        if (scanNote != null && scanNote.isNotEmpty) _note = scanNote;
        _initialized = true;
      });
    }
  }

  // -------------------------------------------------------------------------
  // Validation
  // -------------------------------------------------------------------------

  bool get _isValid {
    if (_type == 'adjustment') {
      final selisih = _selisih;
      return selisih != 0;
    }
    if (_amount <= 0) return false;
    if (_wallet == null) return false;
    if (_type == 'transfer') {
      return _targetWallet != null && _targetWallet!.id != _wallet!.id;
    }
    // income / expense need category
    return _category != null;
  }

  int get _selisih {
    // For adjustment: target − current wallet balance
    if (_wallet == null) return 0;
    return _amount - _wallet!.currentBalance;
  }

  // -------------------------------------------------------------------------
  // Save
  // -------------------------------------------------------------------------

  Future<void> _save() async {
    if (!_isValid || _loading) return;
    setState(() => _loading = true);

    try {
      final repo = ref.read(transactionRepoProvider);
      final userId = ref.read(currentUserIdProvider).value;
      if (userId == null) throw Exception('Sesi tidak valid, silakan login ulang');
      final now = DateTime.now();

      final int saveAmount;
      if (_type == 'adjustment') {
        saveAmount = _selisih;
      } else if (_type == 'expense' || _type == 'transfer') {
        saveAmount = -_amount.abs();
      } else {
        saveAmount = _amount.abs();
      }

      final spentById =
          _spentBy.isNotEmpty ? _spentBy.first.id : null;

      if (_editingTx != null) {
        await repo.updateTransaction(
          clientId: _editingTx!.clientId,
          type: _type,
          walletId: _wallet!.id,
          targetWalletId: _targetWallet?.id,
          categoryId: _category?.id,
          amount: saveAmount,
          date: _editingTx!.date,
          note: _note.isNotEmpty ? _note : null,
          spentBy: spentById,
        );
      } else {
        await repo.addTransaction(
          type: _type,
          walletId: _wallet!.id,
          targetWalletId: _targetWallet?.id,
          categoryId: _category?.id,
          amount: saveAmount,
          date: now,
          note: _note.isNotEmpty ? _note : null,
          recordedBy: userId,
          spentBy: spentById,
        );
      }

      if (mounted) {
        ref.invalidate(backgroundSyncProvider);
        AppToast.show(context, 'Transaksi tersimpan ✓');
        context.pop();
      }
    } catch (e) {
      if (kDebugMode) print('[AddTransaction] save error: $e');
      if (mounted) {
        AppToast.show(context, 'Gagal menyimpan transaksi', success: false);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // -------------------------------------------------------------------------
  // Keypad
  // -------------------------------------------------------------------------

  void _onKey(String key) {
    HapticFeedback.selectionClick();
    setState(() {
      if (key == 'backspace') {
        final s = _amount.toString();
        if (s.length <= 1) {
          _amount = 0;
        } else {
          _amount = int.parse(s.substring(0, s.length - 1));
        }
      } else if (key == '000') {
        if (_amount > 0) {
          final next = _amount * 1000;
          if (next <= 999999999) _amount = next;
        }
      } else {
        final digit = int.parse(key);
        final next = _amount * 10 + digit;
        if (next <= 999999999) _amount = next;
      }
    });
  }

  // -------------------------------------------------------------------------
  // Sheets
  // -------------------------------------------------------------------------

  Future<void> _pickCategory() async {
    final cats = ref.read(categoriesProvider).value ?? [];
    final filtered = cats
        .where((c) =>
            c.type == (_type == 'income' ? 'income' : 'expense'))
        .toList();

    final picked = await AppSheet.show<Category>(
      context: context,
      child: _CategorySheet(categories: filtered),
    );
    if (picked != null && mounted) {
      setState(() => _category = picked);
    }
  }

  Future<void> _pickWallet({bool isTarget = false}) async {
    final wallets = ref.read(walletsProvider).value ?? [];
    final userId = ref.read(currentUserIdProvider).value;
    final members = ref.read(membersProvider).value ?? [];

    final picked = await AppSheet.show<Wallet>(
      context: context,
      child: _WalletSheet(
        wallets: wallets,
        currentUserId: userId,
        members: members,
        isTarget: isTarget,
        sourceWalletId: isTarget ? _wallet?.id : null,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isTarget) {
          _targetWallet = picked;
        } else {
          _wallet = picked;
          // If target same as new source, clear target
          if (_targetWallet?.id == picked.id) {
            _targetWallet = null;
          }
        }
      });
    }
  }

  Future<void> _pickNote() async {
    final picked = await AppSheet.show<String>(
      context: context,
      child: _NoteSheet(initial: _note),
    );
    if (picked != null && mounted) {
      setState(() => _note = picked);
    }
  }

  Future<void> _pickMembers() async {
    final members = ref.read(membersProvider).value ?? [];
    final picked = await AppSheet.show<List<Member>>(
      context: context,
      child: _MemberPickerSheet(members: members, selected: _spentBy),
    );
    if (picked != null && mounted) {
      setState(() => _spentBy = picked);
    }
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final meta = TxTypeMeta.of(_type, colors);
    final isEdit = _editingTx != null;

    return Scaffold(
      backgroundColor: colors.appBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(colors, meta, isEdit),
            Expanded(
              child: !_initialized
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          _buildTypeSelector(colors, meta),
                          const SizedBox(height: 20),
                          _buildAmountHero(colors, meta),
                          const SizedBox(height: 16),
                          _buildDetailCard(colors),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
            ),
            _buildKeypad(colors, meta),
            _buildSaveButton(colors, meta),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppColors colors, TxTypeMeta meta, bool isEdit) {
    return Container(
      color: colors.appBg,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 56,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close_rounded, color: colors.text),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Text(
              isEdit ? 'Edit Transaksi' : 'Catat Transaksi',
              style: AppText.cardTitle(color: colors.text),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(AppColors colors, TxTypeMeta meta) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SegmentedControl<String>(
        activeColor: meta.color,
        selected: _type,
        onChanged: (v) => setState(() {
          _type = v;
          _category = null;
          // clear target for non-transfer
          if (v != 'transfer') _targetWallet = null;
        }),
        items: const [
          SegmentItem(value: 'expense', label: 'Keluar'),
          SegmentItem(value: 'income', label: 'Masuk'),
          SegmentItem(value: 'transfer', label: 'Transfer'),
          SegmentItem(value: 'adjustment', label: 'Sesuaikan'),
        ],
      ),
    );
  }

  Widget _buildAmountHero(AppColors colors, TxTypeMeta meta) {
    final amountColor = meta.color;
    final label = _type == 'adjustment' ? 'Saldo sebenarnya' : 'Nominal';

    return Column(
      children: [
        Text(
          label,
          style: AppText.label(color: colors.text3),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'Rp',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: amountColor.withValues(alpha: 0.7),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 2),
            Text(
              _formatAmount(_amount),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 46,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.02 * 46,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: amountColor,
              ),
            ),
          ],
        ),
        if (_type == 'adjustment' && _wallet != null) ...[
          const SizedBox(height: 4),
          _buildSelisihBadge(colors),
        ],
      ],
    );
  }

  Widget _buildSelisihBadge(AppColors colors) {
    final diff = _selisih;
    final isPositive = diff >= 0;
    final color = isPositive ? colors.income : colors.expense;
    final sign = isPositive ? '+' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isPositive ? colors.incomeTint : colors.expenseTint,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Selisih $sign${fmtRp(diff)}',
        style: AppText.label(color: color),
      ),
    );
  }

  Widget _buildDetailCard(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          children: [
            if (_type == 'expense' || _type == 'income') ...[
              _buildRow(
                colors: colors,
                icon: Icons.grid_view_rounded,
                label: 'Kategori',
                value: _category?.name ?? 'Pilih',
                onTap: _pickCategory,
                trailing: _category != null
                    ? CatIcon(
                        iconKey: _category!.icon,
                        hue: _category!.hue,
                        size: 28,
                      )
                    : null,
              ),
              _divider(colors),
            ],
            _buildRow(
              colors: colors,
              icon: Icons.account_balance_wallet_outlined,
              label: 'Dompet',
              value: _wallet?.name ?? 'Pilih',
              onTap: () => _pickWallet(isTarget: false),
            ),
            if (_type == 'transfer') ...[
              _divider(colors),
              _buildRow(
                colors: colors,
                icon: Icons.swap_horiz_rounded,
                label: 'Ke dompet',
                value: _targetWallet?.name ?? 'Pilih',
                onTap: () => _pickWallet(isTarget: true),
              ),
            ],
            if (_type == 'expense' || _type == 'income') ...[
              _divider(colors),
              _buildMemberRow(colors),
            ],
            _divider(colors),
            _buildRow(
              colors: colors,
              icon: Icons.notes_rounded,
              label: 'Catatan',
              value: _note.isNotEmpty ? _note : 'Tambah',
              onTap: _pickNote,
            ),
            _divider(colors),
            _buildRow(
              colors: colors,
              icon: Icons.camera_alt_outlined,
              label: 'Foto struk',
              value: 'Opsional',
              onTap: () => AppToast.show(context, 'Segera hadir'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(AppColors colors) =>
      Divider(height: 1, thickness: 1, color: colors.border);

  Widget _buildRow({
    required AppColors colors,
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colors.text3),
            const SizedBox(width: 12),
            Text(label, style: AppText.body(color: colors.text2)),
            const Spacer(),
            if (trailing != null) ...[trailing, const SizedBox(width: 6)],
            Text(
              value,
              style: AppText.body(color: colors.text).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 18, color: colors.text3),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberRow(AppColors colors) {
    return InkWell(
      onTap: _pickMembers,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.person_outline_rounded, size: 18, color: colors.text3),
            const SizedBox(width: 12),
            Text('Untuk', style: AppText.body(color: colors.text2)),
            const Spacer(),
            if (_spentBy.isEmpty)
              Text(
                'Opsional',
                style: AppText.body(color: colors.text3),
              )
            else
              Row(
                children: _spentBy
                    .take(3)
                    .map((m) => Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: MemberAvatar(
                            hue: m.avatarHue,
                            initial: m.name,
                            size: 28,
                          ),
                        ))
                    .toList(),
              ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 18, color: colors.text3),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad(AppColors colors, TxTypeMeta meta) {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '000', '0', 'backspace'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          mainAxisExtent: 52,
        ),
        itemCount: keys.length,
        itemBuilder: (_, i) => _KeypadButton(
          label: keys[i],
          colors: colors,
          onTap: () => _onKey(keys[i]),
        ),
      ),
    );
  }

  Widget _buildSaveButton(AppColors colors, TxTypeMeta meta) {
    final enabled = _isValid && !_loading;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: enabled ? meta.color : colors.surface3,
            borderRadius: BorderRadius.circular(17),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: meta.color.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    )
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(17),
              onTap: enabled ? _save : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_loading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else ...[
                    Icon(
                      Icons.check_rounded,
                      color: enabled ? Colors.white : colors.text3,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Simpan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: enabled ? Colors.white : colors.text3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  String _formatAmount(int n) {
    if (n == 0) return '0';
    // Show without Rp prefix (we render Rp separately)
    final fmt = fmtRp(n);
    return fmt.startsWith('Rp') ? fmt.substring(2) : fmt;
  }
}

// ---------------------------------------------------------------------------
// Keypad Button
// ---------------------------------------------------------------------------

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    required this.label,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isBackspace = label == 'backspace';

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: colors.border),
          ),
          alignment: Alignment.center,
          child: isBackspace
              ? Icon(Icons.backspace_outlined, size: 22, color: colors.text2)
              : Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category Picker Sheet
// ---------------------------------------------------------------------------

class _CategorySheet extends StatelessWidget {
  const _CategorySheet({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Text('Pilih Kategori',
              style: AppText.cardTitle(color: colors.text)),
        ),
        Flexible(
          child: GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: categories.length,
            itemBuilder: (_, i) {
              final cat = categories[i];
              return GestureDetector(
                onTap: () => Navigator.of(context).pop(cat),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CatIcon(iconKey: cat.icon, hue: cat.hue, size: 54),
                    const SizedBox(height: 6),
                    Text(
                      cat.name,
                      style: AppText.micro(color: colors.text2),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Wallet Picker Sheet
// ---------------------------------------------------------------------------

class _WalletSheet extends StatelessWidget {
  const _WalletSheet({
    required this.wallets,
    required this.currentUserId,
    required this.members,
    required this.isTarget,
    this.sourceWalletId,
  });

  final List<Wallet> wallets;
  final int? currentUserId;
  final List<Member> members;
  final bool isTarget;
  final int? sourceWalletId;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    // Group wallets
    final myWallets = wallets
        .where((w) => w.scope == 'personal' && w.ownerUserId == currentUserId)
        .toList();
    final sharedWallets = wallets.where((w) => w.scope == 'shared').toList();
    final otherWallets = wallets
        .where((w) =>
            w.scope == 'personal' && w.ownerUserId != currentUserId)
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Text('Pilih Dompet',
              style: AppText.cardTitle(color: colors.text)),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              if (myWallets.isNotEmpty) ...[
                _sectionHeader('Dompet Saya', colors),
                ...myWallets.map((w) => _walletTile(context, w, colors,
                    disabled: false)),
              ],
              if (sharedWallets.isNotEmpty) ...[
                _sectionHeader('Kas Bersama', colors),
                ...sharedWallets.map((w) => _walletTile(context, w, colors,
                    disabled: false)),
              ],
              if (otherWallets.isNotEmpty) ...[
                _sectionHeader('Dompet Anggota Lain', colors),
                ...otherWallets.map((w) {
                  // For expense/transfer source: other members' wallets disabled
                  final disabled = !isTarget;
                  return _walletTile(context, w, colors, disabled: disabled);
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Text(title, style: AppText.label(color: colors.text3)),
    );
  }

  Widget _walletTile(
      BuildContext context, Wallet w, AppColors colors,
      {required bool disabled}) {
    return Opacity(
      opacity: disabled ? 0.38 : 1.0,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        enabled: !disabled,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.primaryTint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _walletIcon(w.type),
            color: colors.primary,
            size: 20,
          ),
        ),
        title: Text(w.name, style: AppText.body(color: colors.text)),
        subtitle: Text(
          w.scope == 'shared' ? 'Bersama' : 'Pribadi',
          style: AppText.micro(color: colors.text3),
        ),
        trailing: Text(
          fmtRp(w.currentBalance),
          style: AppText.body(color: colors.text2).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: disabled ? null : () => Navigator.of(context).pop(w),
      ),
    );
  }

  IconData _walletIcon(String type) {
    switch (type) {
      case 'bank':
        return Icons.account_balance_outlined;
      case 'ewallet':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.payments_outlined;
    }
  }
}

// ---------------------------------------------------------------------------
// Note Sheet
// ---------------------------------------------------------------------------

class _NoteSheet extends StatefulWidget {
  const _NoteSheet({required this.initial});
  final String initial;

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Catatan', style: AppText.cardTitle(color: colors.text)),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            autofocus: true,
            maxLines: 4,
            style: AppText.body(color: colors.text),
            decoration: InputDecoration(
              hintText: 'Tulis catatan...',
              hintStyle: AppText.body(color: colors.text3),
              filled: true,
              fillColor: colors.surface2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(_ctrl.text),
              child: Text(
                'Simpan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Member Picker Sheet
// ---------------------------------------------------------------------------

class _MemberPickerSheet extends StatefulWidget {
  const _MemberPickerSheet({
    required this.members,
    required this.selected,
  });

  final List<Member> members;
  final List<Member> selected;

  @override
  State<_MemberPickerSheet> createState() => _MemberPickerSheetState();
}

class _MemberPickerSheetState extends State<_MemberPickerSheet> {
  late List<Member> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Text('Untuk Siapa?',
              style: AppText.cardTitle(color: colors.text)),
        ),
        ...widget.members.map((m) {
          final isSelected = _selected.any((s) => s.id == m.id);
          return CheckboxListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            value: isSelected,
            onChanged: (v) => setState(() {
              if (v == true) {
                _selected = [m]; // single select
              } else {
                _selected.removeWhere((s) => s.id == m.id);
              }
            }),
            secondary: MemberAvatar(
              hue: m.avatarHue,
              initial: m.name,
              size: 36,
            ),
            title: Text(m.name, style: AppText.body(color: colors.text)),
            activeColor: colors.primary,
          );
        }),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(_selected),
              child: Text(
                'Pilih',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Extension helper
// ---------------------------------------------------------------------------

extension _ListExt<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
