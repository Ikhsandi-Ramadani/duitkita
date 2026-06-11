import 'package:drift/drift.dart';
import '../db/app_database.dart';

class WalletRepository {
  WalletRepository(this._db);
  final AppDatabase _db;

  Stream<List<Wallet>> watchAll() {
    return (_db.select(_db.wallets)
          ..where((t) => t.deleted.equals(false)))
        .watch();
  }

  Future<List<Wallet>> getAll() {
    return (_db.select(_db.wallets)
          ..where((t) => t.deleted.equals(false)))
        .get();
  }

  Future<Wallet?> getById(int id) async {
    return (_db.select(_db.wallets)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<Wallet?> watchById(int id) {
    return (_db.select(_db.wallets)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  Future<void> upsert(WalletsCompanion companion) async {
    await _db.into(_db.wallets).insertOnConflictUpdate(companion);
  }

  Future<void> upsertAll(List<WalletsCompanion> companions) async {
    await _db.batch((b) {
      for (final c in companions) {
        b.insert(_db.wallets, c, onConflict: DoUpdate((_) => c));
      }
    });
  }

  /// Internal: mutate currentBalance by [delta] within an existing transaction.
  Future<void> applyBalanceDelta(int walletId, int delta) async {
    final wallet = await getById(walletId);
    if (wallet == null) return;
    await (_db.update(_db.wallets)..where((t) => t.id.equals(walletId)))
        .write(WalletsCompanion(
      currentBalance: Value(wallet.currentBalance + delta),
    ));
  }
}
