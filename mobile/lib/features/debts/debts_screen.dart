import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/format.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../ui/widgets/amount_sheet.dart';
import '../../ui/widgets/app_progress_bar.dart';
import '../../ui/widgets/app_sheet.dart';
import '../../ui/widgets/app_toast.dart';
import '../../ui/widgets/app_top_bar.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/scope_badge.dart';
import '../../ui/widgets/segmented_control.dart';
import '../goals/widgets/form_inputs.dart';

class DebtsScreen extends ConsumerStatefulWidget {
  const DebtsScreen({super.key});

  @override
  ConsumerState<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends ConsumerState<DebtsScreen> {
  String _tab = 'payable'; // payable | receivable

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final debtsAsync = ref.watch(debtsProvider);
    final walletsAsync = ref.watch(walletsProvider);
    final userAsync = ref.watch(currentUserIdProvider);
    final membersAsync = ref.watch(membersProvider);

    return Scaffold(
      backgroundColor: colors.appBg,
      appBar: AppTopBar(
        title: 'Utang & Piutang',
        action: IconButton(
          icon: Icon(Icons.add_rounded, color: colors.primary, size: 24),
          onPressed: () => AppSheet.show(
            context: context,
            child: _AddDebtSheet(ref: ref),
          ),
          splashRadius: 20,
        ),
      ),
      body: debtsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Gagal memuat',
          sub: e.toString(),
        ),
        data: (debts) {
          final wallets = walletsAsync.value ?? [];
          final uid = userAsync.value;
          final members = membersAsync.value ?? [];

          final payable = debts.where((d) => d.type == 'payable').toList();
          final receivable =
              debts.where((d) => d.type == 'receivable').toList();

          final totalPayable =
              payable.fold(0, (s, d) => s + (d.amount - d.paid));
          final totalReceivable =
              receivable.fold(0, (s, d) => s + (d.amount - d.paid));

          final shown = _tab == 'payable' ? payable : receivable;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              // Summary cards
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'Utang',
                      sub: 'harus dibayar',
                      amount: totalPayable,
                      color: colors.expense,
                      tint: colors.expenseTint,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Piutang',
                      sub: 'akan diterima',
                      amount: totalReceivable,
                      color: colors.income,
                      tint: colors.incomeTint,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Segmented control
              SegmentedControl<String>(
                selected: _tab,
                onChanged: (v) => setState(() => _tab = v),
                items: [
                  SegmentItem(
                      value: 'payable',
                      label: 'Utang (${payable.length})'),
                  SegmentItem(
                      value: 'receivable',
                      label: 'Piutang (${receivable.length})'),
                ],
                activeColor: _tab == 'payable' ? colors.expense : colors.income,
              ),
              const SizedBox(height: 14),
              if (shown.isEmpty)
                EmptyState(
                  icon: Icons.account_balance_outlined,
                  title: _tab == 'payable'
                      ? 'Tidak ada utang'
                      : 'Tidak ada piutang',
                  sub: 'Tap + untuk menambahkan',
                )
              else
                ...shown.map((debt) => _DebtCard(
                      debt: debt,
                      wallets: wallets,
                      uid: uid,
                      members: members,
                      ref: ref,
                    )),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.sub,
    required this.amount,
    required this.color,
    required this.tint,
  });

