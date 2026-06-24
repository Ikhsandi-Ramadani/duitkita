import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../db/app_database.dart';
import 'wallet_repository.dart';

const _uuid = Uuid();

class TransactionFilters {
  const TransactionFilters({
    this.type,
    this.memberId,
    this.search,
    this.walletId,
    this.month,
  });
  final String? type;
  final int? memberId;
  final String? search;
  final int? walletId;
  final String? month; // 'YYYY-MM'
}

class MonthlyTotal {
  const MonthlyTotal({required this.income, required this.expense});
  final int income;
  final int expense;
}

class CategoryTotal {
  const CategoryTotal({required this.categoryId, required this.total});
  final int categoryId;
  final int total;
}

class MemberExpense {
  const MemberExpense({required this.memberId, required this.total});
  final int memberId;
  final int total;
}

class TransactionRepository {
  TransactionRepository(this._db, this._wallets);
  final AppDatabase _db;
  final WalletRepository _wallets;

  // -------------------------------------------------------------------------
  // Mutations (all inside drift transaction)
  // -------------------------------------------------------------------------

  Future<Transaction> addTransaction({
    required String type,
    required int walletId,
    int? targetWalletId,
    int? categoryId,
    required int amount,
    required DateTime date,
    String? note,
    required int recordedBy,
    int? spentBy,
    String? receiptPath,
  }) async {
    final clientId = _uuid.v4();
    final now = DateTime.now();

    await _db.transaction(() async {
      await _db.into(_db.transactions).insert(
        TransactionsCompanion.insert(
          clientId: clientId,
          type: type,
          walletId: walletId,
          targetWalletId: Value(targetWalletId),
          categoryId: Value(categoryId),
          amount: amount,
          date: date,
          note: Value(note),
          recordedBy: recordedBy,
          spentBy: Value(spentBy),
          receiptPath: Value(receiptPath),
          updatedAt: now,
          pendingSync: const Value(true),
        ),
      );
      await _applyBalanceEffect(
        type: type,
        walletId: walletId,
        targetWalletId: targetWalletId,
        amount: amount,
      );
    });

    return (_db.select(_db.transactions)
          ..where((t) => t.clientId.equals(clientId)))
        .getSingle();
  }

  Future<void> updateTransaction({
    required String clientId,
    required String type,
    required int walletId,
    int? targetWalletId,
    int? categoryId,
    required int amount,
    required DateTime date,
    String? note,
    int? spentBy,
    String? receiptPath,
  }) async {
    await _db.transaction(() async {
      final old = await (_db.select(_db.transactions)
            ..where((t) => t.clientId.equals(clientId)))
          .getSingle();

      // Reverse old effect
      await _reverseBalanceEffect(
        type: old.type,
        walletId: old.walletId,
        targetWalletId: old.targetWalletId,
        amount: old.amount,
      );

      // Apply new effect
      await _applyBalanceEffect(
        type: type,
        walletId: walletId,
        targetWalletId: targetWalletId,
        amount: amount,
      );

      await (_db.update(_db.transactions)
            ..where((t) => t.clientId.equals(clientId)))
          .write(TransactionsCompanion(
        type: Value(type),
        walletId: Value(walletId),
        targetWalletId: Value(targetWalletId),
        categoryId: Value(categoryId),
        amount: Value(amount),
        date: Value(date),
        note: Value(note),
        spentBy: Value(spentBy),
        receiptPath: Value(receiptPath),
        updatedAt: Value(DateTime.now()),
        pendingSync: const Value(true),
      ));
    });
  }

  Future<void> deleteTransaction(String clientId) async {
    await _db.transaction(() async {
      final old = await (_db.select(_db.transactions)
            ..where((t) => t.clientId.equals(clientId)))
          .getSingle();

      await _reverseBalanceEffect(
        type: old.type,
        walletId: old.walletId,
        targetWalletId: old.targetWalletId,
        amount: old.amount,
      );

      await (_db.update(_db.transactions)
            ..where((t) => t.clientId.equals(clientId)))
          .write(TransactionsCompanion(
        deleted: const Value(true),
        updatedAt: Value(DateTime.now()),
        pendingSync: const Value(true),
      ));
    });
  }

  // -------------------------------------------------------------------------
  // Balance helpers
  // -------------------------------------------------------------------------

  Future<void> _applyBalanceEffect({
    required String type,
    required int walletId,
    int? targetWalletId,
    required int amount,
  }) async {
    switch (type) {
      case 'income':
        await _wallets.applyBalanceDelta(walletId, amount.abs());
      case 'expense':
        await _wallets.applyBalanceDelta(walletId, -amount.abs());
      case 'transfer':
        await _wallets.applyBalanceDelta(walletId, -amount.abs());
        if (targetWalletId != null) {
          await _wallets.applyBalanceDelta(targetWalletId, amount.abs());
        }
      case 'adjustment':
        // amount is signed
        await _wallets.applyBalanceDelta(walletId, amount);
    }
  }

  Future<void> _reverseBalanceEffect({
    required String type,
    required int walletId,
    int? targetWalletId,
    required int amount,
  }) async {
    switch (type) {
      case 'income':
        await _wallets.applyBalanceDelta(walletId, -amount.abs());
      case 'expense':
        await _wallets.applyBalanceDelta(walletId, amount.abs());
      case 'transfer':
        await _wallets.applyBalanceDelta(walletId, amount.abs());
        if (targetWalletId != null) {
          await _wallets.applyBalanceDelta(targetWalletId, -amount.abs());
        }
      case 'adjustment':
        await _wallets.applyBalanceDelta(walletId, -amount);
    }
  }

