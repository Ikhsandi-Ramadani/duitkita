import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/format.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../features/home/providers/home_providers.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/tx_row.dart';
import '../../ui/widgets/tx_type_meta.dart';

// ---------------------------------------------------------------------------
// Transactions Screen
// ---------------------------------------------------------------------------

/// Period filter options: 'semua' | 'hari-ini' | '7hari' | 'bulan'.
const _periodOptions = [
  ('semua', 'Semua tanggal'),
  ('hari-ini', 'Hari ini'),
  ('7hari', '7 hari terakhir'),
  ('bulan', 'Bulan ini'),
];

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _search = '';
  String? _typeFilter; // null = Semua
  String _period = 'semua';
  bool _periodOpen = false;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Period helpers
  // -------------------------------------------------------------------------

  String _periodLabel(String period) {
    return _periodOptions.firstWhere((o) => o.$1 == period).$2;
  }

  ({DateTime? from, DateTime? to}) _periodRange(String period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (period) {
      case 'hari-ini':
        return (from: today, to: today.add(const Duration(days: 1)));
      case '7hari':
        return (
          from: today.subtract(const Duration(days: 6)),
          to: today.add(const Duration(days: 1)),
        );
      case 'bulan':
        return (
          from: DateTime(now.year, now.month, 1),
          to: DateTime(now.year, now.month + 1, 1),
        );
      default:
        return (from: null, to: null);
    }
  }

  void _selectPeriod(String period) {
    setState(() {
      _period = period;
      _periodOpen = false;
    });
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final range = _periodRange(_period);
    final filters = TransactionFilters(
      type: _typeFilter,
      search: _search.isEmpty ? null : _search,
      dateFrom: range.from,
      dateTo: range.to,
    );

    final grouped = ref.watch(txGroupedProvider(filters));
    final hidden = ref.watch(balanceHiddenProvider).value ?? false;
    final hasActiveFilter =
        _typeFilter != null || _period != 'semua' || _search.isNotEmpty;

    return Scaffold(
      backgroundColor: colors.appBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: title + month eyebrow
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaksi',
                    style: AppText.screenTitle(color: colors.text),
                  ),
                  Text(
                    monthLabel(DateTime.now()).toUpperCase(),
                    style: AppText.micro(color: colors.text3)
                        .copyWith(letterSpacing: 0.8),
                  ),
                ],
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SearchBar(
                controller: _searchCtrl,
                colors: colors,
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
            const SizedBox(height: 10),
            // Period pill + dropdown, type chips, list
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Period pill
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _PeriodPill(
                          label: _periodLabel(_period),
                          active: _period != 'semua',
                          colors: colors,
                          onTap: () =>
                              setState(() => _periodOpen = !_periodOpen),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Type filter chips
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            _FilterChip(
                              label: 'Semua',
                              active: _typeFilter == null,
                              activeColor: colors.primary,
                              colors: colors,
                              onTap: () => setState(() => _typeFilter = null),
                            ),
                            const SizedBox(width: 6),
                            _FilterChip(
                              label: 'Keluar',
                              active: _typeFilter == 'expense',
                              activeColor: colors.expense,
                              colors: colors,
                              onTap: () => setState(() => _typeFilter =
                                  _typeFilter == 'expense' ? null : 'expense'),
                            ),
                            const SizedBox(width: 6),
                            _FilterChip(
                              label: 'Masuk',
                              active: _typeFilter == 'income',
                              activeColor: colors.income,
                              colors: colors,
                              onTap: () => setState(() => _typeFilter =
                                  _typeFilter == 'income' ? null : 'income'),
                            ),
                            const SizedBox(width: 6),
                            _FilterChip(
                              label: 'Transfer',
                              active: _typeFilter == 'transfer',
                              activeColor: colors.transfer,
                              colors: colors,
                              onTap: () => setState(() => _typeFilter =
                                  _typeFilter == 'transfer'
                                      ? null
                                      : 'transfer'),
                            ),
                            const SizedBox(width: 6),
                            _FilterChip(
                              label: 'Penyesuaian',
                              active: _typeFilter == 'adjustment',
                              activeColor: colors.adjust,
                              colors: colors,
                              onTap: () => setState(() => _typeFilter =
                                  _typeFilter == 'adjustment'
                                      ? null
                                      : 'adjustment'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // List
                      Expanded(
                        child: grouped.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Center(child: Text('Error: $e')),
                          data: (data) {
                            if (data.isEmpty) {
                              return EmptyState(
                                icon: Icons.receipt_long_outlined,
                                title: 'Belum ada transaksi',
                                sub: hasActiveFilter
                                    ? 'Tidak ada transaksi pada filter ini.'
                                    : 'Tambah transaksi pertamamu',
                              );
                            }

                            final sortedDays = data.keys.toList()
                              ..sort((a, b) => b.compareTo(a));

                            return ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: sortedDays.length,
                              itemBuilder: (_, i) {
                                final day = sortedDays[i];
                                final txs = data[day]!;
                                return _DayGroup(
                                  day: day,
                                  transactions: txs,
                                  hidden: hidden,
                                  onTapTx: (clientId) =>
                                      context.push('/transaction/$clientId'),
                                  ref: ref,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_periodOpen) ...[
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => setState(() => _periodOpen = false),
                      ),
                    ),
                    Positioned(
                      top: 44,
                      left: 20,
                      child: _PeriodDropdown(
                        selected: _period,
                        colors: colors,
                        onSelect: _selectPeriod,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Day group
// ---------------------------------------------------------------------------

class _DayGroup extends StatelessWidget {
  const _DayGroup({
    required this.day,
    required this.transactions,
    required this.hidden,
    required this.onTapTx,
    required this.ref,
  });

  final DateTime day;
  final List<Transaction> transactions;
  final bool hidden;
  final void Function(String clientId) onTapTx;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    // Net harian: income − expense (exclude transfer/adjustment)
    int netIncome = 0;
    int netExpense = 0;
    for (final tx in transactions) {
      if (tx.type == 'income') netIncome += tx.amount.abs();
      if (tx.type == 'expense') netExpense += tx.amount.abs();
    }
    final net = netIncome - netExpense;
    final netColor = net >= 0 ? colors.income : colors.expense;
    final netStr = net >= 0
        ? '+${fmtRp(net)}'
        : '−${fmtRp(net.abs())}';

    final members = ref.watch(membersProvider).value ?? [];
    final wallets = ref.watch(walletsProvider).value ?? [];
    final cats = ref.watch(categoriesProvider).value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              relDay(day),
              style: AppText.label(color: colors.text2),
            ),
            const Spacer(),
            Text(
              hidden ? '••••••' : netStr,
              style: AppText.label(color: netColor),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.borderRadiusSm,
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: transactions.asMap().entries.map((entry) {
              final idx = entry.key;
              final tx = entry.value;

              // Resolve metadata
              final cat = tx.categoryId != null
                  ? cats.firstWhereOrNull((c) => c.id == tx.categoryId)
                  : null;
              final wallet =
                  wallets.firstWhereOrNull((w) => w.id == tx.walletId);
              final recorder =
                  members.firstWhereOrNull((m) => m.id == tx.recordedBy);
              final spentByMember = tx.spentBy != null
                  ? members.firstWhereOrNull((m) => m.id == tx.spentBy)
                  : null;
              final targetWallet = tx.targetWalletId != null
                  ? wallets.firstWhereOrNull((w) => w.id == tx.targetWalletId)
                  : null;

              // For transfer: title = "walletA → walletB"
              final walletName = tx.type == 'transfer'
                  ? '${wallet?.name ?? ''} → ${targetWallet?.name ?? ''}'
                  : (wallet?.name ?? '');

              final txMeta = TxTypeMeta.of(tx.type, context.appColors);

              return Column(
                children: [
                  if (idx > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(
                          height: 1, thickness: 1, color: colors.border),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: TxRow(
                      type: tx.type,
                      categoryName: cat?.name ?? txMeta.label,
                      categoryIconKey: cat?.icon ?? _typeIconKey(tx.type),
                      categoryHue:
                          cat?.hue ?? _typeHue(tx.type, context.appColors),
                      recorderInitial: recorder?.name ?? '?',
                      recorderHue: recorder?.avatarHue ?? 162,
                      title: cat?.name ?? txMeta.label,
                      walletName: walletName,
                      note: tx.note,
                      spentByName: spentByMember?.name,
                      amount: tx.amount,
                      hidden: hidden,
                      time: timeLabel(tx.date),
                      onTap: () => onTapTx(tx.clientId),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _typeIconKey(String type) {
    switch (type) {
      case 'income':
        return 'briefcase';
      case 'transfer':
        return 'dots';
      case 'adjustment':
        return 'dots';
      default:
        return 'dots';
    }
  }

  int _typeHue(String type, AppColors colors) {
    switch (type) {
      case 'income':
        return 162;
      case 'transfer':
        return 210;
      case 'adjustment':
        return 40;
      default:
        return 24;
    }
  }
}

// ---------------------------------------------------------------------------
// Search bar widget
// ---------------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.colors,
    required this.onChanged,
  });

  final TextEditingController controller;
  final AppColors colors;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search_rounded, color: colors.text3, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppText.body(color: colors.text),
              decoration: InputDecoration(
                hintText: 'Cari catatan, kategori, nominal...',
                hintStyle: AppText.body(color: colors.text3),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged('');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child:
                    Icon(Icons.close_rounded, color: colors.text3, size: 18),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chip
// ---------------------------------------------------------------------------

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.activeColor,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final bool active;
  final Color activeColor;
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? activeColor : colors.surface,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: active ? activeColor : colors.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : colors.text2,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Period pill
// ---------------------------------------------------------------------------

class _PeriodPill extends StatelessWidget {
  const _PeriodPill({
    required this.label,
    required this.active,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final bool active;
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: active ? colors.primaryTint : colors.surface,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: active ? colors.primary : colors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: active ? colors.primary : colors.text2,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? colors.primary : colors.text2,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: active ? colors.primary : colors.text3,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Period dropdown
// ---------------------------------------------------------------------------

class _PeriodDropdown extends StatelessWidget {
  const _PeriodDropdown({
    required this.selected,
    required this.colors,
    required this.onSelect,
  });

  final String selected;
  final AppColors colors;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 224,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.borderRadiusSm,
          border: Border.all(color: colors.border2),
          boxShadow: AppShadows.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _periodOptions.length; i++) ...[
              if (i > 0) const SizedBox(height: 2),
              _PeriodDropdownItem(
                label: _periodOptions[i].$2,
                active: selected == _periodOptions[i].$1,
                colors: colors,
                onTap: () => onSelect(_periodOptions[i].$1),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PeriodDropdownItem extends StatelessWidget {
  const _PeriodDropdownItem({
    required this.label,
    required this.active,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final bool active;
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? colors.primaryTint : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: active ? colors.primary : colors.text2,
              ),
            ),
            if (active)
              Icon(Icons.check_rounded, size: 16, color: colors.primary),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

extension _ListExt<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
