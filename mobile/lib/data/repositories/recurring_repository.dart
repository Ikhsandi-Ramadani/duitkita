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
}
