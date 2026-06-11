import 'package:drift/drift.dart';
import '../db/app_database.dart';
import 'transaction_repository.dart';

class DebtRepository {
  DebtRepository(this._db, this._txRepo);
  final AppDatabase _db;
  final TransactionRepository _txRepo;

  Stream<List<Debt>> watchAll() {
    return (_db.select(_db.debts)..where((t) => t.deleted.equals(false)))
        .watch();
  }

  Future<List<Debt>> getAll() {
    return (_db.select(_db.debts)..where((t) => t.deleted.equals(false))).get();
  }

  Future<Debt?> getById(int id) async {
    return (_db.select(_db.debts)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> upsert(DebtsCompanion companion) async {
    await _db.into(_db.debts).insertOnConflictUpdate(companion);
  }

  Future<void> upsertAll(List<DebtsCompanion> companions) async {
    await _db.batch((b) {
      for (final c in companions) {
        b.insert(_db.debts, c, onConflict: DoUpdate((_) => c));
      }
    });
  }

  /// Pay [amount] toward debt [debtId] using [walletId].
  /// payable → creates expense transaction (money leaves wallet).
  /// receivable → creates income transaction (money enters wallet).
  /// Updates paid amount and status (paid when fully settled).
  Future<void> pay({
    required int debtId,
    required int amount,
    required int walletId,
    required int recordedBy,
  }) async {
    final debt = await getById(debtId);
    if (debt == null) throw StateError('Debt $debtId not found');

    await _db.transaction(() async {
      if (debt.type == 'payable') {
        await _txRepo.addTransaction(
          type: 'expense',
          walletId: walletId,
          amount: amount,
          date: DateTime.now(),
          note: 'Pembayaran utang: ${debt.partyName}',
          recordedBy: recordedBy,
        );
      } else {
        // receivable — money received
        await _txRepo.addTransaction(
          type: 'income',
          walletId: walletId,
          amount: amount,
          date: DateTime.now(),
          note: 'Penerimaan piutang: ${debt.partyName}',
          recordedBy: recordedBy,
        );
      }

      final newPaid = debt.paid + amount;
      final newStatus = newPaid >= debt.amount ? 'paid' : debt.status;

      await (_db.update(_db.debts)..where((t) => t.id.equals(debtId)))
          .write(DebtsCompanion(
        paid: Value(newPaid),
        status: Value(newStatus),
      ));
    });
  }
}
