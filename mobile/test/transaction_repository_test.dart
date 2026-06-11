import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:duitkita/data/db/app_database.dart';
import 'package:duitkita/data/repositories/wallet_repository.dart';
import 'package:duitkita/data/repositories/transaction_repository.dart';
import 'package:duitkita/data/repositories/goal_repository.dart';
import 'package:duitkita/data/repositories/debt_repository.dart';

AppDatabase _makeDb() => AppDatabase(NativeDatabase.memory());

Future<void> _seedWallets(AppDatabase db) async {
  await db.batch((b) {
    b.insertAll(db.wallets, [
      WalletsCompanion.insert(id: const Value(1), scope: 'personal', name: 'BCA', type: 'bank', initialBalance: 10000000, currentBalance: 10000000),
      WalletsCompanion.insert(id: const Value(2), scope: 'personal', name: 'Tunai', type: 'cash', initialBalance: 500000, currentBalance: 500000),
    ]);
  });
}

Future<int> _getBalance(AppDatabase db, int walletId) async {
  final w = await (db.select(db.wallets)..where((t) => t.id.equals(walletId))).getSingle();
  return w.currentBalance;
}

void main() {
  group('TransactionRepository — balance mutations', () {
    late AppDatabase db;
    late WalletRepository walletRepo;
    late TransactionRepository txRepo;

    setUp(() async {
      db = _makeDb();
      walletRepo = WalletRepository(db);
      txRepo = TransactionRepository(db, walletRepo);
      await _seedWallets(db);
    });

    tearDown(() => db.close());

    // -----------------------------------------------------------------------
    test('addTransaction income increases wallet balance', () async {
      await txRepo.addTransaction(
        type: 'income', walletId: 1, amount: 2000000,
        date: DateTime.now(), recordedBy: 1,
      );
      expect(await _getBalance(db, 1), 12000000);
    });

    test('addTransaction expense decreases wallet balance', () async {
      await txRepo.addTransaction(
        type: 'expense', walletId: 1, amount: 300000,
        date: DateTime.now(), recordedBy: 1,
      );
      expect(await _getBalance(db, 1), 9700000);
    });

    test('addTransaction transfer moves money between wallets', () async {
      await txRepo.addTransaction(
        type: 'transfer', walletId: 1, targetWalletId: 2,
        amount: 500000, date: DateTime.now(), recordedBy: 1,
      );
      expect(await _getBalance(db, 1), 9500000);
      expect(await _getBalance(db, 2), 1000000);
    });

    test('addTransaction adjustment applies signed amount', () async {
      // positive adjustment
      await txRepo.addTransaction(
        type: 'adjustment', walletId: 1, amount: 100000,
        date: DateTime.now(), recordedBy: 1,
      );
      expect(await _getBalance(db, 1), 10100000);

      // negative adjustment
      await txRepo.addTransaction(
        type: 'adjustment', walletId: 2, amount: -50000,
        date: DateTime.now(), recordedBy: 1,
      );
      expect(await _getBalance(db, 2), 450000);
    });

    // -----------------------------------------------------------------------
    test('updateTransaction reverses old effect and applies new', () async {
      final tx = await txRepo.addTransaction(
        type: 'expense', walletId: 1, amount: 200000,
        date: DateTime.now(), recordedBy: 1,
      );
      // balance = 9800000
      expect(await _getBalance(db, 1), 9800000);

      await txRepo.updateTransaction(
        clientId: tx.clientId,
        type: 'expense', walletId: 1, amount: 300000,
        date: tx.date,
      );
      // reversed 200000 (back to 10M), applied 300000 → 9700000
      expect(await _getBalance(db, 1), 9700000);
    });

    test('updateTransaction income changed to expense reverses correctly', () async {
      final tx = await txRepo.addTransaction(
        type: 'income', walletId: 1, amount: 1000000,
        date: DateTime.now(), recordedBy: 1,
      );
      expect(await _getBalance(db, 1), 11000000);

      await txRepo.updateTransaction(
        clientId: tx.clientId,
        type: 'expense', walletId: 1, amount: 500000,
        date: tx.date,
      );
      // reverse income (+1M → -1M) + expense (-500k) = 10M - 500k = 9500000
      expect(await _getBalance(db, 1), 9500000);
    });

    // -----------------------------------------------------------------------
    test('deleteTransaction reverses balance and soft-deletes', () async {
      final tx = await txRepo.addTransaction(
        type: 'expense', walletId: 1, amount: 400000,
        date: DateTime.now(), recordedBy: 1,
      );
      expect(await _getBalance(db, 1), 9600000);

      await txRepo.deleteTransaction(tx.clientId);
      // balance restored
      expect(await _getBalance(db, 1), 10000000);

      // row is soft-deleted
      final deleted = await (db.select(db.transactions)
            ..where((t) => t.clientId.equals(tx.clientId)))
          .getSingle();
      expect(deleted.deleted, isTrue);
      expect(deleted.pendingSync, isTrue);
    });

    test('deleted transactions excluded from watchRecent', () async {
      final tx = await txRepo.addTransaction(
        type: 'expense', walletId: 1, amount: 100000,
        date: DateTime.now(), recordedBy: 1,
      );
      await txRepo.deleteTransaction(tx.clientId);

      final recent = await txRepo.watchRecent(10).first;
      expect(recent.every((t) => !t.deleted), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  group('GoalRepository.contribute', () {
    late AppDatabase db;
    late WalletRepository walletRepo;
    late TransactionRepository txRepo;
    late GoalRepository goalRepo;

    setUp(() async {
      db = _makeDb();
      walletRepo = WalletRepository(db);
      txRepo = TransactionRepository(db, walletRepo);
      goalRepo = GoalRepository(db, txRepo);

      await _seedWallets(db);
      // Add a goal wallet (wallet 3)
      await db.into(db.wallets).insert(
        WalletsCompanion.insert(id: const Value(3), scope: 'shared', name: 'Dana Keluarga', type: 'bank', initialBalance: 5000000, currentBalance: 5000000),
      );
      // Goal in wallet 3
      await db.into(db.savingsGoals).insert(
        SavingsGoalsCompanion.insert(
          id: const Value(1), scope: 'shared', name: 'Dana Darurat',
          targetAmount: 20000000, currentAmount: 5000000,
          walletId: 3, icon: 'shield', hue: 162,
        ),
      );
    });

    tearDown(() => db.close());

    test('contribute from different wallet creates transfer + increments currentAmount', () async {
      await goalRepo.contribute(goalId: 1, amount: 1000000, sourceWalletId: 1, recordedBy: 1);

      // Source wallet decreased
      expect(await _getBalance(db, 1), 9000000);
      // Goal wallet increased
      expect(await _getBalance(db, 3), 6000000);

      // currentAmount incremented
      final goal = await (db.select(db.savingsGoals)..where((t) => t.id.equals(1))).getSingle();
      expect(goal.currentAmount, 6000000);
    });

    test('contribute from same wallet earmarks only — no balance change', () async {
      await goalRepo.contribute(goalId: 1, amount: 500000, sourceWalletId: 3, recordedBy: 1);

      // Goal wallet balance unchanged (earmark only)
      expect(await _getBalance(db, 3), 5000000);

      // currentAmount incremented
      final goal = await (db.select(db.savingsGoals)..where((t) => t.id.equals(1))).getSingle();
      expect(goal.currentAmount, 5500000);
    });
  });

  // -------------------------------------------------------------------------
  group('DebtRepository.pay', () {
    late AppDatabase db;
    late WalletRepository walletRepo;
    late TransactionRepository txRepo;
    late DebtRepository debtRepo;

    setUp(() async {
      db = _makeDb();
      walletRepo = WalletRepository(db);
      txRepo = TransactionRepository(db, walletRepo);
      debtRepo = DebtRepository(db, txRepo);

      await _seedWallets(db);
      // Payable debt
      await db.into(db.debts).insert(
        DebtsCompanion.insert(
          id: const Value(1), type: 'payable', partyName: 'Adira',
          amount: 12000000, paid: 7000000, date: DateTime(2025, 1, 1),
          status: 'active', walletId: const Value(1),
        ),
      );
      // Receivable debt
      await db.into(db.debts).insert(
        DebtsCompanion.insert(
          id: const Value(2), type: 'receivable', partyName: 'Tante Lia',
          amount: 1500000, paid: 500000, date: DateTime(2026, 5, 1),
          status: 'active', walletId: const Value(1),
        ),
      );
    });

    tearDown(() => db.close());

    test('pay payable creates expense transaction and decreases wallet', () async {
      await debtRepo.pay(debtId: 1, amount: 1000000, walletId: 1, recordedBy: 1);

      expect(await _getBalance(db, 1), 9000000);

      final debt = await (db.select(db.debts)..where((t) => t.id.equals(1))).getSingle();
      expect(debt.paid, 8000000);
      expect(debt.status, 'active');
    });

    test('pay payable fully sets status to paid', () async {
      await debtRepo.pay(debtId: 1, amount: 5000000, walletId: 1, recordedBy: 1);

      final debt = await (db.select(db.debts)..where((t) => t.id.equals(1))).getSingle();
      expect(debt.paid, 12000000);
      expect(debt.status, 'paid');
    });

    test('pay receivable creates income transaction and increases wallet', () async {
      await debtRepo.pay(debtId: 2, amount: 500000, walletId: 1, recordedBy: 1);

      expect(await _getBalance(db, 1), 10500000);

      final debt = await (db.select(db.debts)..where((t) => t.id.equals(2))).getSingle();
      expect(debt.paid, 1000000);
    });

    test('pay receivable fully sets status to paid', () async {
      await debtRepo.pay(debtId: 2, amount: 1000000, walletId: 1, recordedBy: 1);

      final debt = await (db.select(db.debts)..where((t) => t.id.equals(2))).getSingle();
      expect(debt.paid, 1500000);
      expect(debt.status, 'paid');
    });
  });
}
