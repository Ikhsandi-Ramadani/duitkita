import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../ui/widgets/app_top_bar.dart';
import '../../ui/widgets/empty_state.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.appBg,
      appBar: AppTopBar(title: 'Utang & Piutang'),
      body: EmptyState(
        icon: Icons.account_balance_outlined,
        title: 'Utang & Piutang',
        sub: 'Fitur utang & piutang akan hadir segera',
      ),
    );
  }
}
