import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/format.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../ui/widgets/member_avatar.dart';
import '../../ui/widgets/app_progress_bar.dart';
import '../../ui/widgets/progress_ring_small.dart';
import '../../ui/widgets/tx_row.dart';
import '../../ui/widgets/app_toast.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/entrance_animation.dart';
import 'providers/home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final userIdAsync = ref.watch(currentUserIdProvider);
    final userId = userIdAsync.value ?? 1;

    return Scaffold(
      backgroundColor: colors.appBg,
      body: CustomScrollView(
        slivers: [
          // Emerald gradient header
          SliverToBoxAdapter(
            child: _HomeHeader(userId: userId),
          ),
          // Body sections
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                EntranceAnimation(
                  delay: const Duration(milliseconds: 60),
                  child: _BudgetCard(),
                ),
                const SizedBox(height: 20),
                EntranceAnimation(
                  delay: const Duration(milliseconds: 120),
                  child: _QuickActions(),
                ),
                const SizedBox(height: 20),
                EntranceAnimation(
                  delay: const Duration(milliseconds: 180),
                  child: _FeatureHub(),
                ),
                const SizedBox(height: 20),
                EntranceAnimation(
                  delay: const Duration(milliseconds: 240),
                  child: _TargetDebtCard(),
                ),
                const SizedBox(height: 20),
                EntranceAnimation(
                  delay: const Duration(milliseconds: 300),
                  child: _RecentTransactions(userId: userId),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _HomeHeader extends ConsumerStatefulWidget {
  const _HomeHeader({required this.userId});
  final int userId;

  @override
  ConsumerState<_HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends ConsumerState<_HomeHeader> {
  @override
  Widget build(BuildContext context) {
    final members = ref.watch(membersProvider).value ?? [];
    final member = members.cast<Member?>().firstWhere(
          (m) => m?.id == widget.userId,
          orElse: () => members.isNotEmpty ? members.first : null,
        );

    final totalWealth = ref.watch(totalWealthProvider);
    final myBalance = ref.watch(myBalanceProvider(widget.userId));
    final sharedBalance = ref.watch(sharedBalanceProvider);
    final hiddenAsync = ref.watch(balanceHiddenProvider);
    final hidden = hiddenAsync.value ?? false;

    final greeting = _greeting();
    final name = member?.name ?? 'Pengguna';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF058564), Color(0xFF036249)],
          transform: GradientRotation(158 * 3.14159 / 180),
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 60,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row: avatar + greeting + bell
                  Row(
                    children: [
                      if (member != null)
                        MemberAvatar(
                          hue: member.avatarHue,
                          initial: name[0],
                          size: 40,
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$greeting,',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.80),
                              ),
                            ),
                            Text(
                              '$name \u{1F44B}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _BellButton(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Total kekayaan
                  Row(
                    children: [
                      Text(
                        'Total Kekayaan Keluarga',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.80),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          final sessionRepo = ref.read(sessionRepoProvider);
                          await sessionRepo.set('balanceHidden', (!hidden).toString());
                        },
                        child: Icon(
                          hidden
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white.withValues(alpha: 0.75),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Hero amount
                  hidden
                      ? Text(
                          '••••••',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        )
                      : RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Rp',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.82),
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                              TextSpan(
                                text: fmtRp(totalWealth).replaceFirst('Rp', ''),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.03 * 40,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                        ),
                  const SizedBox(height: 16),
                  // Glass cards
                  Row(
                    children: [
                      Expanded(
                        child: _GlassCard(
                          label: 'Saldo Saya',
                          icon: Icons.person_outline,
                          amount: myBalance,
                          hidden: hidden,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GlassCard(
                          label: 'Kas Bersama',
                          icon: Icons.group_outlined,
                          amount: sharedBalance,
                          hidden: hidden,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }
}

class _BellButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/notifications'),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_outlined,
                color: Colors.white, size: 22),
          ),
          Positioned(
            top: 6,
            right: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD23D),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.label,
    required this.icon,
    required this.amount,
    required this.hidden,
  });

  final String label;
  final IconData icon;
  final int amount;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white.withValues(alpha: 0.80), size: 14),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.80),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          hidden
              ? Text('••••••',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 18.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 2))
              : Text(
                  fmtRp(amount),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Budget card
// ---------------------------------------------------------------------------

class _BudgetCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final budgetAsync = ref.watch(budgetSummaryProvider);
    final month = DateFormat('MMMM', 'id_ID').format(DateTime.now());

    return GestureDetector(
      onTap: () => context.push('/budget'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.borderRadiusBase,
          border: Border.all(color: colors.border),
          boxShadow: AppShadows.sm,
        ),
        child: budgetAsync.when(
          data: (budget) {
            final pct = (budget.fraction * 100).round();
            final isOver = budget.fraction > 1.0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Pengeluaran $month',
                        style: AppText.cardTitle(color: colors.text),
                      ),
                    ),
                    Text(
                      '$pct% terpakai',
                      style: AppText.label(
                          color: isOver ? colors.expense : colors.text2),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded,
                        color: colors.text3, size: 18),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Rp',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: colors.text,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                            TextSpan(
                              text: fmtRp(budget.spent).replaceFirst('Rp', ''),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: isOver ? colors.expense : colors.text,
                                fontFeatures: const [FontFeature.tabularFigures()],
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      'dari ${fmtRp(budget.budgeted)}',
                      style: AppText.label(color: colors.text3),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AppProgressBar(
                  fraction: budget.fraction,
                  height: 6,
                  normalColor: colors.primary,
                  overColor: colors.expense,
                  trackColor: colors.surface2,
                ),
              ],
            );
          },
          loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator())),
          error: (e, _) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick actions
// ---------------------------------------------------------------------------

class _QuickActions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    final actions = [
      _ActionItem(
        icon: Icons.group_outlined,
        label: 'Isi Kas\nBersama',
        onTap: () => context.push('/add-transaction?preset=topup-shared'),
      ),
      _ActionItem(
        icon: Icons.swap_horiz_rounded,
        label: 'Transfer',
        onTap: () => context.push('/add-transaction?preset=transfer'),
      ),
      _ActionItem(
        icon: Icons.arrow_upward_rounded,
        label: 'Pemasukan',
        onTap: () => context.push('/add-transaction?preset=income'),
      ),
      _ActionItem(
        icon: Icons.document_scanner_outlined,
        label: 'Scan\nStruk',
        onTap: () => AppToast.show(context, 'Segera hadir'),
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((a) {
        return Expanded(
          child: GestureDetector(
            onTap: a.onTap,
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colors.primaryTint,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Icon(a.icon, color: colors.primary, size: 24),
                ),
                const SizedBox(height: 6),
                Text(
                  a.label,
                  style: AppText.label(color: colors.text2)
                      .copyWith(height: 1.3),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ActionItem {
  const _ActionItem({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

// ---------------------------------------------------------------------------
// Feature hub
// ---------------------------------------------------------------------------

class _FeatureHub extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    final hubs = [
      _HubItem(icon: Icons.tune_rounded, label: 'Anggaran', route: '/budget'),
      _HubItem(icon: Icons.flag_circle_outlined, label: 'Tujuan', route: '/goals'),
      _HubItem(icon: Icons.account_balance_outlined, label: 'Utang', route: '/debts'),
      _HubItem(icon: Icons.autorenew_rounded, label: 'Berulang', route: '/recurring'),
      _HubItem(icon: Icons.bar_chart_rounded, label: 'Laporan', route: '/reports'),
    ];

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hubs.length,
        separatorBuilder: (_, idx) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final hub = hubs[i];
          return GestureDetector(
            onTap: () => context.push(hub.route),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colors.border),
                    boxShadow: AppShadows.sm,
                  ),
                  child: Icon(hub.icon, color: colors.text2, size: 24),
                ),
                const SizedBox(height: 6),
                Text(hub.label,
                    style: AppText.label(color: colors.text2)
                        .copyWith(fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HubItem {
  const _HubItem({required this.icon, required this.label, required this.route});
  final IconData icon;
  final String label;
  final String route;
}

// ---------------------------------------------------------------------------
// Target & Debt summary card
// ---------------------------------------------------------------------------

class _TargetDebtCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final goalsTotal = ref.watch(goalsTotalProvider);
    final goals = ref.watch(goalsProvider).value ?? [];
    final goalsTarget =
        goals.fold(0, (sum, g) => sum + g.targetAmount);
    final goalsFraction =
        goalsTarget > 0 ? goalsTotal / goalsTarget : 0.0;

    final debtSummary = ref.watch(debtSummaryProvider);
    final hiddenAsync = ref.watch(balanceHiddenProvider);
    final hidden = hiddenAsync.value ?? false;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.borderRadiusBase,
        border: Border.all(color: colors.border),
        boxShadow: AppShadows.sm,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Goals
            Expanded(
              child: GestureDetector(
                onTap: () => context.push('/goals'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ProgressRingSmall(
                        fraction: goalsFraction.clamp(0.0, 1.0),
                        size: 42,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Kantong Tujuan',
                                style: AppText.label(color: colors.text2)),
                            const SizedBox(height: 3),
                            Text(
                              hidden ? '••••••' : fmtShort(goalsTotal),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: colors.text,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Divider
            VerticalDivider(color: colors.border, thickness: 1, width: 1),
            // Debts
            Expanded(
              child: GestureDetector(
                onTap: () => context.push('/debts'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Utang / Piutang',
                          style: AppText.label(color: colors.text2)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            hidden ? '••••••' : '−${fmtShort(debtSummary.payable)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colors.expense,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            hidden ? '••••••' : '+${fmtShort(debtSummary.receivable)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colors.income,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recent transactions
// ---------------------------------------------------------------------------

class _RecentTransactions extends ConsumerWidget {
  const _RecentTransactions({required this.userId});
  final int userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final txList = ref.watch(recent5Provider);
    final members = ref.watch(membersProvider).value ?? [];
    final wallets = ref.watch(walletsProvider).value ?? [];
    final categories = ref.watch(categoriesProvider).value ?? [];
    final hiddenAsync = ref.watch(balanceHiddenProvider);
    final hidden = hiddenAsync.value ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Transaksi Terbaru',
                  style: AppText.sectionTitle(color: colors.text)),
            ),
            GestureDetector(
              onTap: () => context.go('/transactions'),
              child: Text('Lihat semua',
                  style: AppText.label(color: colors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.borderRadiusBase,
            border: Border.all(color: colors.border),
            boxShadow: AppShadows.sm,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: txList.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'Belum ada transaksi',
                    sub: 'Catat transaksi pertamamu',
                  ),
                )
              : Column(
                  children: txList.asMap().entries.map((entry) {
                    final tx = entry.value as Transaction;
                    final recorder = members.cast<Member?>().firstWhere(
                          (m) => m?.id == tx.recordedBy,
                          orElse: () => null,
                        );
                    final spentBy = tx.spentBy != null
                        ? members.cast<Member?>().firstWhere(
                              (m) => m?.id == tx.spentBy,
                              orElse: () => null,
                            )
                        : null;
                    final wallet = wallets.cast<Wallet?>().firstWhere(
                          (w) => w?.id == tx.walletId,
                          orElse: () => null,
                        );
                    final category = tx.categoryId != null
                        ? categories.cast<Category?>().firstWhere(
                              (c) => c?.id == tx.categoryId,
                              orElse: () => null,
                            )
                        : null;

                    final catName = category?.name ?? _typeLabel(tx.type);
                    final catIconKey = category?.icon ?? _typeIconKey(tx.type);
                    final catHue = category?.hue ?? 162;

                    return Column(
                      children: [
                        TxRow(
                          type: tx.type,
                          categoryName: catName,
                          categoryIconKey: catIconKey,
                          categoryHue: catHue,
                          recorderInitial:
                              recorder?.name.isNotEmpty == true ? recorder!.name[0] : '?',
                          recorderHue: recorder?.avatarHue ?? 162,
                          title: catName,
                          walletName: wallet?.name ?? 'Dompet',
                          note: tx.note,
                          spentByName: spentBy?.name,
                          amount: tx.amount,
                          hidden: hidden,
                          onTap: () {},
                        ),
                        if (entry.key < txList.length - 1)
                          Divider(color: colors.border, height: 1),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'income': return 'Pemasukan';
      case 'expense': return 'Pengeluaran';
      case 'transfer': return 'Transfer';
      default: return 'Penyesuaian';
    }
  }

  String _typeIconKey(String type) {
    switch (type) {
      case 'income': return 'briefcase';
      case 'transfer': return 'signal';
      default: return 'dots';
    }
  }
}