  final String label;
  final String sub;
  final int amount;
  final Color color;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppText.label(color: color.withValues(alpha: 0.85))),
          const SizedBox(height: 4),
          Text(
            fmtShort(amount),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(sub, style: AppText.micro(color: color.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}

class _DebtCard extends StatelessWidget {
  const _DebtCard({
    required this.debt,
    required this.wallets,
    required this.uid,
    required this.members,
    required this.ref,
  });

  final Debt debt;
  final List<Wallet> wallets;
  final int? uid;
  final List<Member> members;
  final WidgetRef ref;

  int get _remaining => debt.amount - debt.paid;
  double get _fraction =>
      debt.amount > 0 ? debt.paid / debt.amount : 0.0;
  bool get _isPaid => debt.status == 'paid';

  Color _dueColor(AppColors c) {
    if (_isPaid) return c.income;
    if (debt.dueDate == null) return c.text3;
    final diff = debt.dueDate!.difference(DateTime.now()).inDays;
    if (diff < 0) return c.expense;
    if (diff <= 7) return c.expense;
    if (diff <= 14) return const Color(0xFFC98A16);
    return c.text3;
  }

  String _dueLabel(AppColors c) {
    if (_isPaid) return 'Lunas';
    if (debt.dueDate == null) return 'Tanpa jatuh tempo';
    final diff = debt.dueDate!.difference(DateTime.now()).inDays;
    if (diff < 0) return 'Terlambat ${-diff} hari';
    if (diff == 0) return 'Jatuh tempo hari ini';
    return 'Jatuh tempo $diff hari lagi';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isPayable = debt.type == 'payable';
    final typeColor = isPayable ? colors.expense : colors.income;
    final initial = debt.partyName.isNotEmpty ? debt.partyName[0].toUpperCase() : '?';

    final owner = members.where((m) => m.id == debt.ownerUserId).firstOrNull;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => context.push('/debt/${debt.id}'),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF142818).withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Initial chip
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initial,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: typeColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                debt.partyName,
                                style: AppText.cardTitle(color: colors.text),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (owner != null)
                              ScopeBadge(scope: 'personal')
                            else
                              ScopeBadge(scope: 'shared'),
                          ],
                        ),
                        if (debt.note?.isNotEmpty == true) ...[
                          const SizedBox(height: 2),
                          Text(
                            debt.note!,
                            style: AppText.label(color: colors.text3),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _isPaid ? 'Lunas' : 'Sisa ${fmtRp(_remaining)}',
                              style: AppText.label(
                                color: _isPaid ? colors.income : typeColor,
                              ),
                            ),
                            Text(
                              'dari ${fmtRp(debt.amount)}',
                              style: AppText.micro(color: colors.text3),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        AppProgressBar(
                          fraction: _fraction,
                          height: 5,
                          normalColor: typeColor,
                          radius: 3,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _dueLabel(colors),
                          style: AppText.micro(color: _dueColor(colors)),
                        ),
                      ],
                    ),
                  ),
                  if (!_isPaid) ...[
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _showPay(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: typeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        elevation: 0,
                      ),
                      child: Text(
                        isPayable ? 'Bayar' : 'Terima',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPay(BuildContext context) {
    final walletOptions = wallets
        .map((w) => WalletOption(id: w.id, name: w.name, balance: w.currentBalance))
        .toList();
    final colors = context.appColors;

    AmountSheet.show(
      context: context,
      wallets: walletOptions,
      title: debt.type == 'payable' ? 'Bayar Utang' : 'Terima Piutang',
      confirmLabel: debt.type == 'payable' ? 'Bayar' : 'Terima',
      initialAmount: _remaining,
      initialWalletId: debt.walletId,
      accentColor: debt.type == 'payable' ? colors.expense : colors.income,
      onConfirm: (amount, walletId) async {
        final currentUid = uid;
        if (currentUid == null) return;
        await ref.read(debtRepoProvider).pay(
              debtId: debt.id,
              amount: amount,
              walletId: walletId,
              recordedBy: currentUid,
            );
        if (context.mounted) {
          AppToast.show(context,
              debt.type == 'payable' ? 'Pembayaran dicatat' : 'Penerimaan dicatat');
        }
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Add Debt Sheet
// ---------------------------------------------------------------------------

class _AddDebtSheet extends StatefulWidget {
  const _AddDebtSheet({required this.ref});
  final WidgetRef ref;

  @override
  State<_AddDebtSheet> createState() => _AddDebtSheetState();
}

class _AddDebtSheetState extends State<_AddDebtSheet> {
  final _partyCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _type = 'payable';
  int _amount = 0;
  DateTime? _dueDate;
  int? _walletId;

  bool get _canSave =>
      _partyCtrl.text.trim().isNotEmpty && _amount > 0;

  @override
  void dispose() {
    _partyCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_canSave) return;
    final now = DateTime.now();
    final pseudoId = now.millisecondsSinceEpoch % 2147483647;
    final userId = widget.ref.read(currentUserIdProvider).value;
    if (userId == null) return;

    await widget.ref.read(debtRepoProvider).upsert(
          DebtsCompanion.insert(
            id: Value(pseudoId),
            ownerUserId: Value(userId),
            type: _type,
            partyName: _partyCtrl.text.trim(),
            amount: _amount,
            paid: 0,
            date: now,
            dueDate: Value(_dueDate),
            status: 'active',
            note: Value(_noteCtrl.text.trim().isNotEmpty
                ? _noteCtrl.text.trim()
                : null),
            walletId: Value(_walletId),
            pendingSync: const Value(true),
          ),
        );

    if (mounted) {
      Navigator.of(context).pop();
      AppToast.show(context, 'Utang/piutang ditambahkan');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final walletsAsync = widget.ref.watch(walletsProvider);
    final typeColor = _type == 'payable' ? colors.expense : colors.income;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Tambah Utang/Piutang',
              style: AppText.sectionTitle(color: colors.text)),
          const SizedBox(height: 16),
          // Jenis
          Text('Jenis', style: AppText.label(color: colors.text2)),
          const SizedBox(height: 6),
          SegmentedControl<String>(
            selected: _type,
            onChanged: (v) => setState(() => _type = v),
            activeColor: typeColor,
            items: const [
              SegmentItem(value: 'payable', label: 'Utang'),
              SegmentItem(value: 'receivable', label: 'Piutang'),
            ],
          ),
          const SizedBox(height: 14),
          AppTextInput(
            controller: _partyCtrl,
            label: 'Pihak',
            hint: 'Nama orang / perusahaan',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 14),
          RupiahInput(
            label: 'Jumlah',
            onChanged: (v) => setState(() => _amount = v),
          ),
          const SizedBox(height: 14),
          Text('Jatuh Tempo (opsional)',
              style: AppText.label(color: colors.text2)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickDueDate,
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: colors.surface2,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.event_outlined, size: 18, color: colors.text3),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _dueDate != null ? dayLabel(_dueDate!) : 'Pilih tanggal',
                      style: AppText.body(
                          color: _dueDate != null ? colors.text : colors.text3),
                    ),
                  ),
                  if (_dueDate != null)
                    GestureDetector(
                      onTap: () => setState(() => _dueDate = null),
                      child: Icon(Icons.close_rounded,
                          size: 18, color: colors.text3),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text('Dompet Terkait', style: AppText.label(color: colors.text2)),
          const SizedBox(height: 6),
          walletsAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, st) => const SizedBox.shrink(),
            data: (wallets) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: wallets.map((w) {
                  final isSel = _walletId == w.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _walletId = w.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel
                              ? typeColor.withValues(alpha: 0.12)
                              : colors.surface2,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSel ? typeColor : colors.border,
                            width: isSel ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          w.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSel ? typeColor : colors.text,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          AppTextInput(
            controller: _noteCtrl,
            label: 'Catatan',
            hint: 'Opsional',
            icon: Icons.notes_rounded,
          ),
          const SizedBox(height: 20),
          ListenableBuilder(
            listenable: _partyCtrl,
            builder: (context, _) => SaveButton(
              label: 'Simpan',
              enabled: _canSave,
              onPressed: _save,
            ),
          ),
        ],
      ),
    );
  }
}


