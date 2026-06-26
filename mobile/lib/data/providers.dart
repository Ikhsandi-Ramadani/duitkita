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
import 'repositories/notification_repository.dart';
import 'sync/sync_service.dart';
import '../core/services/update_service.dart';

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Async provider that seeds the DB only when no auth token exists (demo mode).
final dbReadyProvider = FutureProvider<AppDatabase>((ref) async {
  final db = ref.watch(dbProvider);
  final storage = ref.watch(secureStorageProvider);
  final token = await storage.read(key: 'auth_token');
  if (token == null) {
    // No token = not logged in, seed demo data for unauthenticated preview
    await seedIfEmpty(db);
  }
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

final notificationRepoProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(dbProvider));
});

// ---------------------------------------------------------------------------
// SyncService
// ---------------------------------------------------------------------------

final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService(ref.watch(apiClientProvider).dio);
});

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
    notifRepo: ref.watch(notificationRepoProvider),
  );
});

// ---------------------------------------------------------------------------
// Reactive data streams
// ---------------------------------------------------------------------------

/// Current authenticated user id (from SessionKv).
final currentUserIdProvider = StreamProvider<int?>((ref) {
  return ref.watch(sessionRepoProvider).watchCurrentUserId();
});

/// Household invite code (from SessionKv). Null while not yet loaded.
final inviteCodeProvider = StreamProvider<String?>((ref) {
  return ref.watch(sessionRepoProvider).watchInviteCode();
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

// ---------------------------------------------------------------------------
// Member actions
// ---------------------------------------------------------------------------

/// Removes a member by userId: calls the API then deletes from local DB.
/// Usage: await ref.read(removeMemberProvider)(userId);
final removeMemberProvider = Provider<Future<void> Function(int)>((ref) {
  return (int userId) async {
    await ref.read(apiClientProvider).removeMember(userId);
    await ref.read(memberRepoProvider).deleteById(userId);
  };
});

// ---------------------------------------------------------------------------
// Notification providers
// ---------------------------------------------------------------------------

/// All notifications ordered by createdAt desc.
final notificationsProvider = StreamProvider<List<Notification>>((ref) {
  return ref.watch(notificationRepoProvider).watchAll();
});

/// Live unread notification count (stream, updates instantly on read/new).
final unreadNotifCountProvider = StreamProvider<int>((ref) {
  return ref.watch(notificationRepoProvider).watchUnreadCount();
});
