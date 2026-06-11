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
  SessionKv,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'duitkita'));

  @override
  int get schemaVersion => 1;
}
