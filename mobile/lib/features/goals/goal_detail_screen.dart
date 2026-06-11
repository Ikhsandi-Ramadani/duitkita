import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/format.dart';
import '../../data/providers.dart';
import '../../ui/widgets/amount_sheet.dart';
import '../../ui/widgets/app_progress_bar.dart';
import '../../ui/widgets/app_toast.dart';
import '../../ui/widgets/app_top_bar.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/scope_badge.dart';
import '../../ui/widgets/tx_row.dart';
import '../../ui/widgets/app_progress_bar.dart' show ProgressRing;


class GoalDetailScreen extends ConsumerWidget {
  const GoalDetailScreen({super.key, required this.goalId});

  final int goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final goalsAsync = ref.watch(goalsProvider);
    final walletsAsync = ref.watch(walletsProvider);
    final userAsync = ref.watch(currentUserIdProvider);

    return goalsAsync.when(
      loading: () => Scaffold(
        backgroundColor: colors.appBg,
        appBar: AppTopBar(title: 'Detail Kantong'),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: colors.appBg,
        appBar: AppTopBar(title: 'Detail Kantong'),
        body: EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Gagal memuat',
          sub: e.toString(),
        ),
      ),
      data: (goals) {
        final goal = goals.where((g) => g.id == goalId).firstOrNull;
        if (goal == null) {
          return Scaffold(
            backgroundColor: colors.appBg,
            appBar: AppTopBar(title: 'Detail Kantong'),
            body: const EmptyState(
              icon: Icons.flag_circle_outlined,
              title: 'Kantong tidak ditemukan',
            ),
          );
        }

        final wallets = walletsAsync.value ?? [];
        final goalWallet =
            wallets.where((w) => w.id == goal.walletId).firstOrNull;
        final walletOptions = wallets
            .map((w) => WalletOption(id: w.id, name: w.name, balance: w.currentBalance))
            .toList();
        final uid = userAsync.value ?? 1;
        final fraction =
            goal.targetAmount > 0 ? goal.currentAmount / goal.targetAmount : 0.0;
        final ringColor =
            HSLColor.fromAHSL(1.0, goal.hue.toDouble(), 0.55, 0.42).toColor();

        return Scaffold(
          backgroundColor: colors.appBg,
          appBar: AppTopBar(title: goal.name),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              // Hero card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.border),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF142818).withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ProgressRing(
                      fraction: fraction,
                      size: 104,
                      strokeWidth: 8,
                      color: ringColor,
                      centerWidget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(fraction * 100).toStringAsFixed(0)}%',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: ringColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      goal.name,
                      style: AppText.screenTitle(color: colors.text),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ScopeBadge(scope: goal.scope),
                        if (goal.targetDate != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            dayLabel(goal.targetDate!),
                            style: AppText.micro(color: colors.text3),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCell(
                            label: 'Terkumpul',
                            value: fmtRp(goal.currentAmount),
                            valueColor: ringColor,
                          ),
                        ),
                        Container(
                            width: 1,
                            height: 36,
                            color: colors.border),
                        Expanded(
                          child: _StatCell(
                            label: 'Target',
                            value: fmtRp(goal.targetAmount),
                          ),
                        ),
                      ],
                    ),
                    if (goalWallet != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: colors.surface2,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.account_balance_wallet_outlined,
                                size: 14, color: colors.text3),
                            const SizedBox(width: 6),
                            Text(
                              'Tersimpan di ${goalWallet.name}',
                              style: AppText.micro(color: colors.text2),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => AmountSheet.show(
                          context: context,
                          wallets: walletOptions,
                          title: 'Sisihkan Dana',
                          confirmLabel: 'Sisihkan',
                          accentColor: ringColor,
                          onConfirm: (amount, walletId) async {
                            await ref.read(goalRepoProvider).contribute(
                                  goalId: goal.id,
                                  amount: amount,
                                  sourceWalletId: walletId,
                                  recordedBy: uid,
                                );
                            if (context.mounted) {
                              AppToast.show(context, 'Dana berhasil disisihkan');
                            }
                          },
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ringColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Sisihkan Dana',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Riwayat Kontribusi',
                  style: AppText.sectionTitle(color: colors.text)),
              const SizedBox(height: 12),
              // Transactions going into the goal wallet
              if (goalWallet != null)
                _GoalHistory(walletId: goal.walletId)
              else
                const EmptyState(
                  icon: Icons.history_rounded,
                  title: 'Belum ada kontribusi',
                  sub: 'Mulai sisihkan dana untuk kantong ini',
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        Text(label, style: AppText.micro(color: colors.text3)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: valueColor ?? colors.text,
          ),
        ),
      ],
    );
  }
}

class _GoalHistory extends ConsumerWidget {
  const _GoalHistory({required this.walletId});
  final int walletId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(txByWalletProvider(walletId));
    final colors = context.appColors;
    final walletsAsync = ref.watch(walletsProvider);
    final catsAsync = ref.watch(categoriesProvider);
    final membersAsync = ref.watch(membersProvider);

    return txAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const SizedBox.shrink(),
      data: (txList) {
        // Filter only incoming transfers (contributions)
        final contributions =
            txList.where((t) => t.targetWalletId == walletId).toList();

        if (contributions.isEmpty) {
          return const EmptyState(
            icon: Icons.history_rounded,
            title: 'Belum ada kontribusi',
            sub: 'Mulai sisihkan dana untuk kantong ini',
          );
        }

        final wallets = walletsAsync.value ?? [];
        final cats = catsAsync.value ?? [];
        final members = membersAsync.value ?? [];

        final walletMap = {for (final w in wallets) w.id: w};
        final catMap = {for (final c in cats) c.id: c};
        final memberMap = {for (final m in members) m.id: m};

        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: contributions.map((tx) {
              final cat = tx.categoryId != null ? catMap[tx.categoryId] : null;
              final wallet = walletMap[tx.walletId];
              final recorder = memberMap[tx.recordedBy];
              final spentMember =
                  tx.spentBy != null ? memberMap[tx.spentBy] : null;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TxRow(
                  type: tx.type,
                  categoryName: cat?.name ?? 'Transfer',
                  categoryIconKey: cat?.icon ?? 'account_balance_wallet',
                  categoryHue: cat?.hue ?? 162,
                  recorderInitial: recorder?.name.isNotEmpty == true
                      ? recorder!.name[0]
                      : '?',
                  recorderHue: recorder?.avatarHue ?? 162,
                  title: cat?.name ?? 'Kontribusi',
                  walletName: wallet?.name ?? '-',
                  note: tx.note,
                  spentByName: spentMember?.name,
                  amount: tx.amount,
                  hidden: false,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}


