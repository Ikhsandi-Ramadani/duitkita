import 'package:drift/drift.dart';
import '../db/app_database.dart';

class BudgetRepository {
  BudgetRepository(this._db);
  final AppDatabase _db;

  Stream<List<Budget>> watchByMonth(String month) {
    return (_db.select(_db.budgets)
          ..where((t) => t.periodMonth.equals(month)))
        .watch();
  }

  Future<List<Budget>> getByMonth(String month) {
    return (_db.select(_db.budgets)
          ..where((t) => t.periodMonth.equals(month)))
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

  Future<int> delete(int id) {
    return (_db.delete(_db.budgets)..where((t) => t.id.equals(id))).go();
  }
}
