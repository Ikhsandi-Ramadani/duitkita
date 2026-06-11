import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.appBg,
      appBar: AppBar(
        backgroundColor: colors.appBg,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Tambah Transaksi',
          style: AppText.cardTitle(color: colors.text),
        ),
      ),
      body: Center(
        child: Text(
          'Tambah Transaksi',
          style: AppText.screenTitle(color: colors.text),
        ),
      ),
    );
  }
}
