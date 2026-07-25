import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/format.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/transaction_repository.dart'
    show MonthlyTotal;

// ---------------------------------------------------------------------------
// Session helpers
// ---------------------------------------------------------------------------

final balanceHiddenProvider = StreamProvider<bool>((ref) {
  return ref
      .watch(sessionRepoProvider)
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

/// Total income vs expense for the current month, for the homepage
/// income/expense row.
final monthlyIncomeExpenseProvider = FutureProvider<MonthlyTotal>((ref) async {
  final month = ref.watch(currentMonthProvider);
  ref.watch(recentTransactionsProvider);
  final txRepo = ref.watch(transactionRepoProvider);
  return txRepo.monthlyTotals(month);
});

final budgetSummaryProvider = FutureProvider<BudgetSummary>((ref) async {
  final month = ref.watch(currentMonthProvider);
  ref.watch(recentTransactionsProvider);
  final budgets = ref.watch(budgetsByMonthProvider(month)).value ?? [];
  final totalBudget = budgets.fold(0, (sum, b) => sum + b.amount);

  final txRepo = ref.watch(transactionRepoProvider);
  // Only count spending within categories that actually have a budget set —
  // totals.expense is TOTAL household spending across every category, which
  // produced nonsensical percentages (e.g. 524%) when only one category out
  // of many was ever budgeted.
  final catTotals = await txRepo.monthlyExpenseByCategory(month);
  final spentMap = {for (final t in catTotals) t.categoryId: t.total};
  final spentInBudgetedCategories = budgets.fold(
    0,
    (sum, b) => sum + (spentMap[b.categoryId] ?? 0),
  );

  return BudgetSummary(budgeted: totalBudget, spent: spentInBudgetedCategories);
});

class CategoryExpenseSummary {
  const CategoryExpenseSummary({
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.hue,
    required this.total,
  });

  final int categoryId;
  final String name;
  final String icon;
  final int hue;
  final int total;
}

/// Every expense category used in the current month, ordered by spend.
/// Watching recentTransactionsProvider makes this aggregate refresh
/// immediately after a local transaction is added, edited, or deleted.
final monthlyCategoryExpensesProvider =
    FutureProvider<List<CategoryExpenseSummary>>((ref) async {
      final month = ref.watch(currentMonthProvider);
      ref.watch(recentTransactionsProvider);

      final categories = await ref.watch(expenseCategoriesProvider.future);
      final categoryById = {
        for (final category in categories) category.id: category,
      };
      final totals = await ref
          .watch(transactionRepoProvider)
          .monthlyExpenseByCategory(month);

      return totals.map((entry) {
        final category = categoryById[entry.categoryId];
        return CategoryExpenseSummary(
          categoryId: entry.categoryId,
          name: category?.name ?? 'Kategori lainnya',
          icon: category?.icon ?? 'dots',
          hue: category?.hue ?? 24,
          total: entry.total,
        );
      }).toList();
    });

class UpcomingBill {
  const UpcomingBill({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.icon,
    required this.hue,
    required this.autoCreate,
  });

  final int id;
  final String title;
  final int amount;
  final DateTime dueDate;
  final String icon;
  final int hue;
  final bool autoCreate;
}

/// Expense recurrings due from today through the next seven days.
final upcomingBillsProvider = Provider<List<UpcomingBill>>((ref) {
  final recurrings = ref.watch(recurringsProvider).value ?? [];
  final categories = ref.watch(expenseCategoriesProvider).value ?? [];
  final categoryById = {
    for (final category in categories) category.id: category,
  };
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final deadline = today.add(const Duration(days: 7));

  final bills = recurrings
      .where((recurring) {
        final due = DateTime(
          recurring.nextRunDate.year,
          recurring.nextRunDate.month,
          recurring.nextRunDate.day,
        );
        final hasEnded =
            recurring.endDate != null && recurring.endDate!.isBefore(due);
        return recurring.type == 'expense' &&
            !hasEnded &&
            !due.isBefore(today) &&
            !due.isAfter(deadline);
      })
      .map((recurring) {
        final category = categoryById[recurring.categoryId];
        return UpcomingBill(
          id: recurring.id,
          title: recurring.note?.trim().isNotEmpty == true
              ? recurring.note!.trim()
              : category?.name ?? 'Tagihan berulang',
          amount: recurring.amount,
          dueDate: recurring.nextRunDate,
          icon: category?.icon ?? 'calendar',
          hue: category?.hue ?? 24,
          autoCreate: recurring.autoCreate,
        );
      })
      .toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  return bills;
});

enum HomeAttentionKind { danger, warning }

class HomeAttention {
  const HomeAttention({
    required this.kind,
    required this.title,
    required this.detail,
    required this.route,
  });

  final HomeAttentionKind kind;
  final String title;
  final String detail;
  final String route;
}

/// Actionable warnings only: the most urgent budget and debt are shown so
/// Home stays useful without turning into another reports screen.
final homeAttentionProvider = FutureProvider<List<HomeAttention>>((ref) async {
  final month = ref.watch(currentMonthProvider);
  final budgets = ref.watch(budgetsByMonthProvider(month)).value ?? [];
  final debts = ref.watch(debtsProvider).value ?? [];
  final expenses = await ref.watch(monthlyCategoryExpensesProvider.future);
  final spentByCategory = {
    for (final expense in expenses) expense.categoryId: expense,
  };
  final items = <HomeAttention>[];

  final watchedBudgets = budgets
      .where((budget) => budget.amount > 0)
      .map((budget) {
        final expense = spentByCategory[budget.categoryId];
        final spent = expense?.total ?? 0;
        return (
          name: expense?.name ?? 'Kategori',
          spent: spent,
          budget: budget.amount,
          fraction: spent / budget.amount,
        );
      })
      .where((entry) => entry.fraction >= 0.8)
      .toList()
    ..sort((a, b) => b.fraction.compareTo(a.fraction));

  if (watchedBudgets.isNotEmpty) {
    final budget = watchedBudgets.first;
    final percent = (budget.fraction * 100).round();
    final over = budget.fraction > 1;
    items.add(
      HomeAttention(
        kind: over ? HomeAttentionKind.danger : HomeAttentionKind.warning,
        title: over
            ? 'Anggaran ${budget.name} terlampaui'
            : 'Anggaran ${budget.name} hampir habis',
        detail: over
            ? '${fmtShort(budget.spent - budget.budget)} di atas batas'
            : '$percent% sudah terpakai bulan ini',
        route: '/budget',
      ),
    );
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final deadline = today.add(const Duration(days: 7));
  final dueDebts = debts
      .where(
        (debt) =>
            debt.type == 'payable' &&
            debt.status != 'paid' &&
            !debt.deleted &&
            debt.dueDate != null &&
            !debt.dueDate!.isAfter(deadline),
      )
      .toList()
    ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

  if (dueDebts.isNotEmpty) {
    final debt = dueDebts.first;
    final due = DateTime(
      debt.dueDate!.year,
      debt.dueDate!.month,
      debt.dueDate!.day,
    );
    final overdue = due.isBefore(today);
    final remaining = debt.amount - debt.paid;
    items.add(
      HomeAttention(
        kind: overdue ? HomeAttentionKind.danger : HomeAttentionKind.warning,
        title: overdue
            ? 'Utang ${debt.partyName} sudah jatuh tempo'
            : 'Utang ${debt.partyName} segera jatuh tempo',
        detail: '${fmtShort(remaining)} · ${_attentionDateLabel(due, today)}',
        route: '/debts',
      ),
    );
  }

  return items;
});

String _attentionDateLabel(DateTime due, DateTime today) {
  final days = due.difference(today).inDays;
  if (days < 0) return 'terlambat ${days.abs()} hari';
  if (days == 0) return 'jatuh tempo hari ini';
  return 'jatuh tempo $days hari lagi';
}

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
