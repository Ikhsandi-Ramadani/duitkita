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
import '../../data/repositories/transaction_repository.dart';
import '../../ui/widgets/app_progress_bar.dart';
import '../../ui/widgets/app_sheet.dart';
import '../../ui/widgets/app_toast.dart';
import '../../ui/widgets/app_top_bar.dart';
import '../../ui/widgets/cat_icon.dart';
import '../../ui/widgets/empty_state.dart';
import '../goals/widgets/form_inputs.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final now = DateTime.now();
    final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final monthTitle = 'Anggaran ${monthLabel(now)}';

    final budgetsAsync = ref.watch(budgetsByMonthProvider(monthKey));
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: colors.appBg,
      appBar: AppTopBar(
        title: monthTitle,
        action: IconButton(
          icon: Icon(Icons.add_rounded, color: colors.primary, size: 24),
          onPressed: () => _showAddBudgetSheet(context, ref, monthKey),
          splashRadius: 20,
        ),
      ),
      body: budgetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Gagal memuat',
          sub: e.toString(),
        ),
        data: (budgets) => categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Gagal memuat kategori',
          ),
          data: (categories) => _BudgetBody(
            budgets: budgets,
            categories: categories,
            monthKey: monthKey,
            ref: ref,
            onAddBudget: () => _showAddBudgetSheet(context, ref, monthKey),
          ),
        ),
      ),
    );
  }

  void _showAddBudgetSheet(
      BuildContext context, WidgetRef ref, String monthKey) {
    AppSheet.show(
      context: context,
      child: _AddBudgetSheet(monthKey: monthKey, ref: ref),
    );
  }
}

class _BudgetBody extends StatefulWidget {
  const _BudgetBody({
    required this.budgets,
    required this.categories,
    required this.monthKey,
    required this.ref,
    required this.onAddBudget,
  });

  final List<Budget> budgets;
  final List<Category> categories;
  final String monthKey;
  final WidgetRef ref;
  final VoidCallback onAddBudget;

  @override
  State<_BudgetBody> createState() => _BudgetBodyState();
}

