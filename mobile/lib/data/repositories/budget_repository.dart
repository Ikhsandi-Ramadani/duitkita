import 'package:drift/drift.dart';
import '../db/app_database.dart';

class BudgetRepository {
  BudgetRepository(this._db);
  final AppDatabase _db;

  Stream<List<Budget>> watchByMonth(String month) {
    return (_db.select(_db.budgets)
          ..where((t) => t.periodMonth.equals(month) & t.deleted.equals(false)))
        .watch();
  }

  Future<List<Budget>> getByMonth(String month) {
    return (_db.select(_db.budgets)
          ..where((t) => t.periodMonth.equals(month) & t.deleted.equals(false)))
        .get();
  }

  Future<void> upsert(BudgetsCompanion companion) async {
    await _db.into(_db.budgets).insertOnConflictUpdate(companion);
  }

  Future<void> upsertAll(List<BudgetsCompanion> companions) async {
    await _db.batch((b) {
      for (final c in companions) {
        b.insert(_db.budgets, c, onConflict: DoUpdate((_) => c));
      }
    });
  }

  /// Marks a budget deleted locally and queues the deletion for push. Never
  /// synced (never got a real server id) budgets are hard-deleted immediately
  /// since the server never had a copy to tell.
  Future<void> softDelete(int id) async {
    final row = await getById(id);
    if (row == null) return;
    if (!row.everSynced) {
      await hardDelete(id);
      return;
    }
    await (_db.update(_db.budgets)..where((t) => t.id.equals(id))).write(
      const BudgetsCompanion(deleted: Value(true), pendingSync: Value(true)),
    );
  }

  Future<int> hardDelete(int id) {
    return (_db.delete(_db.budgets)..where((t) => t.id.equals(id))).go();
  }

  Future<Budget?> getById(int id) {
    return (_db.select(_db.budgets)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<Budget>> getPendingSync() {
    return (_db.select(_db.budgets)..where((t) => t.pendingSync.equals(true)))
        .get();
  }

  /// Replaces a locally-created row (pseudo id) with the server-assigned id
  /// once the budget has been pushed successfully.
  Future<void> replaceWithServerId(int localId, int serverId) async {
    if (localId == serverId) {
      await (_db.update(_db.budgets)..where((t) => t.id.equals(localId)))
          .write(const BudgetsCompanion(
        pendingSync: Value(false),
        everSynced: Value(true),
      ));
      return;
    }
    final row = await getById(localId);
    if (row == null) return;
    await _db.transaction(() async {
      await (_db.delete(_db.budgets)..where((t) => t.id.equals(localId)))
          .go();
      await _db.into(_db.budgets).insertOnConflictUpdate(
            BudgetsCompanion.insert(
              id: Value(serverId),
              scope: row.scope,
              ownerUserId: Value(row.ownerUserId),
              categoryId: row.categoryId,
              amount: row.amount,
              periodMonth: row.periodMonth,
              pendingSync: const Value(false),
              everSynced: const Value(true),
            ),
          );
    });
  }
}
