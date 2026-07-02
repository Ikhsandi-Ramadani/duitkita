import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../ui/widgets/app_sheet.dart';
import '../../ui/widgets/app_toast.dart';
import '../../ui/widgets/cat_icon.dart';

// ---------------------------------------------------------------------------
// Provider — async create/delete backed by API + local DB
// ---------------------------------------------------------------------------

final _createCategoryProvider =
    Provider<Future<void> Function(Map<String, dynamic>)>((ref) {
  return (body) async {
    final api = ref.read(apiClientProvider);
    final repo = ref.read(categoryRepoProvider);
    final data = await api.createCategory(body);
    await repo.upsert(CategoriesCompanion(
      id: Value(data['id'] as int),
      name: Value(data['name'] as String),
      type: Value(data['type'] as String),
      icon: Value(data['icon'] as String? ?? 'shopping_cart'),
      hue: Value((data['hue'] as num?)?.toInt() ?? 0),
      parentId: const Value(null),
    ));
  };
});

final _deleteCategoryProvider =
    Provider<Future<void> Function(int)>((ref) {
  return (id) async {
    final api = ref.read(apiClientProvider);
    final repo = ref.read(categoryRepoProvider);
    await api.deleteCategory(id);
    await repo.deleteById(id);
  };
});

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: colors.appBg,
      appBar: AppBar(
        backgroundColor: colors.appBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: colors.text, size: 18),
        ),
        title: Text(
          'Kelola Kategori',
          style: AppText.cardTitle(color: colors.text),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => _showAddSheet(context),
              icon: Icon(Icons.add_rounded, color: colors.primary, size: 24),
              tooltip: 'Tambah kategori',
            ),
          ),
        ],
      ),
      body: categoriesAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(strokeWidth: 2)),
        error: (e, _) => Center(
          child: Text('Gagal memuat kategori',
              style: AppText.body(color: colors.text3)),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return _EmptyState(onAdd: () => _showAddSheet(context));
          }

          final expense =
              categories.where((c) => c.type == 'expense').toList();
          final income =
              categories.where((c) => c.type == 'income').toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            children: [
              if (expense.isNotEmpty) ...[
                _GroupHeader(
                    label: 'PENGELUARAN', color: colors.expense),
                const SizedBox(height: 8),
                _CategoryGroup(
                    categories: expense, type: 'expense'),
                const SizedBox(height: 20),
              ],
              if (income.isNotEmpty) ...[
                _GroupHeader(
                    label: 'PEMASUKAN', color: colors.income),
                const SizedBox(height: 8),
                _CategoryGroup(
                    categories: income, type: 'income'),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 2,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    AppSheet.show(
      context: context,
      child: const _AddCategorySheet(),
    );
  }
}

// ---------------------------------------------------------------------------
// Group header
// ---------------------------------------------------------------------------

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Category group card with swipe-to-delete
// ---------------------------------------------------------------------------

