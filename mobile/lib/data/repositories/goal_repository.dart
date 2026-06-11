import 'package:drift/drift.dart';
import '../db/app_database.dart';
import 'transaction_repository.dart';

class GoalRepository {
  GoalRepository(this._db, this._txRepo);
  final AppDatabase _db;
  final TransactionRepository _txRepo;

  Stream<List<SavingsGoal>> watchAll() {
    return (_db.select(_db.savingsGoals)
          ..where((t) => t.deleted.equals(false)))
        .watch();
  }

  Future<List<SavingsGoal>> getAll() {
    return (_db.select(_db.savingsGoals)
          ..where((t) => t.deleted.equals(false)))
        .get();
  }

  Future<SavingsGoal?> getById(int id) async {
    return (_db.select(_db.savingsGoals)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> upsert(SavingsGoalsCompanion companion) async {
    await _db.into(_db.savingsGoals).insertOnConflictUpdate(companion);
  }

  Future<void> upsertAll(List<SavingsGoalsCompanion> companions) async {
    await _db.batch((b) {
      for (final c in companions) {
        b.insert(_db.savingsGoals, c, onConflict: DoUpdate((_) => c));
      }
    });
  }

  /// Contribute [amount] from [sourceWalletId] to goal [goalId].
  /// If sourceWalletId != goal.walletId → create a transfer transaction
  ///   (moves money to goal.walletId and increments currentAmount).
  /// If sourceWalletId == goal.walletId → earmark only (increment currentAmount,
  ///   no wallet balance change since money is already in goal wallet).
  Future<void> contribute({
    required int goalId,
    required int amount,
    required int sourceWalletId,
    required int recordedBy,
  }) async {
    final goal = await getById(goalId);
    if (goal == null) throw StateError('Goal $goalId not found');

    await _db.transaction(() async {
      if (sourceWalletId != goal.walletId) {
        // Create a transfer transaction: source → goal wallet
        await _txRepo.addTransaction(
          type: 'transfer',
          walletId: sourceWalletId,
          targetWalletId: goal.walletId,
          amount: amount,
          date: DateTime.now(),
          note: 'Kontribusi: ${goal.name}',
          recordedBy: recordedBy,
        );
      }
      // Increment currentAmount
      await (_db.update(_db.savingsGoals)
            ..where((t) => t.id.equals(goalId)))
          .write(SavingsGoalsCompanion(
        currentAmount: Value(goal.currentAmount + amount),
      ));
    });
  }
}
