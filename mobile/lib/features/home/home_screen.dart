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
import '../../ui/widgets/cat_icon.dart';
import '../../ui/widgets/progress_ring_small.dart';
import '../../ui/widgets/tx_row.dart';
import '../scan_struk/scan_struk_service.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/entrance_animation.dart';
import 'providers/home_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-sync when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(backgroundSyncProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final userIdAsync = ref.watch(currentUserIdProvider);
    final userId = userIdAsync.value ?? 1;

    // Trigger background sync on mount + foreground resume and keep failures
    // visible so users know their financial data is still only local.
    final backgroundSync = ref.watch(backgroundSyncProvider);

    return Scaffold(
      backgroundColor: colors.appBg,
      body: CustomScrollView(
        slivers: [
          // Emerald gradient header
          SliverToBoxAdapter(child: _HomeHeader(userId: userId)),
          if (backgroundSync.hasError)
            SliverToBoxAdapter(
              child: _SyncWarningBanner(
                onRetry: () => ref.invalidate(backgroundSyncProvider),
              ),
            ),
          // Body sections
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                EntranceAnimation(
                  delay: const Duration(milliseconds: 60),
                  child: _ActionGrid(),
                ),
                const SizedBox(height: 20),
                EntranceAnimation(
                  delay: const Duration(milliseconds: 120),
                  child: _BudgetCard(),
                ),
                const SizedBox(height: 20),
                EntranceAnimation(
                  delay: const Duration(milliseconds: 160),
                  child: _AttentionCard(),
                ),
                const SizedBox(height: 20),
                EntranceAnimation(
                  delay: const Duration(milliseconds: 200),
                  child: _UpcomingBillsCard(),
                ),
                const SizedBox(height: 20),
                EntranceAnimation(
                  delay: const Duration(milliseconds: 240),
                  child: _CategoryExpensesCard(),
                ),
                const SizedBox(height: 20),
                EntranceAnimation(
                  delay: const Duration(milliseconds: 280),
                  child: _TargetDebtCard(),
                ),
                const SizedBox(height: 20),
                EntranceAnimation(
                  delay: const Duration(milliseconds: 320),
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

class _SyncWarningBanner extends StatelessWidget {
  const _SyncWarningBanner({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      liveRegion: true,
      label: 'Data belum tersinkron ke server',
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colors.expenseTint,
          borderRadius: AppRadius.borderRadiusBase,
          border: Border.all(color: colors.expense.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(Icons.cloud_off_rounded, color: colors.expense, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Data tersimpan di HP, tetapi belum tersinkron.',
                style: AppText.label(color: colors.text),
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ),
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
                          await sessionRepo.set(
                            'balanceHidden',
                            (!hidden).toString(),
                          );
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
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              TextSpan(
                                text: fmtRp(totalWealth).replaceFirst('Rp', ''),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.03 * 40,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
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
                  const SizedBox(height: 12),
                  // Income/expense this month
                  Consumer(
                    builder: (context, ref, _) {
                      final monthlyAsync = ref.watch(
                        monthlyIncomeExpenseProvider,
                      );
                      final income = monthlyAsync.value?.income ?? 0;
                      final expense = monthlyAsync.value?.expense ?? 0;
                      return Row(
                        children: [
                          Expanded(
                            child: _GlassCard(
                              label: 'Pemasukan Bulan Ini',
                              icon: Icons.arrow_downward_rounded,
                              amount: income,
                              hidden: hidden,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _GlassCard(
                              label: 'Pengeluaran Bulan Ini',
                              icon: Icons.arrow_upward_rounded,
                              amount: expense,
                              hidden: hidden,
                            ),
                          ),
                        ],
                      );
                    },
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
    final unreadCount = ref.watch(unreadNotifCountProvider).value ?? 0;

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
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD23D),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                      height: 1,
                    ),
                  ),
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
              ? Text(
                  '••••••',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                )
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
                        color: isOver ? colors.expense : colors.text2,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colors.text3,
                      size: 18,
                    ),
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
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            TextSpan(
                              text: fmtRp(budget.spent).replaceFirst('Rp', ''),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: isOver ? colors.expense : colors.text,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
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
          loading: () => const SizedBox(
            height: 60,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Attention
// ---------------------------------------------------------------------------

class _AttentionCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final attentionAsync = ref.watch(homeAttentionProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.borderRadiusBase,
        border: Border.all(color: colors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colors.expenseTint,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.notifications_active_outlined,
                  color: colors.expense,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Perlu Perhatian',
                  style: AppText.cardTitle(color: colors.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          attentionAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: colors.incomeTint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: colors.income,
                        size: 20,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Tidak ada anggaran atau utang yang mendesak.',
                          style: AppText.label(color: colors.text2),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  for (var index = 0; index < items.length; index++) ...[
                    _AttentionRow(item: items[index]),
                    if (index != items.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Divider(height: 1, color: colors.border),
                      ),
                  ],
                ],
              );
            },
            loading: () => const SizedBox(
              height: 48,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => TextButton.icon(
              onPressed: () => ref.invalidate(homeAttentionProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Muat ulang'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttentionRow extends StatelessWidget {
  const _AttentionRow({required this.item});

  final HomeAttention item;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDanger = item.kind == HomeAttentionKind.danger;
    final color = isDanger ? colors.expense : colors.adjust;
    final icon = isDanger
        ? Icons.error_outline_rounded
        : Icons.warning_amber_rounded;

    return InkWell(
      onTap: () => context.push(item.route),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.label(
                      color: colors.text,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(item.detail, style: AppText.micro(color: colors.text3)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.text3, size: 19),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Upcoming bills
// ---------------------------------------------------------------------------

class _UpcomingBillsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final bills = ref.watch(upcomingBillsProvider);
    final shownBills = bills.take(3).toList();
    final total = bills.fold(0, (sum, bill) => sum + bill.amount);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.borderRadiusBase,
        border: Border.all(color: colors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tagihan Terdekat',
                      style: AppText.cardTitle(color: colors.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bills.isEmpty
                          ? 'Tujuh hari ke depan'
                          : '${bills.length} tagihan · ${fmtRp(total)}',
                      style: AppText.label(color: colors.text3),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.push('/recurring'),
                child: Text(bills.isEmpty ? 'Atur' : 'Lihat semua'),
              ),
            ],
          ),
          if (bills.isEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              decoration: BoxDecoration(
                color: colors.surface2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_available_outlined,
                    color: colors.text3,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Belum ada tagihan terjadwal dalam waktu dekat.',
                      style: AppText.label(color: colors.text2),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            const SizedBox(height: 10),
            for (var index = 0; index < shownBills.length; index++) ...[
              _UpcomingBillRow(bill: shownBills[index]),
              if (index != shownBills.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1, color: colors.border),
                ),
            ],
            if (bills.length > shownBills.length) ...[
              const SizedBox(height: 10),
              Text(
                '+${bills.length - shownBills.length} tagihan lainnya',
                style: AppText.micro(color: colors.text3),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _UpcomingBillRow extends StatelessWidget {
  const _UpcomingBillRow({required this.bill});

  final UpcomingBill bill;

  String _dueLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(date.year, date.month, date.day);
    final days = due.difference(today).inDays;
    if (days == 0) return 'Hari ini';
    if (days == 1) return 'Besok';
    return DateFormat('EEE, d MMM', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: () => context.push('/recurring'),
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          CatIcon(iconKey: bill.icon, hue: bill.hue, size: 40),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.label(
                    color: colors.text,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      _dueLabel(bill.dueDate),
                      style: AppText.micro(color: colors.text3),
                    ),
                    if (bill.autoCreate) ...[
                      const SizedBox(width: 6),
                      Text(
                        '• Otomatis',
                        style: AppText.micro(color: colors.primary),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            fmtRp(bill.amount),
            style: AppText.label(
              color: colors.expense,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Expense by category
// ---------------------------------------------------------------------------

class _CategoryExpensesCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final expensesAsync = ref.watch(monthlyCategoryExpensesProvider);
    final month = DateFormat('MMMM', 'id_ID').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.borderRadiusBase,
        border: Border.all(color: colors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengeluaran per Kategori',
                      style: AppText.cardTitle(color: colors.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Bulan $month',
                      style: AppText.label(color: colors.text3),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.push('/reports'),
                child: const Text('Laporan'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          expensesAsync.when(
            data: (expenses) {
              if (expenses.isEmpty) {
                return _CategoryExpensesEmpty(month: month);
              }

              final total = expenses.fold(0, (sum, item) => sum + item.total);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total ${fmtRp(total)}',
                    style: AppText.body(
                      color: colors.text,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),
                  for (var index = 0; index < expenses.length; index++) ...[
                    _CategoryExpenseRow(
                      expense: expenses[index],
                      totalExpense: total,
                    ),
                    if (index != expenses.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1, color: colors.border),
                      ),
                  ],
                ],
              );
            },
            loading: () => const SizedBox(
              height: 88,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => Center(
              child: TextButton.icon(
                onPressed: () =>
                    ref.invalidate(monthlyCategoryExpensesProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Muat ulang kategori'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryExpenseRow extends StatelessWidget {
  const _CategoryExpenseRow({
    required this.expense,
    required this.totalExpense,
  });

  final CategoryExpenseSummary expense;
  final int totalExpense;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final fraction = totalExpense > 0 ? expense.total / totalExpense : 0.0;
    final percentage = (fraction * 100).round();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = isDark
        ? HSLColor.fromAHSL(1, expense.hue.toDouble(), 0.58, 0.66).toColor()
        : HSLColor.fromAHSL(1, expense.hue.toDouble(), 0.55, 0.42).toColor();

    return Semantics(
      label:
          '${expense.name}, ${fmtRp(expense.total)}, $percentage persen dari pengeluaran bulan ini',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatIcon(iconKey: expense.icon, hue: expense.hue, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        expense.name,
                        style: AppText.body(
                          color: colors.text,
                        ).copyWith(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      fmtRp(expense.total),
                      style: AppText.label(
                        color: colors.text,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                AppProgressBar(
                  fraction: fraction,
                  height: 6,
                  normalColor: categoryColor,
                  overColor: categoryColor,
                  trackColor: colors.surface2,
                ),
                const SizedBox(height: 5),
                Text(
                  '$percentage% dari total pengeluaran',
                  style: AppText.label(
                    color: colors.text3,
                  ).copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryExpensesEmpty extends StatelessWidget {
  const _CategoryExpensesEmpty({required this.month});

  final String month;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: AppRadius.borderRadiusBase,
      ),
      child: Column(
        children: [
          Icon(Icons.donut_small_outlined, color: colors.text3, size: 28),
          const SizedBox(height: 8),
          Text(
            'Belum ada pengeluaran di bulan $month',
            style: AppText.label(color: colors.text2),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick actions
// ---------------------------------------------------------------------------

class _ActionGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    final items = <_GridItem>[
      // Row 1 — quick actions (primary tint bg)
      _GridItem(
        icon: Icons.group_outlined,
        label: 'Isi Kas\nBersama',
        primary: true,
        onTap: () => context.push('/add-transaction?preset=topup-shared'),
      ),
      _GridItem(
        icon: Icons.swap_horiz_rounded,
        label: 'Transfer',
        primary: true,
        onTap: () => context.push('/add-transaction?preset=transfer'),
      ),
      _GridItem(
        icon: Icons.arrow_upward_rounded,
        label: 'Pemasukan',
        primary: true,
        onTap: () => context.push('/add-transaction?preset=income'),
      ),
      _GridItem(
        icon: Icons.arrow_downward_rounded,
        label: 'Pengeluaran',
        primary: true,
        onTap: () => context.push('/add-transaction?preset=expense'),
      ),
      _GridItem(
        icon: Icons.document_scanner_outlined,
        label: 'Scan\nStruk',
        primary: true,
        onTap: () async {
          final result = await ScanStrukService().scan(context);
          if (result != null && context.mounted) {
            final parts = <String>[];
            if (result.amount != null) parts.add('amount=${result.amount}');
            if (result.note != null) {
              parts.add('note=${Uri.encodeQueryComponent(result.note!)}');
            }
            final qs = parts.isNotEmpty ? '?${parts.join('&')}' : '';
            context.push('/add-transaction$qs');
          }
        },
      ),
      // Row 2 — feature hubs (surface bg)
      _GridItem(
        icon: Icons.tune_rounded,
        label: 'Anggaran',
        primary: false,
        onTap: () => context.push('/budget'),
      ),
      _GridItem(
        icon: Icons.flag_circle_outlined,
        label: 'Tujuan',
        primary: false,
        onTap: () => context.push('/goals'),
      ),
      _GridItem(
        icon: Icons.account_balance_outlined,
        label: 'Utang',
        primary: false,
        onTap: () => context.push('/debts'),
      ),
      _GridItem(
        icon: Icons.autorenew_rounded,
        label: 'Berulang',
        primary: false,
        onTap: () => context.push('/recurring'),
      ),
      _GridItem(
        icon: Icons.bar_chart_rounded,
        label: 'Laporan',
        primary: false,
        onTap: () => context.push('/reports'),
      ),
    ];

    return GridView.count(
      crossAxisCount: 5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 4,
      childAspectRatio: 0.78,
      children: items.map((item) {
        return GestureDetector(
          onTap: item.onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: item.primary ? colors.primaryTint : colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: item.primary
                      ? null
                      : Border.all(color: colors.border),
                  boxShadow: item.primary ? null : AppShadows.sm,
                ),
                child: Icon(
                  item.icon,
                  color: item.primary ? colors.primary : colors.text2,
                  size: 22,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                item.label,
                style: AppText.label(
                  color: colors.text2,
                ).copyWith(fontSize: 10.5, height: 1.3),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _GridItem {
  const _GridItem({
    required this.icon,
    required this.label,
    required this.primary,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onTap;
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
    final goalsTarget = goals.fold(0, (sum, g) => sum + g.targetAmount);
    final goalsFraction = goalsTarget > 0 ? goalsTotal / goalsTarget : 0.0;

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
                            Text(
                              'Kantong Tujuan',
                              style: AppText.label(color: colors.text2),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              hidden ? '••••••' : fmtShort(goalsTotal),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: colors.text,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
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
                      Text(
                        'Utang / Piutang',
                        style: AppText.label(color: colors.text2),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            hidden
                                ? '••••••'
                                : '−${fmtShort(debtSummary.payable)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colors.expense,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            hidden
                                ? '••••••'
                                : '+${fmtShort(debtSummary.receivable)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colors.income,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
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
              child: Text(
                'Transaksi Terbaru',
                style: AppText.sectionTitle(color: colors.text),
              ),
            ),
            GestureDetector(
              onTap: () => context.go('/transactions'),
              child: Text(
                'Lihat semua',
                style: AppText.label(color: colors.primary),
              ),
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
                          recorderInitial: recorder?.name.isNotEmpty == true
                              ? recorder!.name[0]
                              : '?',
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
      case 'income':
        return 'Pemasukan';
      case 'expense':
        return 'Pengeluaran';
      case 'transfer':
        return 'Transfer';
      default:
        return 'Penyesuaian';
    }
  }

  String _typeIconKey(String type) {
    switch (type) {
      case 'income':
        return 'briefcase';
      case 'transfer':
        return 'signal';
      default:
        return 'dots';
    }
  }
}
