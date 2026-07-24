import 'package:drift/drift.dart';
import 'app_database.dart';

/// Seeds demo data if the Members table is empty.
/// Seeded transactions do NOT have pendingSync=true.
/// Balances are already post-transaction (as-is).
Future<void> seedIfEmpty(AppDatabase db) async {
  final existing = await db.select(db.members).get();
  if (existing.isNotEmpty) return;

  await db.transaction(() async {
    // -----------------------------------------------------------------------
    // Members
    // -----------------------------------------------------------------------
    await db.batch((b) {
      b.insertAll(db.members, [
        MembersCompanion.insert(
          id: const Value(1),
          name: 'Budi',
          email: 'budi@example.com',
          role: 'owner',
          avatarHue: 162,
        ),
        MembersCompanion.insert(
          id: const Value(2),
          name: 'Sari',
          email: 'sari@example.com',
          role: 'member',
          avatarHue: 340,
        ),
        MembersCompanion.insert(
          id: const Value(3),
          name: 'Rian',
          email: 'rian@example.com',
          role: 'member',
          avatarHue: 255,
        ),
      ]);
    });

    // -----------------------------------------------------------------------
    // Wallets
    // -----------------------------------------------------------------------
    await db.batch((b) {
      b.insertAll(db.wallets, [
        WalletsCompanion.insert(
          id: const Value(1),
          scope: 'personal',
          ownerUserId: const Value(1),
          name: 'BCA Budi',
          type: 'bank',
          icon: const Value('account_balance'),
          initialBalance: 18450000,
          currentBalance: 18450000,
        ),
        WalletsCompanion.insert(
          id: const Value(2),
          scope: 'personal',
          ownerUserId: const Value(1),
          name: 'Tunai Budi',
          type: 'cash',
          icon: const Value('payments'),
          initialBalance: 620000,
          currentBalance: 620000,
        ),
        WalletsCompanion.insert(
          id: const Value(3),
          scope: 'personal',
          ownerUserId: const Value(2),
          name: 'GoPay Sari',
          type: 'ewallet',
          icon: const Value('account_balance_wallet'),
          initialBalance: 845000,
          currentBalance: 845000,
        ),
        WalletsCompanion.insert(
          id: const Value(4),
          scope: 'personal',
          ownerUserId: const Value(2),
          name: 'Tunai Sari',
          type: 'cash',
          icon: const Value('payments'),
          initialBalance: 310000,
          currentBalance: 310000,
        ),
        WalletsCompanion.insert(
          id: const Value(5),
          scope: 'personal',
          ownerUserId: const Value(3),
          name: 'OVO Rian',
          type: 'ewallet',
          icon: const Value('account_balance_wallet'),
          initialBalance: 175000,
          currentBalance: 175000,
        ),
        WalletsCompanion.insert(
          id: const Value(6),
          scope: 'shared',
          name: 'Kas Belanja',
          type: 'cash',
          icon: const Value('shopping_cart'),
          initialBalance: 2380000,
          currentBalance: 2380000,
        ),
        WalletsCompanion.insert(
          id: const Value(7),
          scope: 'shared',
          name: 'Dana Keluarga',
          type: 'bank',
          icon: const Value('account_balance'),
          initialBalance: 12500000,
          currentBalance: 12500000,
        ),
      ]);
    });

    // -----------------------------------------------------------------------
    // Categories
    // -----------------------------------------------------------------------
    await db.batch((b) {
      b.insertAll(db.categories, [
        CategoriesCompanion.insert(
          id: const Value(1),
          name: 'Makanan',
          type: 'expense',
          icon: 'utensils',
          hue: 24,
        ),
        CategoriesCompanion.insert(
          id: const Value(2),
          name: 'Transport',
          type: 'expense',
          icon: 'car',
          hue: 210,
        ),
        CategoriesCompanion.insert(
          id: const Value(3),
          name: 'Bensin',
          type: 'expense',
          icon: 'fuel',
          hue: 30,
        ),
        CategoriesCompanion.insert(
          id: const Value(4),
          name: 'Tagihan',
          type: 'expense',
          icon: 'receipt',
          hue: 265,
        ),
        CategoriesCompanion.insert(
          id: const Value(5),
          name: 'Pulsa & Data',
          type: 'expense',
          icon: 'signal',
          hue: 190,
        ),
        CategoriesCompanion.insert(
          id: const Value(6),
          name: 'Belanja',
          type: 'expense',
          icon: 'bag',
          hue: 320,
        ),
        CategoriesCompanion.insert(
          id: const Value(7),
          name: 'Kesehatan',
          type: 'expense',
          icon: 'health',
          hue: 0,
        ),
        CategoriesCompanion.insert(
          id: const Value(8),
          name: 'Pendidikan',
          type: 'expense',
          icon: 'book',
          hue: 230,
        ),
        CategoriesCompanion.insert(
          id: const Value(9),
          name: 'Hiburan',
          type: 'expense',
          icon: 'film',
          hue: 290,
        ),
        CategoriesCompanion.insert(
          id: const Value(10),
          name: 'Arisan',
          type: 'expense',
          icon: 'users',
          hue: 130,
        ),
        CategoriesCompanion.insert(
          id: const Value(11),
          name: 'Zakat & Sedekah',
          type: 'expense',
          icon: 'handheart',
          hue: 160,
        ),
        CategoriesCompanion.insert(
          id: const Value(12),
          name: 'Lainnya',
          type: 'expense',
          icon: 'dots',
          hue: 200,
        ),
        CategoriesCompanion.insert(
          id: const Value(13),
          name: 'Gaji',
          type: 'income',
          icon: 'briefcase',
          hue: 162,
        ),
        CategoriesCompanion.insert(
          id: const Value(14),
          name: 'Bonus / THR',
          type: 'income',
          icon: 'gift',
          hue: 145,
        ),
        CategoriesCompanion.insert(
          id: const Value(15),
          name: 'Lainnya',
          type: 'income',
          icon: 'dots',
          hue: 175,
        ),
      ]);
    });

    // -----------------------------------------------------------------------
    // Budgets — June 2026
    // -----------------------------------------------------------------------
    await db.batch((b) {
      b.insertAll(db.budgets, [
        BudgetsCompanion.insert(
          id: const Value(1),
          scope: 'shared',
          categoryId: 1,
          amount: 3500000,
          periodMonth: '2026-06',
        ),
        BudgetsCompanion.insert(
          id: const Value(2),
          scope: 'shared',
          categoryId: 2,
          amount: 1200000,
          periodMonth: '2026-06',
        ),
        BudgetsCompanion.insert(
          id: const Value(3),
          scope: 'shared',
          categoryId: 6,
          amount: 2000000,
          periodMonth: '2026-06',
        ),
        BudgetsCompanion.insert(
          id: const Value(4),
          scope: 'shared',
          categoryId: 4,
          amount: 1800000,
          periodMonth: '2026-06',
        ),
        BudgetsCompanion.insert(
          id: const Value(5),
          scope: 'shared',
          categoryId: 9,
          amount: 800000,
          periodMonth: '2026-06',
        ),
      ]);
    });

    // -----------------------------------------------------------------------
    // Transactions — June 2026 (pendingSync=false, balances already applied)
    // -----------------------------------------------------------------------
    final now = DateTime.now();
    await db.batch((b) {
      b.insertAll(db.transactions, [
        // 1 Jun — Gaji Budi income BCA 14.5jt
        TransactionsCompanion.insert(
          clientId: 'seed-tx-001',
          type: 'income',
          walletId: 1,
          categoryId: const Value(13),
          amount: 14500000,
          date: DateTime(2026, 6, 1, 8, 0),
          recordedBy: 1,
          updatedAt: now,
          pendingSync: const Value(false),
        ),
        // 1 Jun — Transfer BCA→Kas Belanja 2jt by Budi
        TransactionsCompanion.insert(
          clientId: 'seed-tx-002',
          type: 'transfer',
          walletId: 1,
          targetWalletId: const Value(6),
          amount: -2000000,
          date: DateTime(2026, 6, 1, 9, 0),
          recordedBy: 1,
          updatedAt: now,
          pendingSync: const Value(false),
        ),
        // 2 Jun — Sarapan 87rb expense Kas Belanja by Sari for Rian
        TransactionsCompanion.insert(
          clientId: 'seed-tx-003',
          type: 'expense',
          walletId: 6,
          categoryId: const Value(1),
          amount: -87000,
          date: DateTime(2026, 6, 2, 7, 30),
          note: const Value('Sarapan pagi'),
          recordedBy: 2,
          spentBy: const Value(3),
          updatedAt: now,
          pendingSync: const Value(false),
        ),
        // 2 Jun — Belanja superindo 250rb expense Kas Belanja by Sari
        TransactionsCompanion.insert(
          clientId: 'seed-tx-004',
          type: 'expense',
          walletId: 6,
          categoryId: const Value(6),
          amount: -250000,
          date: DateTime(2026, 6, 2, 11, 0),
          note: const Value('Superindo mingguan'),
          recordedBy: 2,
          updatedAt: now,
          pendingSync: const Value(false),
        ),
        // 3 Jun — Gojek 45rb OVO by Rian
        TransactionsCompanion.insert(
          clientId: 'seed-tx-005',
          type: 'expense',
          walletId: 5,
          categoryId: const Value(2),
          amount: -45000,
          date: DateTime(2026, 6, 3, 8, 15),
          note: const Value('Gojek ke kantor'),
          recordedBy: 3,
          updatedAt: now,
          pendingSync: const Value(false),
        ),
        // 3 Jun — Listrik 320rb BCA by Budi
        TransactionsCompanion.insert(
          clientId: 'seed-tx-006',
          type: 'expense',
          walletId: 1,
          categoryId: const Value(4),
          amount: -320000,
          date: DateTime(2026, 6, 3, 10, 0),
          note: const Value('Tagihan listrik'),
          recordedBy: 1,
          updatedAt: now,
          pendingSync: const Value(false),
        ),
        // 4 Jun — Bensin 80rb Tunai Budi
        TransactionsCompanion.insert(
          clientId: 'seed-tx-007',
          type: 'expense',
          walletId: 2,
          categoryId: const Value(3),
          amount: -80000,
          date: DateTime(2026, 6, 4, 7, 0),
          recordedBy: 1,
          updatedAt: now,
          pendingSync: const Value(false),
        ),
        // 5 Jun — Makan siang 65rb Kas Belanja by Sari
        TransactionsCompanion.insert(
          clientId: 'seed-tx-008',
          type: 'expense',
          walletId: 6,
          categoryId: const Value(1),
          amount: -65000,
          date: DateTime(2026, 6, 5, 12, 30),
          note: const Value('Makan siang bersama'),
          recordedBy: 2,
          updatedAt: now,
          pendingSync: const Value(false),
        ),
        // 6 Jun — IndiHome 230rb BCA by Budi
        TransactionsCompanion.insert(
          clientId: 'seed-tx-009',
          type: 'expense',
          walletId: 1,
          categoryId: const Value(4),
          amount: -230000,
          date: DateTime(2026, 6, 6, 9, 0),
          note: const Value('IndiHome bulanan'),
          recordedBy: 1,
          updatedAt: now,
          pendingSync: const Value(false),
        ),
        // 7 Jun — Paket Data 100rb GoPay by Sari
        TransactionsCompanion.insert(
          clientId: 'seed-tx-010',
          type: 'expense',
          walletId: 3,
          categoryId: const Value(5),
          amount: -100000,
          date: DateTime(2026, 6, 7, 14, 0),
          note: const Value('Paket data Sari'),
          recordedBy: 2,
          updatedAt: now,
          pendingSync: const Value(false),
        ),
        // 7 Jun — Les Rian 420rb Dana Keluarga by Budi
        TransactionsCompanion.insert(
          clientId: 'seed-tx-011',
          type: 'expense',
          walletId: 7,
          categoryId: const Value(8),
          amount: -420000,
          date: DateTime(2026, 6, 7, 16, 0),
          note: const Value('Les matematika Rian'),
          recordedBy: 1,
          spentBy: const Value(3),
          updatedAt: now,
          pendingSync: const Value(false),
        ),
        // 8 Jun — Hiburan bioskop 120rb GoPay by Sari
        TransactionsCompanion.insert(
          clientId: 'seed-tx-012',
          type: 'expense',
          walletId: 3,
          categoryId: const Value(9),
          amount: -120000,
          date: DateTime(2026, 6, 8, 19, 0),
          note: const Value('Nonton bioskop'),
          recordedBy: 2,
          updatedAt: now,
          pendingSync: const Value(false),
        ),
        // 8 Jun — Belanja online 350rb BCA by Budi
        TransactionsCompanion.insert(
          clientId: 'seed-tx-013',
          type: 'expense',
          walletId: 1,
          categoryId: const Value(6),
          amount: -350000,
          date: DateTime(2026, 6, 8, 20, 0),
          note: const Value('Belanja Tokopedia'),
          recordedBy: 1,
          updatedAt: now,
          pendingSync: const Value(false),
        ),
        // 9 Jun — Gojek Rian 38rb OVO
        TransactionsCompanion.insert(
          clientId: 'seed-tx-014',
          type: 'expense',
          walletId: 5,
          categoryId: const Value(2),
          amount: -38000,
          date: DateTime(2026, 6, 9, 8, 0),
          note: const Value('Ojol ke sekolah'),
          recordedBy: 3,
          updatedAt: now,
          pendingSync: const Value(false),
        ),
        // 10 Jun — Sarapan keluarga 145rb Kas Belanja by Sari
        TransactionsCompanion.insert(
          clientId: 'seed-tx-015',
          type: 'expense',
          walletId: 6,
          categoryId: const Value(1),
          amount: -145000,
          date: DateTime(2026, 6, 10, 8, 0),
          note: const Value('Sarapan keluarga'),
          recordedBy: 2,
          updatedAt: now,
          pendingSync: const Value(false),
        ),
        // 10 Jun — Kesehatan vitamin 75rb Tunai Sari
        TransactionsCompanion.insert(
          clientId: 'seed-tx-016',
          type: 'expense',
          walletId: 4,
          categoryId: const Value(7),
          amount: -75000,
          date: DateTime(2026, 6, 10, 15, 0),
          note: const Value('Vitamin keluarga'),
          recordedBy: 2,
          updatedAt: now,
          pendingSync: const Value(false),
        ),
        // 11 Jun — Zakat 500rb BCA by Budi
        TransactionsCompanion.insert(
          clientId: 'seed-tx-017',
          type: 'expense',
          walletId: 1,
          categoryId: const Value(11),
          amount: -500000,
          date: DateTime(2026, 6, 11, 9, 0),
          note: const Value('Zakat bulanan'),
          recordedBy: 1,
          updatedAt: now,
          pendingSync: const Value(false),
        ),
        // 11 Jun — Makan siang 95rb Kas Belanja
        TransactionsCompanion.insert(
          clientId: 'seed-tx-018',
          type: 'expense',
          walletId: 6,
          categoryId: const Value(1),
          amount: -95000,
          date: DateTime(2026, 6, 11, 12, 0),
          note: const Value('Makan siang Jumat'),
          recordedBy: 2,
          updatedAt: now,
          pendingSync: const Value(false),
        ),
      ]);
    });

    // -----------------------------------------------------------------------
    // Savings Goals
    // -----------------------------------------------------------------------
    await db.batch((b) {
      b.insertAll(db.savingsGoals, [
        SavingsGoalsCompanion.insert(
          id: const Value(1),
          scope: 'shared',
          name: 'Dana Darurat Keluarga',
          targetAmount: 20000000,
          currentAmount: 12500000,
          walletId: 7,
          icon: 'shield',
          hue: 162,
        ),
        SavingsGoalsCompanion.insert(
          id: const Value(2),
          scope: 'shared',
          name: 'Liburan Lebaran',
          targetAmount: 15000000,
          currentAmount: 4500000,
          walletId: 7,
          icon: 'flag',
          hue: 30,
        ),
        SavingsGoalsCompanion.insert(
          id: const Value(3),
          scope: 'personal',
          ownerUserId: const Value(2),
          name: 'Tabungan HP Sari',
          targetAmount: 5000000,
          currentAmount: 2100000,
          walletId: 3,
          icon: 'smartphone',
          hue: 340,
        ),
        SavingsGoalsCompanion.insert(
          id: const Value(4),
          scope: 'personal',
          ownerUserId: const Value(1),
          name: 'Pendidikan Rian',
          targetAmount: 30000000,
          currentAmount: 18000000,
          walletId: 1,
          icon: 'book',
          hue: 230,
        ),
      ]);
    });

    // -----------------------------------------------------------------------
    // Debts
    // -----------------------------------------------------------------------
    await db.batch((b) {
      b.insertAll(db.debts, [
        DebtsCompanion.insert(
          id: const Value(1),
          type: 'payable',
          partyName: 'Adira Finance',
          amount: 12000000,
          paid: 7000000,
          date: DateTime(2025, 1, 1),
          dueDate: Value(DateTime.utc(2026, 6, 25)),
          status: 'active',
          note: const Value('Cicilan motor'),
          walletId: const Value(7),
        ),
        DebtsCompanion.insert(
          id: const Value(2),
          type: 'payable',
          partyName: 'Pak Hasan',
          amount: 2000000,
          paid: 0,
          date: DateTime(2026, 5, 15),
          dueDate: Value(DateTime.utc(2026, 6, 20)),
          status: 'active',
          walletId: const Value(1),
        ),
        DebtsCompanion.insert(
          id: const Value(3),
          type: 'receivable',
          partyName: 'Tante Lia',
          amount: 1500000,
          paid: 500000,
          date: DateTime(2026, 5, 1),
          dueDate: Value(DateTime.utc(2026, 7, 10)),
          status: 'active',
          walletId: const Value(7),
        ),
        DebtsCompanion.insert(
          id: const Value(4),
          type: 'receivable',
          partyName: 'Rian',
          amount: 300000,
          paid: 0,
          date: DateTime(2026, 6, 5),
          dueDate: Value(DateTime.utc(2026, 6, 15)),
          status: 'active',
          walletId: const Value(3),
        ),
      ]);
    });

    // -----------------------------------------------------------------------
    // Recurrings
    // -----------------------------------------------------------------------
    await db.batch((b) {
      b.insertAll(db.recurrings, [
        RecurringsCompanion.insert(
          id: const Value(1),
          type: 'income',
          walletId: 1,
          categoryId: 13,
          amount: 14500000,
          freq: 'monthly',
          nextRunDate: DateTime(2026, 7, 1),
          autoCreate: true,
          createdBy: 1,
        ),
        RecurringsCompanion.insert(
          id: const Value(2),
          type: 'expense',
          walletId: 6,
          categoryId: 4,
          amount: 230000,
          freq: 'monthly',
          nextRunDate: DateTime(2026, 7, 1),
          autoCreate: true,
          note: const Value('IndiHome'),
          createdBy: 1,
        ),
        RecurringsCompanion.insert(
          id: const Value(3),
          type: 'expense',
          walletId: 1,
          categoryId: 4,
          amount: 320000,
          freq: 'monthly',
          nextRunDate: DateTime(2026, 7, 1),
          autoCreate: false,
          note: const Value('Listrik PLN'),
          createdBy: 1,
        ),
        RecurringsCompanion.insert(
          id: const Value(4),
          type: 'expense',
          walletId: 3,
          categoryId: 5,
          amount: 100000,
          freq: 'monthly',
          nextRunDate: DateTime(2026, 7, 1),
          autoCreate: false,
          note: const Value('Paket data'),
          createdBy: 2,
        ),
        RecurringsCompanion.insert(
          id: const Value(5),
          type: 'expense',
          walletId: 7,
          categoryId: 8,
          amount: 420000,
          freq: 'monthly',
          nextRunDate: DateTime(2026, 7, 1),
          autoCreate: true,
          note: const Value('Les Rian'),
          createdBy: 1,
        ),
      ]);
    });

    // -----------------------------------------------------------------------
    // Session
    // -----------------------------------------------------------------------
    await db.batch((b) {
      b.insertAll(db.sessionKv, [
        SessionKvCompanion.insert(key: 'currentUserId', value: '1'),
        SessionKvCompanion.insert(key: 'householdName', value: 'Keluarga Budi'),
        SessionKvCompanion.insert(key: 'lastSyncAt', value: '0'),
        SessionKvCompanion.insert(key: 'themeMode', value: 'system'),
        SessionKvCompanion.insert(key: 'balanceHidden', value: 'false'),
        SessionKvCompanion.insert(key: 'demoMode', value: 'true'),
        SessionKvCompanion.insert(key: 'hasPin', value: 'false'),
      ]);
    });
  });
}
