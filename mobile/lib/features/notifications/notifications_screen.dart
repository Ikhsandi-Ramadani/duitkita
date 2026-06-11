import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../ui/widgets/app_top_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.appBg,
      appBar: AppTopBar(title: 'Notifikasi'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: _kNotifs.map((n) => _NotifCard(item: n)).toList(),
      ),
    );
  }
}

enum _NotifType { warning, transfer, income, reminder }

class _NotifItem {
  const _NotifItem({
    required this.type,
    required this.title,
    required this.sub,
    required this.time,
  });
  final _NotifType type;
  final String title;
  final String sub;
  final String time;
}

const _kNotifs = [
  _NotifItem(
    type: _NotifType.warning,
    title: 'Anggaran hampir habis',
    sub: 'Makanan sudah terpakai 92% dari anggaran bulan ini',
    time: '2 jam lalu',
  ),
  _NotifItem(
    type: _NotifType.transfer,
    title: 'Transfer isi kas',
    sub: 'Budi mengisi Kas Bersama sebesar Rp2.000.000',
    time: '5 jam lalu',
  ),
  _NotifItem(
    type: _NotifType.income,
    title: 'Gaji masuk',
    sub: 'Pemasukan Rp8.500.000 dicatat ke BCA Pribadi',
    time: 'Kemarin',
  ),
  _NotifItem(
    type: _NotifType.reminder,
    title: 'Tagihan IndiHome jatuh tempo',
    sub: 'Tagihan IndiHome senilai Rp350.000 jatuh tempo 2 hari lagi',
    time: '1 hari lalu',
  ),
];

class _NotifCard extends StatelessWidget {
  const _NotifCard({required this.item});
  final _NotifItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final (iconData, iconColor, iconBg) = _meta(item.type, colors);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF142818).withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppText.cardTitle(color: colors.text),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.time,
                        style: AppText.micro(color: colors.text3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.sub,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colors.text2,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static (IconData, Color, Color) _meta(_NotifType t, AppColors colors) {
    switch (t) {
      case _NotifType.warning:
        return (
          Icons.warning_amber_rounded,
          const Color(0xFFD97706),
          const Color(0xFFFEF3C7),
        );
      case _NotifType.transfer:
        return (
          Icons.swap_horiz_rounded,
          colors.transfer,
          colors.transferTint,
        );
      case _NotifType.income:
        return (
          Icons.arrow_downward_rounded,
          colors.income,
          colors.incomeTint,
        );
      case _NotifType.reminder:
        return (
          Icons.notifications_active_outlined,
          colors.expense,
          colors.expenseTint,
        );
    }
  }
}
