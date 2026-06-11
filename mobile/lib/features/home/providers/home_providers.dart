import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers.dart';

// ---------------------------------------------------------------------------
// Session helpers
// ---------------------------------------------------------------------------

final balanceHiddenProvider = StreamProvider<bool>((ref) {
  return ref.watch(sessionRepoProvider)
      .watch('balanceHidden')
      .map((v) => v == 'true');
});

final householdNameProvider = FutureProvider<String>((ref) async {
  return (await ref.watch(sessionRepoProvider).get('householdName')) ??
      'Keluarga';
});

// ---------------------------------------------------------------------------
// Balance aggregates derived from wallet stream
// ---------------------------------------------------------------------------

final totalWealthProvider = Provider<int>((ref) {
  final wallets = ref.watch(walletsProvider).value ?? [];
  return wallets.fold(0, (sum, w) => sum + w.currentBalance);
});

final myBalanceProvider = Provider.family<int, int>((ref, userId) {
  final wallets = ref.watch(walletsProvider).value ?? [];
  return wallets
      .where((w) => w.scope == 'personal' && w.ownerUserId == userId)
      .fold(0, (sum, w) => sum + w.currentBalance);
});

final sharedBalanceProvider = Provider<int>((ref) {
  final wallets = ref.watch(walletsProvider).value ?? [];
  return wallets
      .where((w) => w.scope == 'shared')
      .fold(0, (sum, w) => sum + w.currentBalance);
});

// Budget summary: total budget vs total expense for current month
class BudgetSummary {
  const BudgetSummary({required this.budgeted, required this.spent});
  final int budgeted;
  final int spent;
  double get fraction => budgeted > 0 ? spent / budgeted : 0.0;
}

final currentMonthProvider = Provider<String>((ref) {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}';
});

final budgetSummaryProvider = FutureProvider<BudgetSummary>((ref) async {
  final month = ref.watch(currentMonthProvider);
  final budgets = ref.watch(budgetsByMonthProvider(month)).value ?? [];
  final totalBudget = budgets.fold(0, (sum, b) => sum + b.amount);

  final txRepo = ref.watch(transactionRepoProvider);
  final totals = await txRepo.monthlyTotals(month);

  return BudgetSummary(budgeted: totalBudget, spent: totals.expense);
});

// Goals total collected
final goalsTotalProvider = Provider<int>((ref) {
  final goals = ref.watch(goalsProvider).value ?? [];
  return goals.fold(0, (sum, g) => sum + g.currentAmount);
});

// Debts summary
class DebtSummary {
  const DebtSummary({required this.payable, required this.receivable});
  final int payable;
  final int receivable;
}

final debtSummaryProvider = Provider<DebtSummary>((ref) {
  final debts = ref.watch(debtsProvider).value ?? [];
  final payable = debts
      .where((d) => d.type == 'payable' && d.status != 'paid')
      .fold(0, (sum, d) => sum + (d.amount - d.paid));
  final receivable = debts
      .where((d) => d.type == 'receivable' && d.status != 'paid')
      .fold(0, (sum, d) => sum + (d.amount - d.paid));
  return DebtSummary(payable: payable, receivable: receivable);
});

// Recent 5 transactions
final recent5Provider = Provider<List<dynamic>>((ref) {
  final all = ref.watch(recentTransactionsProvider).value ?? [];
  return all.take(5).toList();
});
