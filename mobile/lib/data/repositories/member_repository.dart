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

  Future<void> deleteById(int id) async {
    await (_db.delete(_db.members)..where((m) => m.id.equals(id))).go();
  }

  /// Removes any local member NOT in [keepIds]. The server's members query is
  /// always the full current household roster (never date-filtered), so this
  /// is safe to run after every pull — it's how a member removed by another
  /// device stops showing up as a permanent zombie in pickers.
  Future<void> deleteAllExcept(List<int> keepIds) async {
    if (keepIds.isEmpty) return;
    await (_db.delete(_db.members)..where((m) => m.id.isNotIn(keepIds))).go();
  }
}
