import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart' hide Category;
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
import '../../features/home/providers/home_providers.dart';
import '../../ui/widgets/app_sheet.dart';
import '../../ui/widgets/app_toast.dart';
import '../../ui/widgets/entrance_animation.dart';
import '../../ui/widgets/member_avatar.dart';
import '../../ui/widgets/money_text.dart';
import 'providers/wallet_providers.dart';

class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final userIdAsync = ref.watch(currentUserIdProvider);
    final userId = userIdAsync.value ?? 1;
    final hiddenAsync = ref.watch(balanceHiddenProvider);
    final hidden = hiddenAsync.value ?? false;

    final totalWealth = ref.watch(totalWealthProvider);
    final myBalance = ref.watch(myBalanceTotalProvider(userId));
    final sharedBalance = ref.watch(sharedBalanceTotalProvider);

    final groups = ref.watch(walletGroupsProvider(userId));

    return Scaffold(
      backgroundColor: colors.appBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Title bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Dompet',
                        style: AppText.screenTitle(color: colors.text),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddWalletSheet(context, ref, userId),
                      icon: Icon(Icons.add_rounded,
                          color: colors.primary, size: 18),
                      label: Text(
                        'Dompet',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: colors.primaryTint,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Emerald total card
                  EntranceAnimation(
                    child: _TotalCard(
                      totalWealth: totalWealth,
                      myBalance: myBalance,
                      sharedBalance: sharedBalance,
                      hidden: hidden,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Dompet Saya
                  if (groups.mine.isNotEmpty) ...[
                    EntranceAnimation(
                      delay: const Duration(milliseconds: 60),
                      child: _WalletGroup(
                        title: 'Dompet Saya',
                        subtitle: 'Dikelola olehmu',
                        subtotal: myBalance,
                        wallets: groups.mine,
                        members: ref.watch(membersProvider).value ?? [],
                        hidden: hidden,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Kas Bersama
                  if (groups.shared.isNotEmpty) ...[
                    EntranceAnimation(
                      delay: const Duration(milliseconds: 120),
                      child: _WalletGroup(
                        title: 'Kas Bersama',
                        subtitle: 'Milik keluarga — semua bisa pakai',
                        subtotal: sharedBalance,
                        wallets: groups.shared,
                        members: ref.watch(membersProvider).value ?? [],
                        hidden: hidden,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Dompet anggota lain
                  ...groups.otherOwners.asMap().entries.map((entry) {
                    final i = entry.key;
                    final owner = entry.value;
                    final ownerWallets = groups.others[owner.id] ?? [];
                    final ownerTotal = ref.watch(otherMemberBalanceProvider(owner.id));
                    return Column(
                      children: [
                        EntranceAnimation(
                          delay: Duration(milliseconds: 180 + i * 60),
                          child: _WalletGroup(
                            title: 'Dompet ${owner.name}',
                            subtitle: 'Hanya bisa dilihat',
                            subtotal: ownerTotal,
                            wallets: ownerWallets,
                            members: ref.watch(membersProvider).value ?? [],
                            hidden: hidden,
                            ownerHue: owner.avatarHue,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWalletSheet(
      BuildContext context, WidgetRef ref, int userId) {
    AppSheet.show(
      context: context,
      child: _AddWalletSheet(userId: userId),
    );
  }
}

// ---------------------------------------------------------------------------
// Total emerald card
// ---------------------------------------------------------------------------

class _TotalCard extends StatelessWidget {
  const _TotalCard({
    required this.totalWealth,
    required this.myBalance,
    required this.sharedBalance,
    required this.hidden,
  });

  final int totalWealth;
  final int myBalance;
  final int sharedBalance;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF058564), Color(0xFF036249)],
        ),
        borderRadius: AppRadius.borderRadiusBase,
        boxShadow: const [
          BoxShadow(
            color: Color(0x52047857),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Kekayaan Keluarga',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 6),
          hidden
              ? Text(
                  '••••••',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 3,
                  ),
                )
              : RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Rp',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.85),
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      TextSpan(
                        text: fmtRp(totalWealth).replaceFirst('Rp', ''),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.02 * 30,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldo Saya',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 3),
                    hidden
                        ? Text('••••••',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ))
                        : Text(
                            fmtRp(myBalance),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontFeatures: const [FontFeature.tabularFigures()],
                              letterSpacing: -0.3,
                            ),
                          ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kas Bersama',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 3),
                    hidden
                        ? Text('••••••',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ))
                        : Text(
                            fmtRp(sharedBalance),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontFeatures: const [FontFeature.tabularFigures()],
                              letterSpacing: -0.3,
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Wallet group section
// ---------------------------------------------------------------------------

class _WalletGroup extends StatelessWidget {
  const _WalletGroup({
    required this.title,
    required this.subtitle,
    required this.subtotal,
    required this.wallets,
    required this.members,
    required this.hidden,
    this.ownerHue,
  });

  final String title;
  final String subtitle;
  final int subtotal;
  final List<Wallet> wallets;
  final List<Member> members;
  final bool hidden;
  final int? ownerHue;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.sectionTitle(color: colors.text),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppText.label(color: colors.text3),
                  ),
                ],
              ),
            ),
            MoneyText(
              amount: subtotal,
              hidden: hidden,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
                letterSpacing: -0.3,
              ),
              color: colors.text2,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.borderRadiusBase,
            border: Border.all(color: colors.border),
            boxShadow: AppShadows.sm,
          ),
          child: Column(
            children: wallets.asMap().entries.map((entry) {
              final idx = entry.key;
              final wallet = entry.value;
              final owner = wallet.ownerUserId != null
                  ? members.cast<Member?>().firstWhere(
                        (m) => m?.id == wallet.ownerUserId,
                        orElse: () => null,
                      )
                  : null;

              return Column(
                children: [
                  _WalletTile(
                    wallet: wallet,
                    owner: owner,
                    hidden: hidden,
                    showAvatar: ownerHue != null,
                    ownerHue: ownerHue,
                  ),
                  if (idx < wallets.length - 1)
                    Divider(
                      height: 1,
                      color: colors.border,
                      indent: 62,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Single wallet tile
// ---------------------------------------------------------------------------

class _WalletTile extends StatelessWidget {
  const _WalletTile({
    required this.wallet,
    required this.owner,
    required this.hidden,
    required this.showAvatar,
    this.ownerHue,
  });

  final Wallet wallet;
  final Member? owner;
  final bool hidden;
  final bool showAvatar;
  final int? ownerHue;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: () => context.push('/wallet/${wallet.id}'),
      borderRadius: AppRadius.borderRadiusBase,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Type icon
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.primaryTint,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                _walletIcon(wallet.type),
                color: colors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Name + type label (+ owner avatar for other members)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallet.name,
                    style: AppText.body(color: colors.text)
                        .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        _typeLabel(wallet.type),
                        style: AppText.label(color: colors.text3),
                      ),
                      if (showAvatar && owner != null && ownerHue != null) ...[
                        const SizedBox(width: 6),
                        MemberAvatar(
                          hue: ownerHue!,
                          initial: owner!.name.isNotEmpty
                              ? owner!.name[0]
                              : '?',
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Balance + chevron
            Row(
              children: [
                MoneyText(
                  amount: wallet.currentBalance,
                  hidden: hidden,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    letterSpacing: -0.4,
                  ),
                  color: colors.text,
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded,
                    color: colors.text3, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static IconData _walletIcon(String type) {
    switch (type) {
      case 'bank':
        return Icons.account_balance_outlined;
      case 'ewallet':
        return Icons.account_balance_wallet_outlined;
      case 'cash':
      default:
        return Icons.payments_outlined;
    }
  }

  static String _typeLabel(String type) {
    switch (type) {
      case 'bank':
        return 'Bank';
      case 'ewallet':
        return 'Dompet Digital';
      case 'cash':
      default:
        return 'Tunai';
    }
  }
}

// ---------------------------------------------------------------------------
// Add Wallet bottom sheet
// ---------------------------------------------------------------------------

class _AddWalletSheet extends ConsumerStatefulWidget {
  const _AddWalletSheet({required this.userId});
  final int userId;

  @override
  ConsumerState<_AddWalletSheet> createState() => _AddWalletSheetState();
}

class _AddWalletSheetState extends ConsumerState<_AddWalletSheet> {
  final _nameCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController();
  String _type = 'cash';
  String _scope = 'personal';
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _nameCtrl.text.trim().isNotEmpty;

  String _formatBalance(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return '';
    final n = int.tryParse(digits) ?? 0;
    return fmtRp(n).replaceFirst('Rp', '');
  }

  int get _parsedBalance {
    final digits =
        _balanceCtrl.text.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(digits) ?? 0;
  }

  Future<void> _save() async {
    if (!_isValid || _saving) return;
    setState(() => _saving = true);

    final name = _nameCtrl.text.trim();
    final balance = _parsedBalance;

    try {
      // Call API first — use server-assigned id
      final api = ref.read(apiClientProvider);
      final result = await api.createWallet({
        'name': name,
        'type': _type,
        'scope': _scope,
        'initial_balance': balance,
        'current_balance': balance,
      });

      final serverId = (result['data']?['id'] ?? result['id']) as int;

      await ref.read(walletRepoProvider).upsert(
            WalletsCompanion(
              id: Value(serverId),
              scope: Value(_scope),
              ownerUserId: _scope == 'personal'
                  ? Value(widget.userId)
                  : const Value.absent(),
              name: Value(name),
              type: Value(_type),
              initialBalance: Value(balance),
              currentBalance: Value(balance),
              deleted: const Value(false),
            ),
          );

      if (mounted) {
        Navigator.of(context).pop();
        AppToast.show(context, 'Dompet "$name" berhasil ditambahkan');
      }
    } catch (e) {
      if (kDebugMode) print('[WalletsScreen] saveWallet error: $e');
      if (mounted) {
        AppToast.show(context, 'Gagal menyimpan dompet', success: false);
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tambah Dompet',
            style: AppText.screenTitle(color: colors.text),
          ),
          const SizedBox(height: 20),
          // Name field
          Text('Nama Dompet',
              style: AppText.label(color: colors.text2)),
          const SizedBox(height: 6),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            style: AppText.body(color: colors.text),
            decoration: InputDecoration(
              hintText: 'Contoh: BCA Utama',
              hintStyle: AppText.body(color: colors.text3),
              filled: true,
              fillColor: colors.surface2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: colors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          // Type chips
          Text('Jenis', style: AppText.label(color: colors.text2)),
          const SizedBox(height: 8),
          Row(
            children: [
              _TypeChip(
                label: 'Tunai',
                icon: Icons.payments_outlined,
                value: 'cash',
                selected: _type == 'cash',
                onTap: () => setState(() => _type = 'cash'),
              ),
              const SizedBox(width: 8),
              _TypeChip(
                label: 'Bank',
                icon: Icons.account_balance_outlined,
                value: 'bank',
                selected: _type == 'bank',
                onTap: () => setState(() => _type = 'bank'),
              ),
              const SizedBox(width: 8),
              _TypeChip(
                label: 'E-Wallet',
                icon: Icons.account_balance_wallet_outlined,
                value: 'ewallet',
                selected: _type == 'ewallet',
                onTap: () => setState(() => _type = 'ewallet'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Scope chips
          Text('Jenis Kepemilikan',
              style: AppText.label(color: colors.text2)),
          const SizedBox(height: 8),
          Row(
            children: [
              _TypeChip(
                label: 'Pribadi',
                icon: Icons.person_outline,
                value: 'personal',
                selected: _scope == 'personal',
                onTap: () => setState(() => _scope = 'personal'),
              ),
              const SizedBox(width: 8),
              _TypeChip(
                label: 'Bersama',
                icon: Icons.group_outlined,
                value: 'shared',
                selected: _scope == 'shared',
                onTap: () => setState(() => _scope = 'shared'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Balance field
          Text('Saldo Awal', style: AppText.label(color: colors.text2)),
          const SizedBox(height: 6),
          TextField(
            controller: _balanceCtrl,
            keyboardType: TextInputType.number,
            style: AppText.body(color: colors.text),
            decoration: InputDecoration(
              prefixText: 'Rp ',
              prefixStyle: AppText.body(color: colors.text2),
              hintText: '0',
              hintStyle: AppText.body(color: colors.text3),
              filled: true,
              fillColor: colors.surface2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: colors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
            ),
            onChanged: (v) {
              final formatted = _formatBalance(v);
              if (formatted != v) {
                _balanceCtrl.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(
                      offset: formatted.length),
                );
              }
              setState(() {});
            },
          ),
          const SizedBox(height: 24),
          // Save button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isValid && !_saving ? _save : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                disabledBackgroundColor: colors.surface3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.base),
                ),
                elevation: 0,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Simpan Dompet',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.onPrimary,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? colors.primaryTint : colors.surface2,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: selected ? colors.primary : colors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected ? colors.primary : colors.text3,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? colors.primary : colors.text2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
