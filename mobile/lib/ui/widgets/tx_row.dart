import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/format.dart';
import 'cat_icon.dart';
import 'member_avatar.dart';
import 'tx_type_meta.dart';

/// A single transaction row with:
/// - category chip + recorder avatar badge (19px bottom-right)
/// - title + subtitle (wallet - note)
/// - "untuk nama" label when spentBy set
/// - signed amount (15/w700 tabular)
class TxRow extends StatelessWidget {
  const TxRow({
    super.key,
    required this.type,
    required this.categoryName,
    required this.categoryIconKey,
    required this.categoryHue,
    required this.recorderInitial,
    required this.recorderHue,
    required this.title,
    required this.walletName,
    this.note,
    this.spentByName,
    required this.amount,
    required this.hidden,
    this.onTap,
  });

  final String type;
  final String categoryName;
  final String categoryIconKey;
  final int categoryHue;
  final String recorderInitial;
  final int recorderHue;
  final String title;
  final String walletName;
  final String? note;
  final String? spentByName;
  final int amount;
  final bool hidden;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final meta = TxTypeMeta.of(type, colors);

    final amountText = hidden
        ? '••••••'
        : _buildAmountText(amount, type);

    final subtitle = [
      walletName,
      if (note != null && note!.isNotEmpty) note!,
    ].join(' · ');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Category chip with recorder avatar badge
            SizedBox(
              width: 42,
              height: 42,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CatIcon(
                    iconKey: categoryIconKey,
                    hue: categoryHue,
                    size: 42,
                  ),
                  Positioned(
                    bottom: -2,
                    right: -4,
                    child: Container(
                      width: 19,
                      height: 19,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.surface, width: 1.5),
                      ),
                      child: MemberAvatar(
                        hue: recorderHue,
                        initial: recorderInitial,
                        size: 19,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Title + subtitle + spentBy
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.body(color: colors.text).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppText.label(color: colors.text3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (spentByName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'untuk $spentByName',
                      style: AppText.micro(color: colors.text2),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Amount
            Text(
              amountText,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.15,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: meta.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _buildAmountText(int amount, String type) {
    final abs = amount.abs();
    final rp = 'Rp${_rpFmt(abs)}';
    switch (type) {
      case 'income':
        return '+$rp';
      case 'expense':
        return '−$rp';
      default:
        return rp;
    }
  }

  static String _rpFmt(int n) {
    // Reuse format utils
    return fmtRp(n).replaceFirst('Rp', '');
  }
}
