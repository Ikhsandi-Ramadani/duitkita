import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/format.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../ui/widgets/app_sheet.dart';
import '../../ui/widgets/app_toast.dart';
import '../../ui/widgets/app_top_bar.dart';
import '../../ui/widgets/cat_icon.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/segmented_control.dart';
import '../goals/widgets/form_inputs.dart';

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final recurringsAsync = ref.watch(recurringsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final walletsAsync = ref.watch(walletsProvider);
    final userAsync = ref.watch(currentUserIdProvider);

    return Scaffold(
      backgroundColor: colors.appBg,
      appBar: AppTopBar(
        title: 'Transaksi Berulang',
        action: IconButton(
          icon: Icon(Icons.add_rounded, color: colors.primary, size: 24),
          onPressed: () => AppSheet.show(
            context: context,
            child: _AddRecurringSheet(ref: ref),
          ),
          splashRadius: 20,
        ),
      ),
      body: recurringsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Gagal memuat',
          sub: e.toString(),
        ),
        data: (recurrings) {
          final cats = categoriesAsync.value ?? [];
          final wallets = walletsAsync.value ?? [];
          final uid = userAsync.value ?? 1;
          final catMap = {for (final c in cats) c.id: c};
          final walletMap = {for (final w in wallets) w.id: w};

          final incomeRec = recurrings.where((r) => r.type == 'income').toList();
          final expenseRec = recurrings.where((r) => r.type == 'expense').toList();
          final totalIn = incomeRec.fold(0, (s, r) => s + r.amount);
          final totalOut = expenseRec.fold(0, (s, r) => s + r.amount);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              // Summary cards
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'Masuk Rutin',
                      amount: totalIn,
                      sub: '/bln',
                      color: colors.income,
                      tint: colors.incomeTint,
                      icon: Icons.arrow_downward_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Keluar Rutin',
                      amount: totalOut,
                      sub: '/bln',
                      color: colors.expense,
                      tint: colors.expenseTint,
                      icon: Icons.arrow_upward_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (recurrings.isEmpty)
                EmptyState(
                  icon: Icons.autorenew_rounded,
                  title: 'Belum ada transaksi berulang',
                  sub: 'Tap + untuk menambahkan',
                )
              else
                ...recurrings.map((r) => _RecurringCard(
                      recurring: r,
                      cat: catMap[r.categoryId],
                      wallet: walletMap[r.walletId],
                      ref: ref,
                      uid: uid,
                    )),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.sub,
    required this.color,
    required this.tint,
    required this.icon,
  });

  final String label;
  final int amount;
  final String sub;
  final Color color;
  final Color tint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(label, style: AppText.micro(color: color.withValues(alpha: 0.85))),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            fmtShort(amount),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(sub, style: AppText.micro(color: color.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}

class _RecurringCard extends StatefulWidget {
  const _RecurringCard({
    required this.recurring,
    required this.cat,
    required this.wallet,
    required this.ref,
    required this.uid,
  });

  final Recurring recurring;
  final Category? cat;
  final Wallet? wallet;
  final WidgetRef ref;
  final int uid;

  @override
  State<_RecurringCard> createState() => _RecurringCardState();
}

class _RecurringCardState extends State<_RecurringCard> {
  bool _saving = false;

  String _freqLabel(String freq) {
    switch (freq) {
      case 'daily':
        return 'Harian';
      case 'weekly':
        return 'Mingguan';
      case 'monthly':
        return 'Bulanan';
      case 'yearly':
        return 'Tahunan';
      default:
        return freq;
    }
  }

  DateTime _nextDate(DateTime current, String freq) {
    switch (freq) {
      case 'daily':
        return current.add(const Duration(days: 1));
      case 'weekly':
        return current.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(current.year, current.month + 1, current.day);
      case 'yearly':
        return DateTime(current.year + 1, current.month, current.day);
      default:
        return current.add(const Duration(days: 30));
    }
  }

  Future<void> _recordNow() async {
    if (_saving) return;
    setState(() => _saving = true);

    final r = widget.recurring;
    try {
      // Create the transaction
      await widget.ref.read(transactionRepoProvider).addTransaction(
            type: r.type,
            walletId: r.walletId,
            categoryId: r.categoryId,
            amount: r.amount,
            date: DateTime.now(),
            note: r.note,
            recordedBy: widget.uid,
          );

      // Advance nextRunDate
      final next = _nextDate(r.nextRunDate, r.freq);
      await widget.ref.read(recurringRepoProvider).upsert(
            RecurringsCompanion(
              id: Value(r.id),
              nextRunDate: Value(next),
              pendingSync: const Value(true),
            ),
          );

      if (mounted) {
        AppToast.show(context, 'Transaksi dicatat');
      }
    } catch (e) {
      if (kDebugMode) print('[Recurring] recordNow error: $e');
      if (mounted) {
        AppToast.show(context, 'Gagal mencatat transaksi', success: false);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _toggleAuto(bool value) async {
    try {
      await widget.ref.read(recurringRepoProvider).upsert(
            RecurringsCompanion(
              id: Value(widget.recurring.id),
              autoCreate: Value(value),
              pendingSync: const Value(true),
            ),
          );
    } catch (e) {
      if (kDebugMode) print('[Recurring] toggleAuto error: $e');
      if (mounted) {
        AppToast.show(context, 'Gagal mengubah pengaturan', success: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = widget.recurring;
    final isIncome = r.type == 'income';
    final amtColor = isIncome ? colors.income : colors.expense;
    final cat = widget.cat;
    final wallet = widget.wallet;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF142818).withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                if (cat != null)
                  CatIcon(iconKey: cat.icon, hue: cat.hue, size: 42)
                else
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: amtColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      isIncome
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: amtColor,
                      size: 20,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.note ?? cat?.name ?? 'Transaksi Berulang',
                        style: AppText.cardTitle(color: colors.text),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${wallet?.name ?? '-'} · ${_freqLabel(r.freq)}',
                        style: AppText.label(color: colors.text3),
                      ),
                    ],
                  ),
                ),
                Text(
                  fmtRp(r.amount),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: amtColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 12, color: colors.text3),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Berikutnya ${dayLabel(r.nextRunDate)}',
                    style: AppText.micro(color: colors.text3),
                  ),
                ),
                // Toggle Otomatis/Ingatkan
                GestureDetector(
                  onTap: () => _toggleAuto(!r.autoCreate),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: r.autoCreate
                          ? colors.primary.withValues(alpha: 0.12)
                          : colors.surface2,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            r.autoCreate ? colors.primary : colors.border,
                        width: r.autoCreate ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      r.autoCreate ? 'Otomatis' : 'Ingatkan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: r.autoCreate ? colors.primary : colors.text2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saving ? null : _recordNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: amtColor,
                    disabledBackgroundColor: colors.surface3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    elevation: 0,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: _saving
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Catat',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add Recurring Sheet
// ---------------------------------------------------------------------------

class _AddRecurringSheet extends StatefulWidget {
  const _AddRecurringSheet({required this.ref});
  final WidgetRef ref;

  @override
  State<_AddRecurringSheet> createState() => _AddRecurringSheetState();
}

class _AddRecurringSheetState extends State<_AddRecurringSheet> {
  final _noteCtrl = TextEditingController();
  String _type = 'expense';
  int _amount = 0;
  int? _categoryId;
  int? _walletId;
  String? _freq;

  static const _freqOptions = [
    (value: 'daily', label: 'Harian'),
    (value: 'weekly', label: 'Mingguan'),
    (value: 'monthly', label: 'Bulanan'),
    (value: 'yearly', label: 'Tahunan'),
  ];

  bool get _canSave =>
      _amount > 0 && _categoryId != null && _walletId != null && _freq != null;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_canSave) return;
    final now = DateTime.now();
    final pseudoId = now.millisecondsSinceEpoch % 2147483647;
    final uid = widget.ref.read(currentUserIdProvider).value ?? 1;

    await widget.ref.read(recurringRepoProvider).upsert(
          RecurringsCompanion.insert(
            id: Value(pseudoId),
            type: _type,
            walletId: _walletId!,
            categoryId: _categoryId!,
            amount: _amount,
            freq: _freq!,
            nextRunDate: now,
            autoCreate: false,
            note: Value(_noteCtrl.text.trim().isNotEmpty
                ? _noteCtrl.text.trim()
                : null),
            createdBy: uid,
            pendingSync: const Value(true),
          ),
        );

    if (mounted) {
      Navigator.of(context).pop();
      AppToast.show(context, 'Template berulang ditambahkan');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typeColor = _type == 'income' ? colors.income : colors.expense;
    final categoriesAsync = _type == 'income'
        ? widget.ref.watch(incomeCategoriesProvider)
        : widget.ref.watch(expenseCategoriesProvider);
    final walletsAsync = widget.ref.watch(walletsProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Tambah Template Berulang',
              style: AppText.sectionTitle(color: colors.text)),
          const SizedBox(height: 16),
          Text('Jenis', style: AppText.label(color: colors.text2)),
          const SizedBox(height: 6),
          SegmentedControl<String>(
            selected: _type,
            onChanged: (v) => setState(() {
              _type = v;
              _categoryId = null;
            }),
            activeColor: typeColor,
            items: const [
              SegmentItem(value: 'income', label: 'Pemasukan'),
              SegmentItem(value: 'expense', label: 'Pengeluaran'),
            ],
          ),
          const SizedBox(height: 14),
          AppTextInput(
            controller: _noteCtrl,
            label: 'Nama / Catatan',
            hint: 'mis. Gaji Bulanan',
            icon: Icons.edit_note_rounded,
          ),
          const SizedBox(height: 14),
          RupiahInput(
            label: 'Jumlah',
            onChanged: (v) => setState(() => _amount = v),
          ),
          const SizedBox(height: 14),
          Text('Kategori', style: AppText.label(color: colors.text2)),
          const SizedBox(height: 6),
          categoriesAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, st) => const SizedBox.shrink(),
            data: (cats) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cats.map((cat) {
                final isSel = _categoryId == cat.id;
                return GestureDetector(
                  onTap: () => setState(() => _categoryId = cat.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSel
                          ? typeColor.withValues(alpha: 0.12)
                          : colors.surface2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSel ? typeColor : colors.border,
                        width: isSel ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CatIcon(iconKey: cat.icon, hue: cat.hue, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          cat.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSel ? typeColor : colors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          Text('Dompet', style: AppText.label(color: colors.text2)),
          const SizedBox(height: 6),
          walletsAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, st) => const SizedBox.shrink(),
            data: (wallets) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: wallets.map((w) {
                  final isSel = _walletId == w.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _walletId = w.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel
                              ? typeColor.withValues(alpha: 0.12)
                              : colors.surface2,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSel ? typeColor : colors.border,
                            width: isSel ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          w.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSel ? typeColor : colors.text,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          ChipRow<String>(
            label: 'Frekuensi',
            items: _freqOptions,
            selected: _freq,
            onSelected: (v) => setState(() => _freq = v),
          ),
          const SizedBox(height: 20),
          SaveButton(
            label: 'Simpan Template',
            enabled: _canSave,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}



