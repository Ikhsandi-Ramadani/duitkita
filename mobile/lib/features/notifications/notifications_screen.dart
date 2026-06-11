import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../ui/widgets/app_top_bar.dart';
import '../../ui/widgets/empty_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.appBg,
      appBar: AppTopBar(title: 'Notifikasi'),
      body: EmptyState(
        icon: Icons.notifications_outlined,
        title: 'Belum ada notifikasi',
        sub: 'Notifikasi akan muncul di sini',
      ),
    );
  }
}
