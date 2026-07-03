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
  int get schemaVersion => 7;

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
          if (from < 6) {
            await m.addColumn(debts, debts.everSynced);
            await m.addColumn(recurrings, recurrings.everSynced);
            await m.addColumn(budgets, budgets.everSynced);
            await m.addColumn(budgets, budgets.deleted);
            await m.addColumn(savingsGoals, savingsGoals.pendingSync);
            await m.addColumn(savingsGoals, savingsGoals.everSynced);
            // Rows already synced before this migration (pendingSync=false)
            // already have a real server id — backfill everSynced so the next
            // edit routes to an UPDATE call instead of creating a duplicate.
            await customStatement('UPDATE debts SET ever_synced = 1 WHERE pending_sync = 0');
            await customStatement('UPDATE recurrings SET ever_synced = 1 WHERE pending_sync = 0');
            await customStatement('UPDATE budgets SET ever_synced = 1 WHERE pending_sync = 0');
          }
          if (from < 7) {
            await m.addColumn(categories, categories.deleted);
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
