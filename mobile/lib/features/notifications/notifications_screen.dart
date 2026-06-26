import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../ui/widgets/app_top_bar.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final notifsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: colors.appBg,
      appBar: AppTopBar(
        title: 'Notifikasi',
        action: IconButton(
          icon: Icon(Icons.done_all_rounded, color: colors.text2, size: 22),
          tooltip: 'Tandai semua dibaca',
          onPressed: () async {
            await ref.read(notificationRepoProvider).markAllRead();
            try {
              await ref.read(apiClientProvider).markAllNotificationsRead();
            } catch (e) {
              // Fire-and-forget — local state already updated
              if (kDebugMode) print('[Notifications] markAllRead error: $e');
            }
          },
        ),
      ),
      body: notifsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat notifikasi: $e')),
        data: (notifs) {
          if (notifs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none_rounded,
                      size: 56, color: colors.text3),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada notifikasi',
                    style: AppText.cardTitle(color: colors.text2),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            itemCount: notifs.length,
            itemBuilder: (context, i) => _NotifCard(
              item: notifs[i],
              onTap: () async {
                if (notifs[i].readAt == null) {
                  await ref
                      .read(notificationRepoProvider)
                      .markRead(notifs[i].id);
                  try {
                    await ref
                        .read(apiClientProvider)
                        .markNotificationRead(notifs[i].id);
                  } catch (e) {
                    // Fire-and-forget — local read state already updated
                    if (kDebugMode) print('[Notifications] markRead error: $e');
                  }
                }
              },
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card
// ---------------------------------------------------------------------------

class _NotifCard extends StatelessWidget {
  const _NotifCard({required this.item, required this.onTap});

  final Notification item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isUnread = item.readAt == null;
    final (iconData, iconColor, iconBg) = _iconMeta(item.type, colors);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUnread
                ? colors.primary.withValues(alpha: 0.05)
                : colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isUnread
                  ? colors.primary.withValues(alpha: 0.18)
                  : colors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF142818).withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconData, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: AppText.cardTitle(color: colors.text)
                                .copyWith(
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _relativeTime(item.createdAt),
                          style: AppText.micro(color: colors.text3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colors.text2,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (isUnread) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static (IconData, Color, Color) _iconMeta(String type, AppColors colors) {
    switch (type) {
      case 'budget_alert':
        return (
          Icons.warning_amber_rounded,
          const Color(0xFFD97706),
          const Color(0xFFFEF3C7),
        );
      case 'transaction':
      case 'receipt_long':
        return (
          Icons.receipt_long_rounded,
          colors.income,
          colors.incomeTint,
        );
      case 'transfer':
        return (
          Icons.swap_horiz_rounded,
          colors.transfer,
          colors.transferTint,
        );
      case 'member_join':
      case 'member':
        return (
          Icons.person_add_rounded,
          colors.primary,
          colors.primary.withValues(alpha: 0.12),
        );
      case 'recurring':
      case 'reminder':
        return (
          Icons.notifications_active_outlined,
          colors.expense,
          colors.expenseTint,
        );
      case 'goal':
        return (
          Icons.savings_rounded,
          const Color(0xFF7C3AED),
          const Color(0xFFEDE9FE),
        );
      case 'debt':
        return (
          Icons.account_balance_rounded,
          const Color(0xFFD97706),
          const Color(0xFFFEF3C7),
        );
      default:
        return (
          Icons.info_outline_rounded,
          colors.text2,
          colors.border,
        );
    }
  }

  static String _relativeTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return DateFormat('d MMM', 'id').format(dt);
  }
}
