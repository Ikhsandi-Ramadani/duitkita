import 'package:drift/drift.dart';
import '../api/api_client.dart';
import '../db/app_database.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/wallet_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/budget_repository.dart';
import '../repositories/goal_repository.dart';
import '../repositories/debt_repository.dart';
import '../repositories/recurring_repository.dart';
import '../repositories/member_repository.dart';
import '../repositories/session_repository.dart';
import '../repositories/notification_repository.dart';

class SyncService {
  SyncService({
    required this.api,
    required this.txRepo,
    required this.walletRepo,
    required this.categoryRepo,
    required this.budgetRepo,
    required this.goalRepo,
    required this.debtRepo,
    required this.recurringRepo,
    required this.memberRepo,
    required this.sessionRepo,
    required this.notifRepo,
  });

  final ApiClient api;
  final TransactionRepository txRepo;
  final WalletRepository walletRepo;
  final CategoryRepository categoryRepo;
  final BudgetRepository budgetRepo;
  final GoalRepository goalRepo;
  final DebtRepository debtRepo;
  final RecurringRepository recurringRepo;
  final MemberRepository memberRepo;
  final SessionRepository sessionRepo;
  final NotificationRepository notifRepo;

  /// Push all pending (pendingSync=true) transactions to the server.
  Future<void> pushPending() async {
    final pending = await txRepo.getPendingSync();
    if (pending.isEmpty) return;

    final payload = pending
        .map((t) => {
              'client_id': t.clientId,
              'type': t.type,
              'wallet_id': t.walletId,
              'target_wallet_id': t.targetWalletId,
              'category_id': t.categoryId,
              'amount': t.amount,
              'date': t.date.toIso8601String(),
              'note': t.note,
              'recorded_by': t.recordedBy,
              'spent_by': t.spentBy,
              'updated_at': t.updatedAt.toIso8601String(),
              'deleted': t.deleted,
            })
        .toList();

    final result = await api.pushTransactions(payload);

    // Server returns synced list with server IDs
    final synced = (result['synced'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    for (final s in synced) {
      await txRepo.markSynced(
        s['client_id'] as String,
        s['server_id'] as int,
      );
    }
  }

  /// Pull all entity updates from server since [lastSyncAt].
  Future<void> pull() async {
    final lastSyncStr = await sessionRepo.get('lastSyncAt') ?? '0';
    final lastSync = int.tryParse(lastSyncStr) ?? 0;

    final data = await api.pullSince(lastSync);
    await _upsertAll(data);

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    await sessionRepo.set('lastSyncAt', nowMs.toString());
  }

  /// Full initial pull: fetch /me + /sync?since=0.
  Future<void> initialPull() async {
    final data = await api.initialPull();
    final syncData = data['sync'] as Map<String, dynamic>;
    await _upsertAll(syncData);

    final meData = data['me'] as Map<String, dynamic>;
    final userId = meData['id'] as int?;
    if (userId != null) {
      await sessionRepo.setCurrentUserId(userId);
    }

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    await sessionRepo.set('lastSyncAt', nowMs.toString());
  }

  Future<void> _upsertAll(Map<String, dynamic> data) async {
    // Members
    if (data['members'] != null) {
      final members = (data['members'] as List).cast<Map<String, dynamic>>();
      await memberRepo.upsertAll(members
          .map((m) => MembersCompanion(
                id: Value(m['id'] as int),
                name: Value(m['name'] as String),
                email: Value(m['email'] as String),
                role: Value(m['role'] as String),
                avatarHue: Value(m['avatar_hue'] as int? ?? 162),
              ))
          .toList());
    }

    // Wallets
    if (data['wallets'] != null) {
      final wallets = (data['wallets'] as List).cast<Map<String, dynamic>>();
      await walletRepo.upsertAll(wallets
          .map((w) => WalletsCompanion(
                id: Value(w['id'] as int),
                scope: Value(w['scope'] as String),
                ownerUserId: Value(w['owner_user_id'] as int?),
                name: Value(w['name'] as String),
                type: Value(w['type'] as String),
                icon: Value(w['icon'] as String?),
                initialBalance: Value(w['initial_balance'] as int),
                currentBalance: Value(w['current_balance'] as int),
                deleted: Value((w['deleted'] as bool?) ?? false),
              ))
          .toList());
    }

    // Categories
    if (data['categories'] != null) {
      final cats = (data['categories'] as List).cast<Map<String, dynamic>>();
      await categoryRepo.upsertAll(cats
          .map((c) => CategoriesCompanion(
                id: Value(c['id'] as int),
                name: Value(c['name'] as String),
                type: Value(c['type'] as String),
                icon: Value(c['icon'] as String),
                hue: Value(c['hue'] as int),
                parentId: Value(c['parent_id'] as int?),
              ))
          .toList());
    }

    // Transactions
    if (data['transactions'] != null) {
      final txs = (data['transactions'] as List).cast<Map<String, dynamic>>();
      for (final t in txs) {
        await txRepo.upsertFromServer(TransactionsCompanion(
          clientId: Value(t['client_id'] as String),
          serverId: Value(t['id'] as int?),
          type: Value(t['type'] as String),
          walletId: Value(t['wallet_id'] as int),
          targetWalletId: Value(t['target_wallet_id'] as int?),
          categoryId: Value(t['category_id'] as int?),
          amount: Value(t['amount'] as int),
          date: Value(DateTime.parse(t['date'] as String)),
          note: Value(t['note'] as String?),
          recordedBy: Value(t['recorded_by'] as int),
          spentBy: Value(t['spent_by'] as int?),
          receiptPath: Value(t['receipt_path'] as String?),
          updatedAt: Value(DateTime.parse(t['updated_at'] as String)),
          deleted: Value((t['deleted'] as bool?) ?? false),
          pendingSync: const Value(false),
        ));
      }
    }

    // Budgets
    if (data['budgets'] != null) {
      final budgets = (data['budgets'] as List).cast<Map<String, dynamic>>();
      await budgetRepo.upsertAll(budgets
          .map((b) => BudgetsCompanion(
                id: Value(b['id'] as int),
                scope: Value(b['scope'] as String),
                ownerUserId: Value(b['owner_user_id'] as int?),
                categoryId: Value(b['category_id'] as int),
                amount: Value(b['amount'] as int),
                periodMonth: Value(b['period_month'] as String),
              ))
          .toList());
    }

    // SavingsGoals
    if (data['savings_goals'] != null) {
      final goals =
          (data['savings_goals'] as List).cast<Map<String, dynamic>>();
      await goalRepo.upsertAll(goals
          .map((g) => SavingsGoalsCompanion(
                id: Value(g['id'] as int),
                scope: Value(g['scope'] as String),
                ownerUserId: Value(g['owner_user_id'] as int?),
                name: Value(g['name'] as String),
                targetAmount: Value(g['target_amount'] as int),
                currentAmount: Value(g['current_amount'] as int),
                targetDate: Value(g['target_date'] != null
                    ? DateTime.parse(g['target_date'] as String)
                    : null),
                walletId: Value(g['wallet_id'] as int),
                icon: Value(g['icon'] as String),
                hue: Value(g['hue'] as int),
                deleted: Value((g['deleted'] as bool?) ?? false),
              ))
          .toList());
    }

    // Debts
    if (data['debts'] != null) {
      final debts = (data['debts'] as List).cast<Map<String, dynamic>>();
      await debtRepo.upsertAll(debts
          .map((d) => DebtsCompanion(
                id: Value(d['id'] as int),
                ownerUserId: Value(d['owner_user_id'] as int?),
                type: Value(d['type'] as String),
                partyName: Value(d['party_name'] as String),
                amount: Value(d['amount'] as int),
                paid: Value(d['paid'] as int),
                date: Value(DateTime.parse(d['date'] as String)),
                dueDate: Value(d['due_date'] != null
                    ? DateTime.parse(d['due_date'] as String)
                    : null),
                status: Value(d['status'] as String),
                note: Value(d['note'] as String?),
                walletId: Value(d['wallet_id'] as int?),
                deleted: Value((d['deleted'] as bool?) ?? false),
              ))
          .toList());
    }

    // Recurrings
    if (data['recurrings'] != null) {
      final recs = (data['recurrings'] as List).cast<Map<String, dynamic>>();
      await recurringRepo.upsertAll(recs
          .map((r) => RecurringsCompanion(
                id: Value(r['id'] as int),
                type: Value(r['type'] as String),
                walletId: Value(r['wallet_id'] as int),
                categoryId: Value(r['category_id'] as int),
                amount: Value(r['amount'] as int),
                freq: Value(r['freq'] as String),
                nextRunDate: Value(DateTime.parse(r['next_run_date'] as String)),
                endDate: Value(r['end_date'] != null
                    ? DateTime.parse(r['end_date'] as String)
                    : null),
                autoCreate: Value(r['auto_create'] as bool),
                note: Value(r['note'] as String?),
                createdBy: Value(r['created_by'] as int),
              ))
          .toList());
    }

    // Notifications
    if (data['notifications'] != null) {
      await notifRepo.upsertAll(
        (data['notifications'] as List).cast<Map<String, dynamic>>(),
      );
    }
  }
}
