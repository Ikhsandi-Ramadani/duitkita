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
import '../../ui/widgets/app_sheet.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/member_avatar.dart';
import '../../ui/widgets/tx_row.dart';
import '../../ui/widgets/tx_type_meta.dart';

// ---------------------------------------------------------------------------
// Transactions Screen
// ---------------------------------------------------------------------------

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _search = '';
  String? _typeFilter; // null = Semua
  int? _memberFilter; // null = Semua
  String? _monthFilter; // null = all time, 'YYYY-MM' = specific month
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Month helpers
  // -------------------------------------------------------------------------

  String _formatMonth(String ym) {
    final parts = ym.split('-');
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${months[int.parse(parts[1]) - 1]} ${parts[0]}';
  }

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    final months = List.generate(12, (i) {
      final d = DateTime(now.year, now.month - i);
      return '${d.year}-${d.month.toString().padLeft(2, '0')}';
    });

    final picked = await AppSheet.show<String?>(
      context: context,
      child: _MonthPickerSheet(months: months, selected: _monthFilter),
    );
    if (mounted) {
      setState(() => _monthFilter = (picked == null || picked == '') ? null : picked);
    }
  }

  // -------------------------------------------------------------------------
  // Member picker sheet
  // -------------------------------------------------------------------------

  Future<void> _pickMember() async {
    final members = ref.read(membersProvider).value ?? [];

    final picked = await AppSheet.show<int?>(
      context: context,
      child: _MemberFilterSheet(
        members: members,
        selected: _memberFilter,
      ),
    );

    if (mounted && picked != null) {
      // -1 = Semua anggota
      setState(() => _memberFilter = picked == -1 ? null : picked);
    }
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final filters = TransactionFilters(
      type: _typeFilter,
      memberId: _memberFilter,
      search: _search.isEmpty ? null : _search,
      month: _monthFilter,
    );

    final grouped = ref.watch(txGroupedProvider(filters));
    final hidden = ref.watch(balanceHiddenProvider).value ?? false;

    return Scaffold(
      backgroundColor: colors.appBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                'Transaksi',
                style: AppText.screenTitle(color: colors.text),
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
            // Filter chips
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
                    onTap: () => setState(() =>
                        _typeFilter = _typeFilter == 'expense' ? null : 'expense'),
                  ),
                  const SizedBox(width: 6),
                  _FilterChip(
                    label: 'Masuk',
                    active: _typeFilter == 'income',
                    activeColor: colors.income,
                    colors: colors,
                    onTap: () => setState(() =>
                        _typeFilter = _typeFilter == 'income' ? null : 'income'),
                  ),
                  const SizedBox(width: 6),
                  _FilterChip(
                    label: 'Transfer',
                    active: _typeFilter == 'transfer',
                    activeColor: colors.transfer,
                    colors: colors,
                    onTap: () => setState(() =>
                        _typeFilter =
                            _typeFilter == 'transfer' ? null : 'transfer'),
                  ),
                  const SizedBox(width: 6),
                  _FilterChip(
                    label: 'Penyesuaian',
                    active: _typeFilter == 'adjustment',
                    activeColor: colors.adjust,
                    colors: colors,
                    onTap: () => setState(() =>
                        _typeFilter =
                            _typeFilter == 'adjustment' ? null : 'adjustment'),
                  ),
                  const SizedBox(width: 6),
                  _FilterChip(
                    label: _memberFilter == null ? 'Anggota' : _memberName(),
                    active: _memberFilter != null,
                    activeColor: colors.primary,
                    colors: colors,
                    onTap: _pickMember,
                  ),
                  const SizedBox(width: 6),
                  _FilterChip(
                    label: _monthFilter == null
                        ? 'Semua Bulan'
                        : _formatMonth(_monthFilter!),
                    active: _monthFilter != null,
                    activeColor: colors.primary,
                    colors: colors,
                    onTap: _pickMonth,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // List
            Expanded(
              child: grouped.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (data) {
                  if (data.isEmpty) {
                    return const EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'Belum ada transaksi',
                      sub: 'Tambah transaksi pertamamu',
                    );
                  }

                  final sortedDays = data.keys.toList()
                    ..sort((a, b) => b.compareTo(a));

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
      ),
    );
  }

  String _memberName() {
    final members = ref.read(membersProvider).value ?? [];
    return members.firstWhere((m) => m.id == _memberFilter,
        orElse: () => const Member(
              id: 0,
              name: 'Anggota',
              email: '',
              role: '',
              avatarHue: 0,
            )).name;
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
            borderRadius: AppRadius.borderRadiusBase,
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
                    child: Row(
                      children: [
                        Expanded(
                          child: TxRow(
                            type: tx.type,
                            categoryName: cat?.name ?? txMeta.label,
                            categoryIconKey: cat?.icon ?? _typeIconKey(tx.type),
                            categoryHue: cat?.hue ?? _typeHue(tx.type, context.appColors),
                            recorderInitial: recorder?.name ?? '?',
                            recorderHue: recorder?.avatarHue ?? 162,
                            title: cat?.name ?? txMeta.label,
                            walletName: walletName,
                            note: tx.note,
                            spentByName: spentByMember?.name,
                            amount: tx.amount,
                            hidden: hidden,
                            onTap: () => onTapTx(tx.clientId),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Time
                        Text(
                          timeLabel(tx.date),
                          style: AppText.micro(color: colors.text3),
                        ),
                      ],
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
// Member filter sheet
// ---------------------------------------------------------------------------

class _MemberFilterSheet extends StatelessWidget {
  const _MemberFilterSheet({
    required this.members,
    required this.selected,
  });

  final List<Member> members;
  final int? selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Text('Filter Anggota',
              style: AppText.cardTitle(color: colors.text)),
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.surface2,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.group_outlined, color: colors.text3, size: 18),
          ),
          title: Text('Semua anggota', style: AppText.body(color: colors.text)),
          trailing: selected == null
              ? Icon(Icons.check_rounded, color: colors.primary)
              : null,
          onTap: () => Navigator.of(context).pop(-1),
        ),
        ...members.map(
          (m) => ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            leading: MemberAvatar(
                hue: m.avatarHue, initial: m.name, size: 36),
            title: Text(m.name, style: AppText.body(color: colors.text)),
            trailing: selected == m.id
                ? Icon(Icons.check_rounded, color: colors.primary)
                : null,
            onTap: () => Navigator.of(context).pop(m.id),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Month picker sheet
// ---------------------------------------------------------------------------

class _MonthPickerSheet extends StatelessWidget {
  const _MonthPickerSheet({
    required this.months,
    required this.selected,
  });

  final List<String> months;
  final String? selected;

  String _label(String ym) {
    final parts = ym.split('-');
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${names[int.parse(parts[1]) - 1]} ${parts[0]}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Text('Filter Bulan',
              style: AppText.cardTitle(color: colors.text)),
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.surface2,
              shape: BoxShape.circle,
            ),
            child:
                Icon(Icons.calendar_today_outlined, color: colors.text3, size: 18),
          ),
          title:
              Text('Semua Bulan', style: AppText.body(color: colors.text)),
          trailing: selected == null
              ? Icon(Icons.check_rounded, color: colors.primary)
              : null,
          onTap: () => Navigator.of(context).pop(''),
        ),
        ...months.map(
          (ym) => ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.surface2,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.calendar_month_outlined,
                  color: colors.text3, size: 18),
            ),
            title: Text(_label(ym), style: AppText.body(color: colors.text)),
            trailing: selected == ym
                ? Icon(Icons.check_rounded, color: colors.primary)
                : null,
            onTap: () => Navigator.of(context).pop(ym),
          ),
        ),
        const SizedBox(height: 16),
      ],
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
