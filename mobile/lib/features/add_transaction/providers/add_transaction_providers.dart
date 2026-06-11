import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers.dart';
import '../../../data/db/app_database.dart';

// ---------------------------------------------------------------------------
// Transaction being edited (nullable = new)
// ---------------------------------------------------------------------------

final editingTransactionProvider =
    FutureProvider.family<Transaction?, String>((ref, clientId) async {
  final db = ref.watch(dbProvider);
  return (db.select(db.transactions)
        ..where((t) => t.clientId.equals(clientId)))
      .getSingleOrNull();
});
