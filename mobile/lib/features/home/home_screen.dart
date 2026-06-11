import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      body: Center(
        child: Text(
          'Beranda',
          style: AppText.screenTitle(color: colors.text),
        ),
      ),
    );
  }
}
