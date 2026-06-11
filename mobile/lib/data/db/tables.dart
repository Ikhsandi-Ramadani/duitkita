import 'package:drift/drift.dart';

// ---------------------------------------------------------------------------
// Members
// ---------------------------------------------------------------------------
class Members extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get role => text()();
  IntColumn get avatarHue => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Wallets
// ---------------------------------------------------------------------------
class Wallets extends Table {
  IntColumn get id => integer()();
  TextColumn get scope => text()(); // personal | shared
  IntColumn get ownerUserId => integer().nullable()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // cash | bank | ewallet
  TextColumn get icon => text().nullable()();
  IntColumn get initialBalance => integer()();
  IntColumn get currentBalance => integer()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Categories
// ---------------------------------------------------------------------------
class Categories extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // income | expense
  TextColumn get icon => text()();
  IntColumn get hue => integer()();
  IntColumn get parentId => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Transactions
// ---------------------------------------------------------------------------
class Transactions extends Table {
  TextColumn get clientId => text()(); // uuid v4
  IntColumn get serverId => integer().nullable()();
  TextColumn get type => text()(); // income | expense | transfer | adjustment
  IntColumn get walletId => integer()();
  IntColumn get targetWalletId => integer().nullable()();
  IntColumn get categoryId => integer().nullable()();
  IntColumn get amount => integer()(); // signed
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  IntColumn get recordedBy => integer()();
  IntColumn get spentBy => integer().nullable()();
  TextColumn get receiptPath => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {clientId};
}

// ---------------------------------------------------------------------------
// Budgets
// ---------------------------------------------------------------------------
class Budgets extends Table {
  IntColumn get id => integer()();
  TextColumn get scope => text()();
  IntColumn get ownerUserId => integer().nullable()();
  IntColumn get categoryId => integer()();
  IntColumn get amount => integer()();
  TextColumn get periodMonth => text()(); // YYYY-MM

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// SavingsGoals
// ---------------------------------------------------------------------------
class SavingsGoals extends Table {
  IntColumn get id => integer()();
  TextColumn get scope => text()();
  IntColumn get ownerUserId => integer().nullable()();
  TextColumn get name => text()();
  IntColumn get targetAmount => integer()();
  IntColumn get currentAmount => integer()();
  DateTimeColumn get targetDate => dateTime().nullable()();
  IntColumn get walletId => integer()();
  TextColumn get icon => text()();
  IntColumn get hue => integer()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Debts
// ---------------------------------------------------------------------------
class Debts extends Table {
  IntColumn get id => integer()();
  IntColumn get ownerUserId => integer().nullable()();
  TextColumn get type => text()(); // payable | receivable
  TextColumn get partyName => text()();
  IntColumn get amount => integer()();
  IntColumn get paid => integer()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get status => text()();
  TextColumn get note => text().nullable()();
  IntColumn get walletId => integer().nullable()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Recurrings
// ---------------------------------------------------------------------------
class Recurrings extends Table {
  IntColumn get id => integer()();
  TextColumn get type => text()();
  IntColumn get walletId => integer()();
  IntColumn get categoryId => integer()();
  IntColumn get amount => integer()();
  TextColumn get freq => text()();
  DateTimeColumn get nextRunDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get autoCreate => boolean()();
  TextColumn get note => text().nullable()();
  IntColumn get createdBy => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// SessionKv
// ---------------------------------------------------------------------------
class SessionKv extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
