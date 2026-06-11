import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/format.dart';
import 'app_sheet.dart';

/// Reusable amount input sheet:
/// - Quick chips (+50rb/100rb/250rb/500rb/1jt + Reset)
/// - Wallet picker row
/// - Confirm button
class AmountSheet extends StatefulWidget {
  const AmountSheet({
    super.key,
    required this.wallets,
    this.title = 'Jumlah',
    this.confirmLabel = 'Konfirmasi',
    this.initialAmount = 0,
    this.initialWalletId,
    this.onConfirm,
    this.accentColor,
  });

  final List<WalletOption> wallets;
  final String title;
  final String confirmLabel;
  final int initialAmount;
  final int? initialWalletId;
  final void Function(int amount, int walletId)? onConfirm;
  final Color? accentColor;

  static Future<void> show({
    required BuildContext context,
    required List<WalletOption> wallets,
    String title = 'Jumlah',
    String confirmLabel = 'Konfirmasi',
    int initialAmount = 0,
    int? initialWalletId,
    void Function(int amount, int walletId)? onConfirm,
    Color? accentColor,
  }) {
    return AppSheet.show(
      context: context,
      child: AmountSheet(
        wallets: wallets,
        title: title,
        confirmLabel: confirmLabel,
        initialAmount: initialAmount,
        initialWalletId: initialWalletId,
        onConfirm: onConfirm,
        accentColor: accentColor,
      ),
    );
  }

  @override
  State<AmountSheet> createState() => _AmountSheetState();
}

class _AmountSheetState extends State<AmountSheet> {
  late int _amount;
  late int? _walletId;

  static const _chips = [50000, 100000, 250000, 500000, 1000000];

  @override
  void initState() {
    super.initState();
    _amount = widget.initialAmount;
    _walletId =
        widget.initialWalletId ?? (widget.wallets.isNotEmpty ? widget.wallets.first.id : null);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = widget.accentColor ?? colors.primary;
    final canConfirm = _amount > 0 && _walletId != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title,
              style: AppText.sectionTitle(color: colors.text)),
          const SizedBox(height: 16),
          // Amount display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colors.surface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border),
            ),
            child: Text(
              _amount == 0 ? 'Rp0' : fmtRp(_amount),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: accent,
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Quick chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ..._chips.map((v) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _ChipButton(
                        label: '+${fmtShort(v).replaceAll('Rp', '')}',
                        onTap: () => setState(() => _amount += v),
                        accent: accent,
                      ),
                    )),
                _ChipButton(
                  label: 'Reset',
                  onTap: () => setState(() => _amount = 0),
                  accent: colors.text3,
                  outlined: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Wallet picker
          if (widget.wallets.isNotEmpty) ...[
            Text('Dari dompet', style: AppText.label(color: colors.text2)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.wallets.map((w) {
                  final isSelected = _walletId == w.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _walletId = w.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? accent.withValues(alpha: 0.12) : colors.surface2,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? accent : colors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(w.name,
                                style: AppText.label(
                                    color: isSelected ? accent : colors.text)),
                            Text(fmtRp(w.balance),
                                style: AppText.micro(
                                    color: isSelected ? accent : colors.text2)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: canConfirm
                  ? () {
                      Navigator.of(context).pop();
                      widget.onConfirm?.call(_amount, _walletId!);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                disabledBackgroundColor: colors.surface3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                widget.confirmLabel,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.label,
    required this.onTap,
    required this.accent,
    this.outlined = false,
  });

  final String label;
  final VoidCallback onTap;
  final Color accent;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: outlined ? colors.border : accent.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: outlined ? colors.text3 : accent,
          ),
        ),
      ),
    );
  }
}

/// Public wallet option for AmountSheet.
class WalletOption {
  const WalletOption({required this.id, required this.name, required this.balance});
  final int id;
  final String name;
  final int balance;
}
