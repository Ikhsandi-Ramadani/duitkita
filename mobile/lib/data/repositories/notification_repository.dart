import 'package:drift/drift.dart';
import '../db/app_database.dart';

class NotificationRepository {
  NotificationRepository(this._db);
  final AppDatabase _db;

  Stream<List<Notification>> watchAll() =>
      (_db.select(_db.notifications)
            ..orderBy([(n) => OrderingTerm.desc(n.createdAt)]))
          .watch();

  Future<int> unreadCount() async {
    final countExpr = _db.notifications.id.count();
    final query = _db.selectOnly(_db.notifications)
      ..addColumns([countExpr])
      ..where(_db.notifications.readAt.isNull());
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  Stream<int> watchUnreadCount() {
    final countExpr = _db.notifications.id.count();
    final query = _db.selectOnly(_db.notifications)
      ..addColumns([countExpr])
      ..where(_db.notifications.readAt.isNull());
    return query.map((row) => row.read(countExpr) ?? 0).watchSingle();
  }

  Future<void> upsertAll(List<Map<String, dynamic>> items) async {
    await _db.batch((b) {
      for (final item in items) {
        final companion = NotificationsCompanion(
          id: Value(item['id'] as int),
          householdId: Value(item['household_id'] as int),
          userId: Value(item['user_id'] as int?),
          type: Value(item['type'] as String),
          title: Value(item['title'] as String),
          body: Value(item['body'] as String),
          data: Value(item['data'] as String?),
          readAt: Value(
            item['read_at'] != null
                ? DateTime.parse(item['read_at'] as String)
                : null,
          ),
          createdAt: Value(DateTime.parse(item['created_at'] as String)),
        );
        b.insert(_db.notifications, companion,
            onConflict: DoUpdate((_) => companion));
      }
    });
  }

  Future<void> markRead(int id) async {
    await (_db.update(_db.notifications)..where((n) => n.id.equals(id)))
        .write(NotificationsCompanion(readAt: Value(DateTime.now())));
  }

  Future<void> markAllRead() async {
    await (_db.update(_db.notifications)
          ..where((n) => n.readAt.isNull()))
        .write(NotificationsCompanion(readAt: Value(DateTime.now())));
  }
}
