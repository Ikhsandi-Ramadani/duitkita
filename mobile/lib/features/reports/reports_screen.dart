import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/format.dart';
import '../../data/providers.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../ui/widgets/app_progress_bar.dart';
import '../../ui/widgets/app_top_bar.dart';
import '../../ui/widgets/member_avatar.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);

  String get _monthKey =>
      '${_month.year}-${_month.month.toString().padLeft(2, '0')}';

  // Computed async state
  MonthlyTotal? _totals;
  List<CategoryTotal> _catTotals = [];
  List<MemberExpense> _memberExpenses = [];
  List<MonthlyTotal?> _sixMonths = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final txRepo = ref.read(transactionRepoProvider);

    final results = await Future.wait([
      txRepo.monthlyTotals(_monthKey),
      txRepo.monthlyExpenseByCategory(_monthKey),
      txRepo.monthlyExpenseByMember(_monthKey),
    ]);

    final sixMonthFutures = List.generate(6, (i) {
      final m = DateTime(_month.year, _month.month - 5 + i, 1);
      final key = '${m.year}-${m.month.toString().padLeft(2, '0')}';
      return txRepo.monthlyTotals(key);
    });
    final sixData = await Future.wait(sixMonthFutures);

    if (mounted) {
      setState(() {
        _totals = results[0] as MonthlyTotal;
        _catTotals = results[1] as List<CategoryTotal>;
        _memberExpenses = results[2] as List<MemberExpense>;
        _sixMonths = sixData.cast<MonthlyTotal?>();
        _loading = false;
      });
    }
  }

  void _prevMonth() {
    setState(() {
      _month = DateTime(_month.year, _month.month - 1, 1);
    });
    _loadData();
  }

  void _nextMonth() {
    final now = DateTime.now();
    final next = DateTime(_month.year, _month.month + 1, 1);
    if (next.isAfter(DateTime(now.year, now.month, 1))) return;
    setState(() => _month = next);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final categories = ref.watch(categoriesProvider).value ?? [];
    final members = ref.watch(membersProvider).value ?? [];
    final catMap = {for (final c in categories) c.id: c};
    final memberMap = {for (final m in members) m.id: m};

    return Scaffold(
      backgroundColor: colors.appBg,
      appBar: AppTopBar(
        title: 'Laporan',
        action: const SizedBox(width: 48),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // Month picker
          _MonthPicker(
            month: _month,
            onPrev: _prevMonth,
            onNext: _nextMonth,
          ),
          const SizedBox(height: 16),

          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            // Income / Expense summary cards
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'Pemasukan',
                    amount: _totals?.income ?? 0,
                    color: colors.income,
                    tint: colors.incomeTint,
                    icon: Icons.arrow_downward_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    label: 'Pengeluaran',
                    amount: _totals?.expense ?? 0,
                    color: colors.expense,
                    tint: colors.expenseTint,
                    icon: Icons.arrow_upward_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Donut chart — expense by category
            if (_catTotals.isNotEmpty) ...[
              Text('Pengeluaran per Kategori',
                  style: AppText.sectionTitle(color: colors.text)),
              const SizedBox(height: 12),
              _DonutChart(
                catTotals: _catTotals,
                catMap: catMap,
                totalExpense: _totals?.expense ?? 0,
              ),
              const SizedBox(height: 20),
            ],

            // Bar chart — 6-month cashflow
            Text('Arus Kas 6 Bulan',
                style: AppText.sectionTitle(color: colors.text)),
            const SizedBox(height: 12),
            _CashflowBarChart(
              months: _sixMonths,
              currentMonth: _month,
              colors: colors,
            ),
            const SizedBox(height: 20),

            // Per-member expense
            if (_memberExpenses.isNotEmpty) ...[
              Text('Pengeluaran per Anggota',
                  style: AppText.sectionTitle(color: colors.text)),
              const SizedBox(height: 12),
              _MemberExpenseList(
                memberExpenses: _memberExpenses,
                memberMap: memberMap,
                totalExpense: _totals?.expense ?? 0,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _MonthPicker extends StatelessWidget {
  const _MonthPicker({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final now = DateTime.now();
    final isCurrentMonth =
        month.year == now.year && month.month == now.month;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left_rounded, color: colors.text2),
            onPressed: onPrev,
            splashRadius: 18,
          ),
          Text(
            monthLabel(month),
            style: AppText.cardTitle(color: colors.text),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right_rounded,
              color: isCurrentMonth ? colors.text3 : colors.text2,
            ),
            onPressed: isCurrentMonth ? null : onNext,
            splashRadius: 18,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.tint,
    required this.icon,
  });

  final String label;
  final int amount;
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
              Icon(icon, color: color, size: 13),
              const SizedBox(width: 4),
              Text(label, style: AppText.micro(color: color.withValues(alpha: 0.85))),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            fmtShort(amount),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutChart extends StatefulWidget {
  const _DonutChart({
    required this.catTotals,
    required this.catMap,
    required this.totalExpense,
  });

  final List<CategoryTotal> catTotals;
  final Map<int, dynamic> catMap;
  final int totalExpense;

  @override
  State<_DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<_DonutChart> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final sections = widget.catTotals.asMap().entries.map((entry) {
      final i = entry.key;
      final ct = entry.value;
      final cat = widget.catMap[ct.categoryId];
      final hue = cat?.hue ?? (30 + i * 30) % 360;
      final pct = widget.totalExpense > 0
          ? (ct.total / widget.totalExpense * 100).toStringAsFixed(0)
          : '0';
      final isTouched = i == _touched;
      final color = HSLColor.fromAHSL(1.0, hue.toDouble(), 0.55, 0.45).toColor();

      return PieChartSectionData(
        color: color,
        value: ct.total.toDouble(),
        title: isTouched ? '$pct%' : '',
        radius: isTouched ? 60 : 52,
        titleStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 56,
                    sectionsSpace: 2,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              response == null ||
                              response.touchedSection == null) {
                            _touched = -1;
                          } else {
                            _touched =
                                response.touchedSection!.touchedSectionIndex;
                          }
                        });
                      },
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total',
                      style: AppText.micro(color: colors.text3),
                    ),
                    Text(
                      fmtShort(widget.totalExpense),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: colors.expense,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: widget.catTotals.asMap().entries.map((entry) {
              final i = entry.key;
              final ct = entry.value;
              final cat = widget.catMap[ct.categoryId];
              final hue = cat?.hue ?? (30 + i * 30) % 360;
              final pct = widget.totalExpense > 0
                  ? (ct.total / widget.totalExpense * 100).toStringAsFixed(0)
                  : '0';
              final color =
                  HSLColor.fromAHSL(1.0, hue.toDouble(), 0.55, 0.45).toColor();

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${cat?.name ?? 'Lainnya'} $pct%',
                    style: AppText.micro(color: colors.text2),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CashflowBarChart extends StatelessWidget {
  const _CashflowBarChart({
    required this.months,
    required this.currentMonth,
    required this.colors,
  });

  final List<MonthlyTotal?> months;
  final DateTime currentMonth;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final maxVal = months.fold(0, (m, t) {
      if (t == null) return m;
      return [m, t.income, t.expense].reduce((a, b) => a > b ? a : b);
    });
    final maxY = maxVal > 0 ? (maxVal * 1.2).toDouble() : 1000000.0;

    final groups = List.generate(months.length, (i) {
      final t = months[i];
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: t?.income.toDouble() ?? 0,
            color: colors.income,
            width: 10,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          BarChartRodData(
            toY: t?.expense.toDouble() ?? 0,
            color: colors.expense,
            width: 10,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
        barsSpace: 3,
      );
    });

    final monthLabels = List.generate(6, (i) {
      final m = DateTime(currentMonth.year, currentMonth.month - 5 + i, 1);
      const shortMonths = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
      return shortMonths[m.month - 1];
    });

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barGroups: groups,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: colors.border,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= monthLabels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            monthLabels[idx],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: colors.text3,
                            ),
                          ),
                        );
                      },
                      reservedSize: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: colors.income, label: 'Masuk'),
              const SizedBox(width: 16),
              _LegendDot(color: colors.expense, label: 'Keluar'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppText.micro(color: context.appColors.text2)),
      ],
    );
  }
}

class _MemberExpenseList extends StatelessWidget {
  const _MemberExpenseList({
    required this.memberExpenses,
    required this.memberMap,
    required this.totalExpense,
  });

  final List<MemberExpense> memberExpenses;
  final Map<int, dynamic> memberMap;
  final int totalExpense;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: memberExpenses.map((me) {
          final member = memberMap[me.memberId];
          final name = member?.name ?? 'Anggota';
          final hue = member?.avatarHue ?? 162;
          final initial = name.isNotEmpty ? name[0] : '?';
          final fraction =
              totalExpense > 0 ? me.total / totalExpense : 0.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                MemberAvatar(hue: hue, initial: initial, size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(name, style: AppText.body(color: colors.text)),
                          Text(
                            fmtShort(me.total),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colors.expense,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      AppProgressBar(
                        fraction: fraction,
                        height: 5,
                        normalColor: colors.expense,
                        radius: 3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}



