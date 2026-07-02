import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' hide Category;
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

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v.toString()) ?? 0;
  }

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
              'date': t.date.toUtc().toIso8601String(),
              'note': t.note,
              'recorded_by': t.recordedBy,
              'spent_by': t.spentBy,
              'updated_at': t.updatedAt.toUtc().toIso8601String(),
              'deleted': t.deleted,
            })
        .toList();

    try {
      final result = await api.pushTransactions(payload);

      // Server returns {'results': [{'client_id', 'status', 'id'}, ...]}
      final results = (result['results'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      for (final r in results) {
        await txRepo.markSynced(
          r['client_id'] as String,
          r['id'] as int,
        );
      }
    } catch (e) {
      if (kDebugMode) print('[Sync] pushTransactions error: $e');
    }
  }

  /// Push all pending (pendingSync=true) debts to the server.
  Future<void> pushPendingDebts() async {
    final pending = await debtRepo.getPendingSync();
    for (final d in pending) {
      try {
        final result = await api.createDebt({
          'type': d.type,
          'party_name': d.partyName,
          'amount': d.amount,
          'date': d.date.toUtc().toIso8601String(),
          'due_date': d.dueDate?.toUtc().toIso8601String(),
          'note': d.note,
          'wallet_id': d.walletId,
        });
        final serverId = result['id'] as int?;
        if (serverId != null) {
          await debtRepo.replaceWithServerId(d.id, serverId);
        }
      } catch (e) {
        if (kDebugMode) print('[Sync] debt push error (id=${d.id}): $e');
      }
    }
  }

  /// Push all pending (pendingSync=true) recurring rules to the server.
  Future<void> pushPendingRecurrings() async {
    final pending = await recurringRepo.getPendingSync();
    for (final r in pending) {
      try {
        final result = await api.createRecurring({
          'type': r.type,
          'wallet_id': r.walletId,
          'category_id': r.categoryId,
          'amount': r.amount,
          'freq': r.freq,
          'next_run_date': r.nextRunDate.toUtc().toIso8601String(),
          'end_date': r.endDate?.toUtc().toIso8601String(),
          'auto_create': r.autoCreate,
          'note': r.note,
        });
        final serverId = result['id'] as int?;
        if (serverId != null) {
          await recurringRepo.replaceWithServerId(r.id, serverId);
        }
      } catch (e) {
        if (kDebugMode) print('[Sync] recurring push error (id=${r.id}): $e');
      }
    }
  }

  /// Push all pending (pendingSync=true) budgets to the server.
  Future<void> pushPendingBudgets() async {
    final pending = await budgetRepo.getPendingSync();
    for (final b in pending) {
      try {
        final result = await api.createBudget({
          'scope': b.scope,
          'category_id': b.categoryId,
          'amount': b.amount,
          'period_month': b.periodMonth,
        });
        final serverId = result['id'] as int?;
        if (serverId != null) {
          await budgetRepo.replaceWithServerId(b.id, serverId);
        }
      } catch (e) {
        if (kDebugMode) print('[Sync] budget push error (id=${b.id}): $e');
      }
    }
  }

  /// Best-effort push of every locally-created entity not yet on the server.
  Future<void> pushAllPending() async {
    await pushPending();
    await pushPendingDebts();
    await pushPendingRecurrings();
    await pushPendingBudgets();
  }

  /// True if any entity still has unsynced local writes.
  Future<bool> hasPendingSync() async {
    final tx = await txRepo.getPendingSync();
    if (tx.isNotEmpty) return true;
    final debts = await debtRepo.getPendingSync();
    if (debts.isNotEmpty) return true;
    final recs = await recurringRepo.getPendingSync();
    if (recs.isNotEmpty) return true;
    final budgets = await budgetRepo.getPendingSync();
    return budgets.isNotEmpty;
  }

  /// Pull all entity updates from server since [lastSyncAt].
  Future<void> pull() async {
    final lastSyncStr = await sessionRepo.get('lastSyncAt') ?? '0';
    final lastSync = int.tryParse(lastSyncStr) ?? 0;

    final data = await api.pullSince(lastSync);
    await _upsertAll(data);
    await _recordSyncTime(data);
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

    await _recordSyncTime(syncData);
  }

  /// Records the server's clock (not the device's) as the sync watermark,
  /// avoiding skipped records from device clock skew.
  Future<void> _recordSyncTime(Map<String, dynamic> data) async {
    final serverTimeStr = data['server_time'] as String?;
    final ms = serverTimeStr != null
        ? DateTime.parse(serverTimeStr).millisecondsSinceEpoch
        : DateTime.now().millisecondsSinceEpoch;
    await sessionRepo.set('lastSyncAt', ms.toString());
  }

  Future<void> _upsertAll(Map<String, dynamic> data) async {
    // Members
    if (data['members'] != null) {
      try {
        final members = (data['members'] as List).cast<Map<String, dynamic>>();
        await memberRepo.upsertAll(members
            .map((m) => MembersCompanion(
                  id: Value(_toInt(m['id'])),
                  name: Value((m['name'] as String?) ?? ''),
                  email: Value((m['email'] as String?) ?? ''),
                  role: Value((m['role'] as String?) ?? 'member'),
                  avatarHue: Value((m['avatar_hue'] as int?) ?? 162),
                  phone: Value(m['phone'] as String?),
                  avatarPath: Value(m['avatar_path'] as String?),
                ))
            .toList());
      } catch (e) {
        if (kDebugMode) print('[Sync] member upsert error: $e');
      }
    }

    // Wallets
    if (data['wallets'] != null) {
      try {
        final wallets = (data['wallets'] as List).cast<Map<String, dynamic>>();
        await walletRepo.upsertAll(wallets
            .map((w) => WalletsCompanion(
                  id: Value(_toInt(w['id'])),
                  scope: Value((w['scope'] as String?) ?? 'household'),
                  ownerUserId: Value(w['owner_user_id'] as int?),
                  name: Value((w['name'] as String?) ?? ''),
                  type: Value((w['type'] as String?) ?? 'cash'),
                  icon: Value(w['icon'] as String?),
                  initialBalance: Value(_toInt(w['initial_balance'])),
                  currentBalance: Value(_toInt(w['current_balance'])),
                  deleted: Value((w['deleted'] as bool?) ?? false),
                ))
            .toList());
      } catch (e) {
        if (kDebugMode) print('[Sync] wallet upsert error: $e');
      }
    }

    // Categories
    if (data['categories'] != null) {
      try {
        final cats = (data['categories'] as List).cast<Map<String, dynamic>>();
        await categoryRepo.upsertAll(cats
            .map((c) => CategoriesCompanion(
                  id: Value(_toInt(c['id'])),
                  name: Value((c['name'] as String?) ?? ''),
                  type: Value((c['type'] as String?) ?? 'expense'),
                  icon: Value((c['icon'] as String?) ?? ''),
                  hue: Value(_toInt(c['hue'])),
                  parentId: Value(c['parent_id'] as int?),
                ))
            .toList());
      } catch (e) {
        if (kDebugMode) print('[Sync] category upsert error: $e');
      }
    }

    // Transactions
    if (data['transactions'] != null) {
      try {
        final txs = (data['transactions'] as List).cast<Map<String, dynamic>>();
        for (final t in txs) {
          try {
            await txRepo.upsertFromServer(TransactionsCompanion(
              clientId: Value((t['client_id'] as String?) ?? ''),
              serverId: Value(t['id'] as int?),
              type: Value((t['type'] as String?) ?? 'expense'),
              walletId: Value(_toInt(t['wallet_id'])),
              targetWalletId: Value(t['target_wallet_id'] as int?),
              categoryId: Value(t['category_id'] as int?),
              amount: Value(_toInt(t['amount'])),
              date: Value(DateTime.parse((t['date'] as String?) ?? DateTime.now().toIso8601String()).toLocal()),
              note: Value(t['note'] as String?),
              recordedBy: Value(_toInt(t['recorded_by'])),
              spentBy: Value(t['spent_by'] as int?),
              receiptPath: Value(t['receipt_path'] as String?),
              updatedAt: Value(DateTime.parse((t['updated_at'] as String?) ?? DateTime.now().toIso8601String()).toLocal()),
              deleted: Value((t['deleted'] as bool?) ?? false),
              pendingSync: const Value(false),
            ));
          } catch (e) {
            if (kDebugMode) print('[Sync] transaction upsert error (id=${t['id']}): $e');
          }
        }
      } catch (e) {
        if (kDebugMode) print('[Sync] transactions block error: $e');
      }
    }

    // Budgets
    if (data['budgets'] != null) {
      try {
        final budgets = (data['budgets'] as List).cast<Map<String, dynamic>>();
        await budgetRepo.upsertAll(budgets
            .map((b) => BudgetsCompanion(
                  id: Value(_toInt(b['id'])),
                  scope: Value((b['scope'] as String?) ?? 'household'),
                  ownerUserId: Value(b['owner_user_id'] as int?),
                  categoryId: Value(_toInt(b['category_id'])),
                  amount: Value(_toInt(b['amount'])),
                  periodMonth: Value((b['period_month'] as String?) ?? ''),
                  pendingSync: const Value(false),
                ))
            .toList());
      } catch (e) {
        if (kDebugMode) print('[Sync] budget upsert error: $e');
      }
    }

    // SavingsGoals
    if (data['savings_goals'] != null) {
      try {
        final goals =
            (data['savings_goals'] as List).cast<Map<String, dynamic>>();
        await goalRepo.upsertAll(goals
            .map((g) => SavingsGoalsCompanion(
                  id: Value(_toInt(g['id'])),
                  scope: Value((g['scope'] as String?) ?? 'household'),
                  ownerUserId: Value(g['owner_user_id'] as int?),
                  name: Value((g['name'] as String?) ?? ''),
                  targetAmount: Value(_toInt(g['target_amount'])),
                  currentAmount: Value(_toInt(g['current_amount'])),
                  targetDate: Value(g['target_date'] != null
                      ? DateTime.parse(g['target_date'] as String).toLocal()
                      : null),
                  walletId: Value(_toInt(g['wallet_id'])),
                  icon: Value((g['icon'] as String?) ?? ''),
                  hue: Value(_toInt(g['hue'])),
                  deleted: Value((g['deleted'] as bool?) ?? false),
                ))
            .toList());
      } catch (e) {
        if (kDebugMode) print('[Sync] savings_goal upsert error: $e');
      }
    }

    // Debts
    if (data['debts'] != null) {
      try {
        final debts = (data['debts'] as List).cast<Map<String, dynamic>>();
        await debtRepo.upsertAll(debts
            .map((d) => DebtsCompanion(
                  id: Value(_toInt(d['id'])),
                  ownerUserId: Value(d['owner_user_id'] as int?),
                  type: Value((d['type'] as String?) ?? 'receivable'),
                  partyName: Value((d['party_name'] as String?) ?? ''),
                  amount: Value(_toInt(d['amount'])),
                  paid: Value(_toInt(d['paid'])),
                  date: Value(DateTime.parse((d['date'] as String?) ?? DateTime.now().toIso8601String()).toLocal()),
                  dueDate: Value(d['due_date'] != null
                      ? DateTime.parse(d['due_date'] as String).toLocal()
                      : null),
                  status: Value((d['status'] as String?) ?? 'ongoing'),
                  note: Value(d['note'] as String?),
                  walletId: Value(d['wallet_id'] as int?),
                  deleted: Value((d['deleted'] as bool?) ?? false),
                  pendingSync: const Value(false),
                ))
            .toList());
      } catch (e) {
        if (kDebugMode) print('[Sync] debt upsert error: $e');
      }
    }

    // Recurrings
    if (data['recurrings'] != null) {
      try {
        final recs = (data['recurrings'] as List).cast<Map<String, dynamic>>();
        await recurringRepo.upsertAll(recs
            .map((r) => RecurringsCompanion(
                  id: Value(_toInt(r['id'])),
                  type: Value((r['type'] as String?) ?? 'expense'),
                  walletId: Value(_toInt(r['wallet_id'])),
                  categoryId: Value(_toInt(r['category_id'])),
                  amount: Value(_toInt(r['amount'])),
                  freq: Value((r['freq'] as String?) ?? 'monthly'),
                  nextRunDate: Value(DateTime.parse((r['next_run_date'] as String?) ?? DateTime.now().toIso8601String()).toLocal()),
                  endDate: Value(r['end_date'] != null
                      ? DateTime.parse(r['end_date'] as String).toLocal()
                      : null),
                  autoCreate: Value((r['auto_create'] as bool?) ?? false),
                  note: Value(r['note'] as String?),
                  createdBy: Value(_toInt(r['created_by'])),
                  pendingSync: const Value(false),
                ))
            .toList());
      } catch (e) {
        if (kDebugMode) print('[Sync] recurring upsert error: $e');
      }
    }

    // Notifications
    if (data['notifications'] != null) {
      try {
        await notifRepo.upsertAll(
          (data['notifications'] as List).cast<Map<String, dynamic>>(),
        );
      } catch (e) {
        if (kDebugMode) print('[Sync] notification upsert error: $e');
      }
    }
  }
}
