import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Members,
  Wallets,
  Categories,
  Transactions,
  Budgets,
  SavingsGoals,
  Debts,
  Recurrings,
  Notifications,
  SessionKv,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'duitkita'));

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(notifications);
          }
          if (from < 3) {
            await m.addColumn(debts, debts.pendingSync);
            await m.addColumn(recurrings, recurrings.pendingSync);
          }
          if (from < 4) {
            await m.addColumn(members, members.phone);
            await m.addColumn(members, members.avatarPath);
          }
          if (from < 5) {
            await m.addColumn(budgets, budgets.pendingSync);
          }
        },
      );

  Future<void> clearAll() async {
    await delete(transactions).go();
    await delete(wallets).go();
    await delete(categories).go();
    await delete(members).go();
    await delete(budgets).go();
    await delete(savingsGoals).go();
    await delete(debts).go();
    await delete(recurrings).go();
    await delete(notifications).go();
  }
}
