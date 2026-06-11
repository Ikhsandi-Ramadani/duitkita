import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Metadata for a transaction type: color, label, icon.
class TxTypeMeta {
  const TxTypeMeta({
    required this.color,
    required this.tintColor,
    required this.label,
    required this.icon,
    required this.signedPrefix,
  });

  final Color color;
  final Color tintColor;
  final String label;
  final IconData icon;
  final String signedPrefix; // '+' or '−' or ''

  static TxTypeMeta of(String type, AppColors colors) {
    switch (type) {
      case 'income':
        return TxTypeMeta(
          color: colors.income,
          tintColor: colors.incomeTint,
          label: 'Masuk',
          icon: Icons.arrow_downward_rounded,
          signedPrefix: '+',
        );
      case 'expense':
        return TxTypeMeta(
          color: colors.expense,
          tintColor: colors.expenseTint,
          label: 'Keluar',
          icon: Icons.arrow_upward_rounded,
          signedPrefix: '−',
        );
      case 'transfer':
        return TxTypeMeta(
          color: colors.transfer,
          tintColor: colors.transferTint,
          label: 'Transfer',
          icon: Icons.swap_horiz_rounded,
          signedPrefix: '',
        );
      case 'adjustment':
      default:
        return TxTypeMeta(
          color: colors.adjust,
          tintColor: colors.adjustTint,
          label: 'Penyesuaian',
          icon: Icons.tune_rounded,
          signedPrefix: '',
        );
    }
  }
}
