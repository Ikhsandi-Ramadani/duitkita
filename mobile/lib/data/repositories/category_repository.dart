import 'package:drift/drift.dart';
import '../db/app_database.dart';

class CategoryRepository {
  CategoryRepository(this._db);
  final AppDatabase _db;

  Stream<List<Category>> watchAll() {
    return (_db.select(_db.categories)..where((t) => t.deleted.equals(false)))
        .watch();
  }

  Future<List<Category>> getAll() {
    return (_db.select(_db.categories)..where((t) => t.deleted.equals(false)))
        .get();
  }

  Future<List<Category>> getByType(String type) {
    return (_db.select(_db.categories)
          ..where((t) => t.type.equals(type) & t.deleted.equals(false)))
        .get();
  }

  Stream<List<Category>> watchByType(String type) {
    return (_db.select(_db.categories)
          ..where((t) => t.type.equals(type) & t.deleted.equals(false)))
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

  Future<void> deleteById(int id) async {
    await (_db.delete(_db.categories)..where((t) => t.id.equals(id))).go();
  }
}
