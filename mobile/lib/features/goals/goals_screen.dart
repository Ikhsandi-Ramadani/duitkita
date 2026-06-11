import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../ui/widgets/app_top_bar.dart';
import '../../ui/widgets/empty_state.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.appBg,
      appBar: AppTopBar(title: 'Kantong Tujuan'),
      body: EmptyState(
        icon: Icons.flag_circle_outlined,
        title: 'Kantong Tujuan',
        sub: 'Fitur kantong tujuan akan hadir segera',
      ),
    );
  }
}