class _CategoryGroup extends ConsumerWidget {
  const _CategoryGroup(
      {required this.categories, required this.type});
  final List<Category> categories;
  final String type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.borderRadiusBase,
        border: Border.all(color: colors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: categories.asMap().entries.map((entry) {
          final idx = entry.key;
          final cat = entry.value;
          return Column(
            children: [
              _CategoryTile(category: cat),
              if (idx < categories.length - 1)
                Divider(height: 1, color: colors.border, indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Single category tile with dismiss
// ---------------------------------------------------------------------------

class _CategoryTile extends ConsumerStatefulWidget {
  const _CategoryTile({required this.category});
  final Category category;

  @override
  ConsumerState<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends ConsumerState<_CategoryTile> {
  bool _deleting = false;

  Future<void> _confirmDelete() async {
    final colors = context.appColors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Hapus Kategori',
            style: AppText.cardTitle(color: colors.text)),
        content: Text(
          'Hapus "${widget.category.name}"? Transaksi yang menggunakan kategori ini tidak akan terpengaruh.',
          style: AppText.body(color: colors.text2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Batal',
                style: AppText.body(color: colors.text2)
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Hapus',
                style: AppText.body(color: colors.expense)
                    .copyWith(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _deleting = true);
      try {
        await ref.read(_deleteCategoryProvider)(widget.category.id);
        if (mounted) {
          AppToast.show(context, '"${widget.category.name}" dihapus');
        }
      } catch (e) {
        if (kDebugMode) print('[Categories] delete error: $e');
        if (mounted) {
          setState(() => _deleting = false);
          AppToast.show(context, 'Gagal menghapus. Coba lagi.');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final cat = widget.category;
    final hueColor =
        HSLColor.fromAHSL(1, cat.hue.toDouble(), 0.65, 0.50).toColor();
    final iconData =
        CatIcon.iconMap[cat.icon] ?? Icons.label_outline_rounded;

    return Dismissible(
      key: ValueKey(cat.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await _confirmDelete();
        return false; // We handle deletion manually to keep UI in sync
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: colors.expenseTint,
          borderRadius: AppRadius.borderRadiusBase,
        ),
        child: Icon(Icons.delete_outline_rounded,
            color: colors.expense, size: 22),
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            // Icon container with hue color
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: hueColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(iconData, color: hueColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                cat.name,
                style: AppText.body(color: colors.text)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            // Hue color dot
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: hueColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            if (_deleting)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              GestureDetector(
                onTap: _confirmDelete,
                child: Icon(Icons.delete_outline_rounded,
                    color: colors.text3, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.category_outlined,
              size: 56, color: colors.text3),
          const SizedBox(height: 16),
          Text('Belum ada kategori',
              style: AppText.cardTitle(color: colors.text2)),
          const SizedBox(height: 6),
          Text(
            'Tambahkan kategori untuk mengorganisir transaksi',
            style: AppText.body(color: colors.text3),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Tambah Kategori'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm)),
              textStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add category bottom sheet
// ---------------------------------------------------------------------------

class _AddCategorySheet extends ConsumerStatefulWidget {
  const _AddCategorySheet();

  @override
  ConsumerState<_AddCategorySheet> createState() =>
      _AddCategorySheetState();
}

class _AddCategorySheetState extends ConsumerState<_AddCategorySheet> {
  final _nameCtrl = TextEditingController();
  String _type = 'expense';
  String _selectedIcon = 'shopping_cart';
  double _selectedHue = 0;
  bool _saving = false;
  String? _errorMsg;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  bool get _canSave => _nameCtrl.text.trim().isNotEmpty && !_saving;

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() {
      _saving = true;
      _errorMsg = null;
    });

    try {
      await ref.read(_createCategoryProvider)({
        'name': _nameCtrl.text.trim(),
        'type': _type,
        'icon': _selectedIcon,
        'hue': _selectedHue.round(),
      });

      if (mounted) {
        Navigator.of(context).pop();
        AppToast.show(
            context, 'Kategori "${_nameCtrl.text.trim()}" ditambahkan');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _errorMsg = 'Gagal menyimpan. Periksa koneksi internet.';
        });
      }
    }
  }

  InputDecoration _fieldDecoration(AppColors colors, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppText.body(color: colors.text3),
      filled: true,
      fillColor: colors.surface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: colors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final previewHue =
        HSLColor.fromAHSL(1, _selectedHue, 0.65, 0.50).toColor();
    final previewIcon =
        CatIcon.iconMap[_selectedIcon] ?? Icons.label_outline_rounded;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + preview icon
          Row(
            children: [
              Expanded(
                child: Text('Tambah Kategori',
                    style: AppText.screenTitle(color: colors.text)),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: previewHue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    Icon(previewIcon, color: previewHue, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Type toggle ─────────────────────────────────────────────────
          Text('Jenis', style: AppText.label(color: colors.text2)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: colors.surface2,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                _TypeToggleBtn(
                  label: 'Pengeluaran',
                  selected: _type == 'expense',
                  selectedColor: colors.expense,
                  onTap: () => setState(() {
                    _type = 'expense';
                    _selectedIcon = 'shopping_cart';
                  }),
                ),
                _TypeToggleBtn(
                  label: 'Pemasukan',
                  selected: _type == 'income',
                  selectedColor: colors.income,
                  onTap: () => setState(() {
                    _type = 'income';
                    _selectedIcon = 'attach_money';
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Name ────────────────────────────────────────────────────────
          Text('Nama Kategori',
              style: AppText.label(color: colors.text2)),
          const SizedBox(height: 6),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            style: AppText.body(color: colors.text),
            decoration: _fieldDecoration(colors, 'Contoh: Makan siang'),
            onChanged: (_) => setState(() {}),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),

          // ── Icon picker ─────────────────────────────────────────────────
          Text('Ikon', style: AppText.label(color: colors.text2)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: CatIcon.iconMap.entries.map((entry) {
              final isSelected = _selectedIcon == entry.key;
              final hueColor = HSLColor.fromAHSL(
                      1, _selectedHue, 0.65, 0.50)
                  .toColor();
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedIcon = entry.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? hueColor.withValues(alpha: 0.18)
                        : colors.surface2,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: isSelected ? hueColor : colors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Icon(
                    entry.value,
                    size: 20,
                    color: isSelected ? hueColor : colors.text3,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // ── Hue slider ──────────────────────────────────────────────────
          Row(
            children: [
              Text('Warna',
                  style: AppText.label(color: colors.text2)),
              const Spacer(),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: previewHue,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 18),
              activeTrackColor: previewHue,
              thumbColor: previewHue,
              inactiveTrackColor: colors.border2,
              overlayColor: previewHue.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: _selectedHue,
              min: 0,
              max: 360,
              onChanged: (v) => setState(() => _selectedHue = v),
            ),
          ),
          const SizedBox(height: 16),

          // ── Error ───────────────────────────────────────────────────────
          if (_errorMsg != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                    color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Text(_errorMsg!,
                  style: AppText.micro(color: Colors.red)),
            ),
            const SizedBox(height: 12),
          ],

          // ── Save button ─────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _canSave ? _save : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                disabledBackgroundColor: colors.surface3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.base),
                ),
                elevation: 0,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Simpan',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Type toggle button
// ---------------------------------------------------------------------------

class _TypeToggleBtn extends StatelessWidget {
  const _TypeToggleBtn({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.all(3),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? selectedColor.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm - 2),
            border: selected
                ? Border.all(
                    color: selectedColor.withValues(alpha: 0.4))
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: selected ? selectedColor : colors.text3,
            ),
          ),
        ),
      ),
    );
  }
}
