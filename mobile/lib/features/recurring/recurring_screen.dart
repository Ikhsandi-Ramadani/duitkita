import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../ui/widgets/app_top_bar.dart';
import '../../ui/widgets/empty_state.dart';

class RecurringScreen extends StatelessWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.appBg,
      appBar: AppTopBar(title: 'Transaksi Berulang'),
      body: EmptyState(
        icon: Icons.autorenew_rounded,
        title: 'Transaksi Berulang',
        sub: 'Fitur transaksi berulang akan hadir segera',
      ),
    );
  }
}
