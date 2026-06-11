import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:duitkita/app.dart';
import 'package:duitkita/data/db/app_database.dart';
import 'package:duitkita/data/providers.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  testWidgets('App builds without error', (WidgetTester tester) async {
    // Override the DB with an in-memory database to avoid pending timer issues.
    final inMemoryDb = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        // Auto-retry schedules timers the test framework flags as pending.
        retry: (retryCount, error) => null,
        overrides: [
          dbProvider.overrideWithValue(inMemoryDb),
        ],
        child: const DuitKitaApp(),
      ),
    );
    // GoRouter renders at least one widget
    expect(find.byType(MaterialApp), findsOneWidget);

    // Unmount the app and flush any straggler timers before teardown.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));

    addTearDown(() => inMemoryDb.close());
  });
}