  // -------------------------------------------------------------------------
  // Queries
  // -------------------------------------------------------------------------

  Stream<Map<DateTime, List<Transaction>>> watchGroupedByDate(
      TransactionFilters filters) {
    final query = _db.select(_db.transactions)
      ..where((t) => t.deleted.equals(false));

    if (filters.type != null) {
      query.where((t) => t.type.equals(filters.type!));
    }
    if (filters.memberId != null) {
      query.where((t) =>
          t.recordedBy.equals(filters.memberId!) |
          t.spentBy.equalsNullable(filters.memberId));
    }
    if (filters.walletId != null) {
      query.where((t) => t.walletId.equals(filters.walletId!));
    }
    if (filters.month != null) {
      // filter by YYYY-MM prefix using date range
      final parts = filters.month!.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final start = DateTime(year, month, 1);
      final end = DateTime(year, month + 1, 1);
      query.where((t) =>
          t.date.isBiggerOrEqualValue(start) &
          t.date.isSmallerThanValue(end));
    }

    query.orderBy([(t) => OrderingTerm.desc(t.date)]);

    return query.watch().map((rows) {
      final grouped = <DateTime, List<Transaction>>{};
      for (final row in rows) {
        if (filters.search != null && filters.search!.isNotEmpty) {
          final q = filters.search!.toLowerCase();
          if (!(row.note ?? '').toLowerCase().contains(q)) continue;
        }
        final day = DateTime(row.date.year, row.date.month, row.date.day);
        grouped.putIfAbsent(day, () => []).add(row);
      }
      return grouped;
    });
  }

  Stream<List<Transaction>> watchRecent(int n) {
    return (_db.select(_db.transactions)
          ..where((t) => t.deleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(n))
        .watch();
  }

  Stream<List<Transaction>> watchByWallet(int walletId) {
    return (_db.select(_db.transactions)
          ..where((t) =>
              t.deleted.equals(false) &
              (t.walletId.equals(walletId) |
                  t.targetWalletId.equalsNullable(walletId)))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<List<CategoryTotal>> monthlyExpenseByCategory(String month) async {
    final parts = month.split('-');
    final year = int.parse(parts[0]);
    final mon = int.parse(parts[1]);
    final start = DateTime(year, mon, 1);
    final end = DateTime(year, mon + 1, 1);

    final rows = await (_db.select(_db.transactions)
          ..where((t) =>
              t.deleted.equals(false) &
              t.type.equals('expense') &
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerThanValue(end) &
              t.categoryId.isNotNull()))
        .get();

    final totals = <int, int>{};
    for (final r in rows) {
      final cid = r.categoryId!;
      totals[cid] = (totals[cid] ?? 0) + r.amount.abs();
    }
    return totals.entries
        .map((e) => CategoryTotal(categoryId: e.key, total: e.value))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));
  }

  Future<MonthlyTotal> monthlyTotals(String month) async {
    final parts = month.split('-');
    final year = int.parse(parts[0]);
    final mon = int.parse(parts[1]);
    final start = DateTime(year, mon, 1);
    final end = DateTime(year, mon + 1, 1);

    final rows = await (_db.select(_db.transactions)
          ..where((t) =>
              t.deleted.equals(false) &
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerThanValue(end) &
              t.type.isIn(['income', 'expense'])))
        .get();

    int income = 0;
    int expense = 0;
    for (final r in rows) {
      if (r.type == 'income') income += r.amount.abs();
      if (r.type == 'expense') expense += r.amount.abs();
    }
    return MonthlyTotal(income: income, expense: expense);
  }

  Future<List<MemberExpense>> monthlyExpenseByMember(String month) async {
    final parts = month.split('-');
    final year = int.parse(parts[0]);
    final mon = int.parse(parts[1]);
    final start = DateTime(year, mon, 1);
    final end = DateTime(year, mon + 1, 1);

    final rows = await (_db.select(_db.transactions)
          ..where((t) =>
              t.deleted.equals(false) &
              t.type.equals('expense') &
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerThanValue(end)))
        .get();

    final totals = <int, int>{};
    for (final r in rows) {
      final memberId = r.spentBy ?? r.recordedBy;
      totals[memberId] = (totals[memberId] ?? 0) + r.amount.abs();
    }
    return totals.entries
        .map((e) => MemberExpense(memberId: e.key, total: e.value))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));
  }

  Future<List<Transaction>> getPendingSync() {
    return (_db.select(_db.transactions)
          ..where((t) => t.pendingSync.equals(true)))
        .get();
  }

  Future<void> markSynced(String clientId, int serverId) async {
    await (_db.update(_db.transactions)
          ..where((t) => t.clientId.equals(clientId)))
        .write(TransactionsCompanion(
      serverId: Value(serverId),
      pendingSync: const Value(false),
    ));
  }

  Future<void> upsertFromServer(TransactionsCompanion companion) async {
    await _db.into(_db.transactions).insertOnConflictUpdate(companion);
  }

  /// Persists a receipt path returned by the server into the local DB row.
  Future<void> updateReceiptPath(String clientId, String path) async {
    await (_db.update(_db.transactions)
          ..where((t) => t.clientId.equals(clientId)))
        .write(TransactionsCompanion(
      receiptPath: Value(path),
      updatedAt: Value(DateTime.now()),
    ));
  }
}