class _BudgetBodyState extends State<_BudgetBody> {
  List<CategoryTotal> _catTotals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTotals();
  }

  @override
  void didUpdateWidget(_BudgetBody old) {
    super.didUpdateWidget(old);
    _loadTotals();
  }

  Future<void> _loadTotals() async {
    final repo = widget.ref.read(transactionRepoProvider);
    final totals = await repo.monthlyExpenseByCategory(widget.monthKey);
    if (mounted) setState(() { _catTotals = totals; _loading = false; });
  }

  Future<bool?> _confirmDelete(BuildContext context, Budget budget) {
    final colors = context.appColors;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Anggaran',
          style: AppText.sectionTitle(color: colors.text),
        ),
        content: Text(
          'Hapus anggaran ini?',
          style: AppText.label(color: colors.text2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Batal', style: TextStyle(color: colors.text2)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Hapus',
              style: TextStyle(color: colors.expense, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBudget(Budget budget) async {
    final repo = widget.ref.read(budgetRepoProvider);
    final api = widget.ref.read(apiClientProvider);
    try {
      await api.deleteBudget(budget.id);
    } catch (e) {
      // Silently continue — delete locally even if API fails (offline-first)
      if (kDebugMode) print('[Budget] deleteBudget error: $e');
    }
    await repo.delete(budget.id);
    if (mounted) {
      AppToast.show(context, 'Anggaran dihapus');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (_loading) return const Center(child: CircularProgressIndicator());

    final catMap = {for (final c in widget.categories) c.id: c};
    final totalBudget = widget.budgets.fold(0, (s, b) => s + b.amount);
    final spentMap = {for (final t in _catTotals) t.categoryId: t.total};
    final totalSpent = _catTotals.fold(0, (s, t) => s + t.total);
    final sisa = totalBudget - totalSpent;
    final overallFraction =
        totalBudget > 0 ? totalSpent / totalBudget : 0.0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        // Emerald summary card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF058564), Color(0xFF036249)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF047857).withValues(alpha: 0.32),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Anggaran', style: AppText.label(color: Colors.white.withValues(alpha: 0.8))),
              const SizedBox(height: 4),
              Text(
                fmtRp(totalBudget),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Terpakai', style: AppText.micro(color: Colors.white.withValues(alpha: 0.75))),
                        Text(
                          fmtRp(totalSpent),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sisa', style: AppText.micro(color: Colors.white.withValues(alpha: 0.75))),
                        Text(
                          fmtRp(sisa),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: sisa < 0
                                ? const Color(0xFFFFB3A0)
                                : Colors.white,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AppProgressBar(
                fraction: overallFraction,
                height: 7,
                normalColor: Colors.white.withValues(alpha: 0.9),
                overColor: const Color(0xFFFFB3A0),
                trackColor: Colors.white.withValues(alpha: 0.25),
                radius: 4,
              ),
              const SizedBox(height: 6),
              Text(
                '${(overallFraction * 100).toStringAsFixed(0)}% terpakai',
                style: AppText.micro(color: Colors.white.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        if (widget.budgets.isEmpty)
          EmptyState(
            icon: Icons.tune_rounded,
            title: 'Belum ada anggaran',
            sub: 'Tap + untuk menambah anggaran per kategori',
          )
        else ...[
          Text('Per Kategori', style: AppText.sectionTitle(color: colors.text)),
          const SizedBox(height: 12),
          ...widget.budgets.map((budget) {
            final cat = catMap[budget.categoryId];
            final spent = spentMap[budget.categoryId] ?? 0;
            final fraction = budget.amount > 0 ? spent / budget.amount : 0.0;
            final pct = (fraction * 100).toStringAsFixed(0);
            final isOver = fraction > 1.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Dismissible(
                key: ValueKey(budget.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) async {
                  final confirmed = await _confirmDelete(context, budget);
                  if (confirmed == true) {
                    await _deleteBudget(budget);
                    return true;
                  }
                  return false;
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: colors.expense,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
                      SizedBox(height: 4),
                      Text('Hapus', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                child: GestureDetector(
                  onLongPress: () async {
                    final confirmed = await _confirmDelete(context, budget);
                    if (confirmed == true) {
                      await _deleteBudget(budget);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.border),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF142818).withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        if (cat != null)
                          CatIcon(iconKey: cat.icon, hue: cat.hue, size: 40)
                        else
                          const SizedBox(width: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      cat?.name ?? 'Kategori #${budget.categoryId}',
                                      style: AppText.cardTitle(color: colors.text),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '$pct%',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isOver ? colors.expense : colors.text2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${fmtRp(spent)} / ${fmtRp(budget.amount)}',
                                style: AppText.label(color: colors.text2),
                              ),
                              const SizedBox(height: 8),
                              AppProgressBar(
                                fraction: fraction,
                                height: 5,
                                normalColor: colors.primary,
                                overColor: colors.expense,
                                radius: 3,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Add Budget Sheet
// ---------------------------------------------------------------------------

class _AddBudgetSheet extends StatefulWidget {
  const _AddBudgetSheet({required this.monthKey, required this.ref});
  final String monthKey;
  final WidgetRef ref;

  @override
  State<_AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends State<_AddBudgetSheet> {
  int _amount = 0;
  Category? _selectedCat;

  bool get _canSave => _amount > 0 && _selectedCat != null;

  Future<void> _save() async {
    if (!_canSave) return;
    final repo = widget.ref.read(budgetRepoProvider);
    // Generate a pseudo-id from category + month for upsert
    final id = int.parse(
      '${_selectedCat!.id}${widget.monthKey.replaceAll('-', '')}',
    );
    await repo.upsert(BudgetsCompanion.insert(
      id: Value(id),
      scope: 'family',
      categoryId: _selectedCat!.id,
      amount: _amount,
      periodMonth: widget.monthKey,
    ));
    if (mounted) {
      Navigator.of(context).pop();
      AppToast.show(context, 'Anggaran disimpan');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final expCatsAsync = widget.ref.watch(expenseCategoriesProvider);

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
          Text('Tambah Anggaran', style: AppText.sectionTitle(color: colors.text)),
          const SizedBox(height: 16),
          Text('Pilih Kategori', style: AppText.label(color: colors.text2)),
          const SizedBox(height: 8),
          expCatsAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, st) => const SizedBox.shrink(),
            data: (cats) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cats.map((cat) {
                final isSelected = _selectedCat?.id == cat.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCat = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CatIcon(iconKey: cat.icon, hue: cat.hue, size: 22),
                        const SizedBox(width: 6),
                        Text(
                          cat.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? colors.primary : colors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          RupiahInput(
            label: 'Jumlah Anggaran',
            onChanged: (v) => setState(() => _amount = v),
          ),
          const SizedBox(height: 20),
          SaveButton(
            label: 'Simpan Anggaran',
            enabled: _canSave,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

