import 'package:drift/drift.dart';
import '../db/app_database.dart';

class MemberRepository {
  MemberRepository(this._db);
  final AppDatabase _db;

  Stream<List<Member>> watchAll() => _db.select(_db.members).watch();

  Future<List<Member>> getAll() => _db.select(_db.members).get();

  Future<Member?> getById(int id) async {
    return (_db.select(_db.members)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> upsert(MembersCompanion companion) async {
    await _db.into(_db.members).insertOnConflictUpdate(companion);
  }

  Future<void> upsertAll(List<MembersCompanion> companions) async {
    await _db.batch((b) {
      for (final c in companions) {
        b.insert(_db.members, c, onConflict: DoUpdate((_) => c));
      }
    });
  }
}
