import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/format.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../ui/widgets/amount_sheet.dart';
import '../../ui/widgets/app_progress_bar.dart';
import '../../ui/widgets/app_toast.dart';
import '../../ui/widgets/app_top_bar.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/scope_badge.dart';
import '../../ui/widgets/tx_row.dart';

class DebtDetailScreen extends ConsumerWidget {
  const DebtDetailScreen({super.key, required this.debtId});

  final int debtId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final debtsAsync = ref.watch(debtsProvider);
    final walletsAsync = ref.watch(walletsProvider);
    final userAsync = ref.watch(currentUserIdProvider);
    final membersAsync = ref.watch(membersProvider);

    return debtsAsync.when(
      loading: () => Scaffold(
        backgroundColor: colors.appBg,
        appBar: AppTopBar(title: 'Detail Utang'),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: colors.appBg,
        appBar: AppTopBar(title: 'Detail Utang'),
        body: EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Gagal memuat',
          sub: e.toString(),
        ),
      ),
      data: (debts) {
        final debt = debts.where((d) => d.id == debtId).firstOrNull;
        if (debt == null) {
          return Scaffold(
            backgroundColor: colors.appBg,
            appBar: AppTopBar(title: 'Detail Utang'),
            body: const EmptyState(
              icon: Icons.account_balance_outlined,
              title: 'Data tidak ditemukan',
            ),
          );
        }

        final wallets = walletsAsync.value ?? [];
        final uid = userAsync.value ?? 1;
        final members = membersAsync.value ?? [];
        final isPayable = debt.type == 'payable';
        final typeColor = isPayable ? colors.expense : colors.income;
        final typeTint = isPayable ? colors.expenseTint : colors.incomeTint;
        final initial =
            debt.partyName.isNotEmpty ? debt.partyName[0].toUpperCase() : '?';
        final isPaid = debt.status == 'paid';
        final remaining = debt.amount - debt.paid;
        final fraction =
            debt.amount > 0 ? debt.paid / debt.amount : 0.0;

        String dueLabel;
        Color dueColor;
        if (isPaid) {
          dueLabel = 'Lunas';
          dueColor = colors.income;
        } else if (debt.dueDate == null) {
          dueLabel = 'Tanpa jatuh tempo';
          dueColor = colors.text3;
        } else {
          final diff = debt.dueDate!.difference(DateTime.now()).inDays;
          if (diff < 0) {
            dueLabel = 'Terlambat ${-diff} hari';
            dueColor = colors.expense;
          } else if (diff == 0) {
            dueLabel = 'Jatuh tempo hari ini';
            dueColor = colors.expense;
          } else if (diff <= 7) {
            dueLabel = 'Jatuh tempo $diff hari lagi';
            dueColor = colors.expense;
          } else if (diff <= 14) {
            dueLabel = 'Jatuh tempo $diff hari lagi';
            dueColor = const Color(0xFFC98A16);
          } else {
            dueLabel = 'Jatuh tempo ${dayLabel(debt.dueDate!)}';
            dueColor = colors.text3;
          }
        }

        final owner = members.where((m) => m.id == debt.ownerUserId).firstOrNull;

        return Scaffold(
          backgroundColor: colors.appBg,
          appBar: AppTopBar(title: debt.partyName),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              // Hero card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: typeTint,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: typeColor.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    // Initial chip
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initial,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: typeColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      debt.partyName,
                      style: AppText.screenTitle(color: colors.text),
                      textAlign: TextAlign.center,
                    ),
                    if (debt.note?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        debt.note!,
                        style: AppText.body(color: colors.text2),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isPayable ? 'Utang' : 'Piutang',
                            style: AppText.micro(color: typeColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ScopeBadge(
                            scope: owner == null ? 'shared' : 'personal'),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: dueColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            dueLabel,
                            style: AppText.micro(color: dueColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCell(
                            label: isPaid ? 'Lunas' : 'Sisa',
                            value: fmtRp(isPaid ? debt.amount : remaining),
                            color: typeColor,
                          ),
                        ),
                        Container(width: 1, height: 36, color: typeColor.withValues(alpha: 0.25)),
                        Expanded(
                          child: _StatCell(
                            label: 'Total',
                            value: fmtRp(debt.amount),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AppProgressBar(
                      fraction: fraction,
                      height: 6,
                      normalColor: typeColor,
                      trackColor: typeColor.withValues(alpha: 0.2),
                      radius: 3,
                    ),
                    if (!isPaid) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => _showPay(
                            context: context,
                            ref: ref,
                            debt: debt,
                            wallets: wallets,
                            remaining: remaining,
                            uid: uid,
                            typeColor: typeColor,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: typeColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isPayable ? 'Bayar Cicilan' : 'Terima Pembayaran',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Riwayat Pembayaran',
                  style: AppText.sectionTitle(color: colors.text)),
              const SizedBox(height: 12),
              _PaymentHistory(
                debt: debt,
                ref: ref,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPay({
    required BuildContext context,
    required WidgetRef ref,
    required Debt debt,
    required List<Wallet> wallets,
    required int remaining,
    required int uid,
    required Color typeColor,
  }) {
    final walletOptions = wallets
        .map((w) => WalletOption(id: w.id, name: w.name, balance: w.currentBalance))
        .toList();

    AmountSheet.show(
      context: context,
      wallets: walletOptions,
      title: debt.type == 'payable' ? 'Bayar Cicilan' : 'Terima Pembayaran',
      confirmLabel: debt.type == 'payable' ? 'Bayar' : 'Terima',
      initialAmount: remaining,
      initialWalletId: debt.walletId,
      accentColor: typeColor,
      onConfirm: (amount, walletId) async {
        await ref.read(debtRepoProvider).pay(
              debtId: debt.id,
              amount: amount,
              walletId: walletId,
              recordedBy: uid,
            );
        if (context.mounted) {
          AppToast.show(context,
              debt.type == 'payable' ? 'Pembayaran dicatat' : 'Penerimaan dicatat');
        }
      },
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

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
            color: color ?? colors.text,
          ),
        ),
      ],
    );
  }
}

class _PaymentHistory extends ConsumerWidget {
  const _PaymentHistory({required this.debt, required this.ref});
  final Debt debt;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef watchRef) {
    final colors = context.appColors;
    final notePrefix = debt.type == 'payable'
        ? 'Pembayaran utang: ${debt.partyName}'
        : 'Penerimaan piutang: ${debt.partyName}';

    final recentAsync = watchRef.watch(recentTransactionsProvider);
    final walletsAsync = watchRef.watch(walletsProvider);
    final membersAsync = watchRef.watch(membersProvider);
    final catsAsync = watchRef.watch(categoriesProvider);

    return recentAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const SizedBox.shrink(),
      data: (all) {
        final payments = all
            .where((t) => (t.note ?? '').startsWith(notePrefix))
            .toList();

        if (payments.isEmpty) {
          return const EmptyState(
            icon: Icons.history_rounded,
            title: 'Belum ada riwayat pembayaran',
          );
        }

        final wallets = walletsAsync.value ?? [];
        final members = membersAsync.value ?? [];
        final cats = catsAsync.value ?? [];
        final walletMap = {for (final w in wallets) w.id: w};
        final memberMap = {for (final m in members) m.id: m};
        final catMap = {for (final c in cats) c.id: c};

        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: payments.map((tx) {
              final cat = tx.categoryId != null ? catMap[tx.categoryId] : null;
              final wallet = walletMap[tx.walletId];
              final recorder = memberMap[tx.recordedBy];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TxRow(
                  type: tx.type,
                  categoryName: cat?.name ?? tx.type,
                  categoryIconKey: cat?.icon ?? 'payments',
                  categoryHue: cat?.hue ?? 162,
                  recorderInitial:
                      recorder?.name.isNotEmpty == true ? recorder!.name[0] : '?',
                  recorderHue: recorder?.avatarHue ?? 162,
                  title: tx.note ?? 'Pembayaran',
                  walletName: wallet?.name ?? '-',
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


