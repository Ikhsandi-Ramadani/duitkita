import 'package:drift/drift.dart';
import '../db/app_database.dart';

class CategoryRepository {
  CategoryRepository(this._db);
  final AppDatabase _db;

  Stream<List<Category>> watchAll() => _db.select(_db.categories).watch();

  Future<List<Category>> getAll() => _db.select(_db.categories).get();

  Future<List<Category>> getByType(String type) {
    return (_db.select(_db.categories)..where((t) => t.type.equals(type))).get();
  }

  Stream<List<Category>> watchByType(String type) {
    return (_db.select(_db.categories)..where((t) => t.type.equals(type)))
        .watch();
  }

  Future<void> upsert(CategoriesCompanion companion) async {
    await _db.into(_db.categories).insertOnConflictUpdate(companion);
  }

  Future<void> upsertAll(List<CategoriesCompanion> companions) async {
    await _db.batch((b) {
      for (final c in companions) {
        b.insert(_db.categories, c, onConflict: DoUpdate((_) => c));
      }
    });
  }
}
