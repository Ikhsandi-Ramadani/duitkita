import 'package:drift/drift.dart';
import '../db/app_database.dart';

class RecurringRepository {
  RecurringRepository(this._db);
  final AppDatabase _db;

  Stream<List<Recurring>> watchAll() => _db.select(_db.recurrings).watch();

  Future<List<Recurring>> getAll() => _db.select(_db.recurrings).get();

  Future<void> upsert(RecurringsCompanion companion) async {
    await _db.into(_db.recurrings).insertOnConflictUpdate(companion);
  }

  Future<void> upsertAll(List<RecurringsCompanion> companions) async {
    await _db.batch((b) {
      for (final c in companions) {
        b.insert(_db.recurrings, c, onConflict: DoUpdate((_) => c));
      }
    });
  }

  Future<Recurring?> getById(int id) {
    return (_db.select(_db.recurrings)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<Recurring>> getPendingSync() {
    return (_db.select(_db.recurrings)
          ..where((t) => t.pendingSync.equals(true)))
        .get();
  }

  /// Replaces a locally-created row (pseudo id) with the server-assigned id
  /// once the recurring rule has been pushed successfully.
  Future<void> replaceWithServerId(int localId, int serverId) async {
    if (localId == serverId) {
      await (_db.update(_db.recurrings)..where((t) => t.id.equals(localId)))
          .write(const RecurringsCompanion(
        pendingSync: Value(false),
        everSynced: Value(true),
      ));
      return;
    }
    final row = await getById(localId);
    if (row == null) return;
    await _db.transaction(() async {
      await (_db.delete(_db.recurrings)..where((t) => t.id.equals(localId)))
          .go();
      await _db.into(_db.recurrings).insertOnConflictUpdate(
            RecurringsCompanion.insert(
              id: Value(serverId),
              type: row.type,
              walletId: row.walletId,
              categoryId: row.categoryId,
              amount: row.amount,
              freq: row.freq,
              nextRunDate: row.nextRunDate,
              endDate: Value(row.endDate),
              autoCreate: row.autoCreate,
              note: Value(row.note),
              createdBy: row.createdBy,
              pendingSync: const Value(false),
              everSynced: const Value(true),
            ),
          );
    });
  }
}
