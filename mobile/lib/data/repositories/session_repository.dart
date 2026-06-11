import '../db/app_database.dart';

class SessionRepository {
  SessionRepository(this._db);
  final AppDatabase _db;

  Future<String?> get(String key) async {
    final row = await (
      _db.select(_db.sessionKv)
        ..where((t) => t.key.equals(key))
    ).getSingleOrNull();
    return row?.value;
  }

  Future<void> set(String key, String value) async {
    await _db.into(_db.sessionKv).insertOnConflictUpdate(
      SessionKvCompanion.insert(key: key, value: value),
    );
  }

  Stream<String?> watch(String key) {
    return (
      _db.select(_db.sessionKv)
        ..where((t) => t.key.equals(key))
    ).watchSingleOrNull().map((row) => row?.value);
  }

  Future<int?> getCurrentUserId() async {
    final v = await get('currentUserId');
    return v == null ? null : int.tryParse(v);
  }

  Future<void> setCurrentUserId(int id) => set('currentUserId', id.toString());

  Stream<int?> watchCurrentUserId() {
    return watch('currentUserId').map((v) => v == null ? null : int.tryParse(v));
  }
}
