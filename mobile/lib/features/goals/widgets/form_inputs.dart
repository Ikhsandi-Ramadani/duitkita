import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/format.dart';

/// Rupiah text field — numeric only, formats with thousand separators on display.
/// [onChanged] receives the raw integer value.
class RupiahInput extends StatefulWidget {
  const RupiahInput({
    super.key,
    required this.onChanged,
    this.initialValue = 0,
    this.label = 'Jumlah',
  });

  final ValueChanged<int> onChanged;
  final int initialValue;
  final String label;

  @override
  State<RupiahInput> createState() => _RupiahInputState();
}

class _RupiahInputState extends State<RupiahInput> {
  late final TextEditingController _ctrl;

  static String _format(int v) => v == 0 ? '' : fmtRp(v).replaceAll('Rp', '');

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _format(widget.initialValue));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onRawChanged(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final value = int.tryParse(digits) ?? 0;
    final formatted = _format(value);
    if (_ctrl.text != formatted) {
      _ctrl.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppText.label(color: colors.text2)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: colors.surface2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Rp',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colors.text2,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                  onChanged: _onRawChanged,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: colors.text,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '0',
                    hintStyle: AppText.body(color: colors.text3),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Horizontal scrollable chip row for single-selection.
class ChipRow<T> extends StatelessWidget {
  const ChipRow({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
    this.label,
  });

  final List<({T value, String label})> items;
  final T? selected;
  final ValueChanged<T> onSelected;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppText.label(color: colors.text2)),
          const SizedBox(height: 6),
        ],
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: items.map((item) {
              final isSelected = item.value == selected;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onSelected(item.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.primary.withValues(alpha: 0.12)
                          : colors.surface2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? colors.primary : colors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      item.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? colors.primary : colors.text2,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Section label + divider utility.
class FormSection extends StatelessWidget {
  const FormSection({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: AppText.label(color: colors.text2)),
    );
  }
}

/// Standard text input field.
class AppTextInput extends StatelessWidget {
  const AppTextInput({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
    this.icon,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label(color: colors.text2)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: colors.surface2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: AppText.body(color: colors.text),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: AppText.body(color: colors.text3),
              prefixIcon: icon != null
                  ? Icon(icon, color: colors.text3, size: 18)
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Save button for forms.
class SaveButton extends StatelessWidget {
  const SaveButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          disabledBackgroundColor: colors.surface3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: enabled ? Colors.white : colors.text3,
          ),
        ),
      ),
    );
  }
}
