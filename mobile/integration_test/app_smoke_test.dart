import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:duitkita/app.dart';
import 'package:duitkita/data/db/app_database.dart';
import 'package:duitkita/data/db/seed.dart';
import 'package:duitkita/data/providers.dart';
import 'package:duitkita/ui/widgets/tx_row.dart';

/// Drives the real app through every screen using seeded demo data.
/// Any uncaught exception fails the test.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  Future<void> pumpApp(WidgetTester tester) async {
    await initializeDateFormatting('id_ID');
    db = AppDatabase(NativeDatabase.memory());
    await seedIfEmpty(db);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [dbProvider.overrideWithValue(db)],
        child: const DuitKitaApp(),
      ),
    );
    // Use pump instead of pumpAndSettle — Drift stream watchers never "settle".
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('full app walkthrough', (tester) async {
    await pumpApp(tester);

    // ── Beranda (explicitly seeded demo sessions do not require PIN) ──
    expect(
      find.textContaining('Total Kekayaan'),
      findsWidgets,
      reason: 'home should render after unlock',
    );
    await settle(tester);

    // ── Tab Transaksi ──
    await tester.tap(find.text('Transaksi').last);
    await settle(tester);

    // Open first transaction detail if present, then back
    final txRows = find.byType(TxRow);
    if (txRows.evaluate().isNotEmpty) {
      await tester.tap(txRows.first);
      await settle(tester);
      await tester.pageBack();
      await settle(tester);
    }

    // ── Tab Dompet ──
    await tester.tap(find.text('Dompet').last);
    await settle(tester);

    // ── Tab Profil ──
    await tester.tap(find.text('Profil').last);
    await settle(tester);

    // ── Add Transaction overlay via FAB (the "+" slot in bottom nav) ──
    await tester.tap(find.byIcon(Icons.add).first);
    await settle(tester);
    // Close it — AddTransaction is a pushed route, close pops back to shell.
    final closeBtn = find.byIcon(Icons.close);
    if (closeBtn.evaluate().isNotEmpty) {
      await tester.tap(closeBtn.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    // ── Pushed screens from Beranda hub ──
    final berandaTab = find.text('Beranda');
    if (berandaTab.evaluate().isNotEmpty) {
      await tester.tap(berandaTab.last);
    }
    await settle(tester);

    for (final label in [
      'Anggaran',
      'Tujuan',
      'Utang',
      'Berulang',
      'Laporan',
    ]) {
      final tile = find.text(label);
      if (tile.evaluate().isEmpty) continue;
      await tester.tap(tile.first);
      await settle(tester);
      await tester.pageBack();
      await settle(tester);
    }
  });
}
