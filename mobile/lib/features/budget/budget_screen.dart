import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../ui/widgets/app_top_bar.dart';
import '../../ui/widgets/empty_state.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.appBg,
      appBar: AppTopBar(title: 'Anggaran'),
      body: EmptyState(
        icon: Icons.tune_rounded,
        title: 'Anggaran',
        sub: 'Fitur anggaran akan hadir segera',
      ),
    );
  }
}
