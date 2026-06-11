import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'db/app_database.dart';
import 'db/seed.dart';
import 'api/api_client.dart';
import 'repositories/session_repository.dart';
import 'repositories/member_repository.dart';
import 'repositories/wallet_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/transaction_repository.dart';
import 'repositories/budget_repository.dart';
import 'repositories/goal_repository.dart';
import 'repositories/debt_repository.dart';
import 'repositories/recurring_repository.dart';
import 'sync/sync_service.dart';

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Async provider that seeds the DB on first open, then returns the db.
final dbReadyProvider = FutureProvider<AppDatabase>((ref) async {
  final db = ref.watch(dbProvider);
  await seedIfEmpty(db);
  return db;
});

// ---------------------------------------------------------------------------
// Secure storage / API
// ---------------------------------------------------------------------------

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage: storage);
});

// ---------------------------------------------------------------------------
// Repositories
// ---------------------------------------------------------------------------

final sessionRepoProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(ref.watch(dbProvider));
});

final memberRepoProvider = Provider<MemberRepository>((ref) {
  return MemberRepository(ref.watch(dbProvider));
});

final walletRepoProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.watch(dbProvider));
});

final categoryRepoProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(dbProvider));
});

final transactionRepoProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(
    ref.watch(dbProvider),
    ref.watch(walletRepoProvider),
  );
});

final budgetRepoProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(ref.watch(dbProvider));
});

final goalRepoProvider = Provider<GoalRepository>((ref) {
  return GoalRepository(
    ref.watch(dbProvider),
    ref.watch(transactionRepoProvider),
  );
});

final debtRepoProvider = Provider<DebtRepository>((ref) {
  return DebtRepository(
    ref.watch(dbProvider),
    ref.watch(transactionRepoProvider),
  );
});

final recurringRepoProvider = Provider<RecurringRepository>((ref) {
  return RecurringRepository(ref.watch(dbProvider));
});

// ---------------------------------------------------------------------------
// SyncService
// ---------------------------------------------------------------------------

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    api: ref.watch(apiClientProvider),
    txRepo: ref.watch(transactionRepoProvider),
    walletRepo: ref.watch(walletRepoProvider),
    categoryRepo: ref.watch(categoryRepoProvider),
    budgetRepo: ref.watch(budgetRepoProvider),
    goalRepo: ref.watch(goalRepoProvider),
    debtRepo: ref.watch(debtRepoProvider),
    recurringRepo: ref.watch(recurringRepoProvider),
    memberRepo: ref.watch(memberRepoProvider),
    sessionRepo: ref.watch(sessionRepoProvider),
  );
});

// ---------------------------------------------------------------------------
// Reactive data streams
// ---------------------------------------------------------------------------

/// Current authenticated user id (from SessionKv).
final currentUserIdProvider = StreamProvider<int?>((ref) {
  return ref.watch(sessionRepoProvider).watchCurrentUserId();
});

/// All non-deleted members.
final membersProvider = StreamProvider<List<Member>>((ref) {
  return ref.watch(memberRepoProvider).watchAll();
});

/// All non-deleted wallets.
final walletsProvider = StreamProvider<List<Wallet>>((ref) {
  return ref.watch(walletRepoProvider).watchAll();
});

/// All categories.
final categoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryRepoProvider).watchAll();
});

/// Expense categories only.
final expenseCategoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryRepoProvider).watchByType('expense');
});

/// Income categories only.
final incomeCategoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryRepoProvider).watchByType('income');
});

/// Recent 20 transactions.
final recentTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  return ref.watch(transactionRepoProvider).watchRecent(20);
});

/// Budgets for a given month.
final budgetsByMonthProvider =
    StreamProvider.family<List<Budget>, String>((ref, month) {
  return ref.watch(budgetRepoProvider).watchByMonth(month);
});

/// All savings goals.
final goalsProvider = StreamProvider<List<SavingsGoal>>((ref) {
  return ref.watch(goalRepoProvider).watchAll();
});

/// All debts.
final debtsProvider = StreamProvider<List<Debt>>((ref) {
  return ref.watch(debtRepoProvider).watchAll();
});

/// All recurrings.
final recurringsProvider = StreamProvider<List<Recurring>>((ref) {
  return ref.watch(recurringRepoProvider).watchAll();
});

/// Transactions by wallet.
final txByWalletProvider =
    StreamProvider.family<List<Transaction>, int>((ref, walletId) {
  return ref.watch(transactionRepoProvider).watchByWallet(walletId);
});

/// Transactions grouped by date with optional filters.
final txGroupedProvider = StreamProvider.family<
    Map<DateTime, List<Transaction>>, TransactionFilters>((ref, filters) {
  return ref.watch(transactionRepoProvider).watchGroupedByDate(filters);
});
