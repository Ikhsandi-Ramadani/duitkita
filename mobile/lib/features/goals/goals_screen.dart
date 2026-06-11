import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/format.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../ui/widgets/amount_sheet.dart';
import '../../ui/widgets/app_progress_bar.dart';
import '../../ui/widgets/app_sheet.dart';
import '../../ui/widgets/app_toast.dart';
import '../../ui/widgets/app_top_bar.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/scope_badge.dart';
import 'widgets/form_inputs.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final goalsAsync = ref.watch(goalsProvider);
    final walletsAsync = ref.watch(walletsProvider);
    final userAsync = ref.watch(currentUserIdProvider);
    final membersAsync = ref.watch(membersProvider);

    return Scaffold(
      backgroundColor: colors.appBg,
      appBar: AppTopBar(
        title: 'Kantong Tujuan',
        action: IconButton(
          icon: Icon(Icons.add_rounded, color: colors.primary, size: 24),
          onPressed: () => AppSheet.show(
            context: context,
            child: _AddGoalSheet(ref: ref),
          ),
          splashRadius: 20,
        ),
      ),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Gagal memuat',
          sub: e.toString(),
        ),
        data: (goals) {
          final uid = userAsync.value;
          final wallets = walletsAsync.value ?? [];
          final members = membersAsync.value ?? [];

          final totalCurrent = goals.fold(0, (s, g) => s + g.currentAmount);
          final totalTarget = goals.fold(0, (s, g) => s + g.targetAmount);
          final totalFraction = totalTarget > 0 ? totalCurrent / totalTarget : 0.0;

          final sharedGoals =
              goals.where((g) => g.scope == 'shared').toList();
          final myGoals =
              goals.where((g) => g.scope == 'personal' && g.ownerUserId == uid).toList();
          final otherGoals = goals
              .where((g) => g.scope == 'personal' && g.ownerUserId != uid)
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              // Emerald summary card
              _TotalCard(
                totalCurrent: totalCurrent,
                totalTarget: totalTarget,
                fraction: totalFraction,
              ),
              const SizedBox(height: 20),

              if (goals.isEmpty)
                EmptyState(
                  icon: Icons.flag_circle_outlined,
                  title: 'Belum ada kantong tujuan',
                  sub: 'Tap + untuk membuat kantong tujuan baru',
                )
              else ...[
                if (sharedGoals.isNotEmpty) ...[
                  _GroupHeader(label: 'Tujuan Bersama'),
                  const SizedBox(height: 8),
                  ...sharedGoals.map((g) => _GoalCard(
                    goal: g,
                    wallets: wallets,
                    ref: ref,
                    uid: uid,
                  )),
                  const SizedBox(height: 16),
                ],
                if (myGoals.isNotEmpty) ...[
                  _GroupHeader(label: 'Tujuan Saya'),
                  const SizedBox(height: 8),
                  ...myGoals.map((g) => _GoalCard(
                    goal: g,
                    wallets: wallets,
                    ref: ref,
                    uid: uid,
                  )),
                  const SizedBox(height: 16),
                ],
                if (otherGoals.isNotEmpty) ...[
                  _GroupHeader(label: 'Tujuan Anggota Lain'),
                  const SizedBox(height: 8),
                  ...otherGoals.map((g) => _GoalCard(
                    goal: g,
                    wallets: wallets,
                    ref: ref,
                    uid: uid,
                    ownerName: members
                        .where((m) => m.id == g.ownerUserId)
                        .map((m) => m.name)
                        .firstOrNull,
                  )),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({
    required this.totalCurrent,
    required this.totalTarget,
    required this.fraction,
  });

  final int totalCurrent;
  final int totalTarget;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            'Total Terkumpul',
            style: AppText.label(color: Colors.white.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 4),
          Text(
            fmtRp(totalCurrent),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'dari ${fmtRp(totalTarget)}',
            style: AppText.label(color: Colors.white.withValues(alpha: 0.75)),
          ),
          const SizedBox(height: 12),
          AppProgressBar(
            fraction: fraction,
            height: 7,
            normalColor: Colors.white.withValues(alpha: 0.9),
            overColor: Colors.white,
            trackColor: Colors.white.withValues(alpha: 0.25),
            radius: 4,
          ),
          const SizedBox(height: 6),
          Text(
            '${(fraction * 100).toStringAsFixed(0)}% dari total target',
            style: AppText.micro(color: Colors.white.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppText.sectionTitle(color: context.appColors.text));
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.wallets,
    required this.ref,
    required this.uid,
    this.ownerName,
  });

  final SavingsGoal goal;
  final List<Wallet> wallets;
  final WidgetRef ref;
  final int? uid;
  final String? ownerName;

  double get _fraction =>
      goal.targetAmount > 0 ? goal.currentAmount / goal.targetAmount : 0.0;

  String get _pct => '${(_fraction * 100).toStringAsFixed(0)}%';

  int get _remaining => goal.targetAmount - goal.currentAmount;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final ringColor = HSLColor.fromAHSL(1.0, goal.hue.toDouble(), 0.55, 0.42).toColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => context.push('/goal/${goal.id}'),
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
                  ProgressRing(
                    fraction: _fraction,
                    size: 56,
                    strokeWidth: 5,
                    color: ringColor,
                    centerWidget: Text(
                      _pct,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: ringColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                goal.name,
                                style: AppText.cardTitle(color: colors.text),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            ScopeBadge(scope: goal.scope),
                          ],
                        ),
                        if (goal.targetDate != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            dayLabel(goal.targetDate!),
                            style: AppText.micro(color: colors.text3),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (ownerName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            ownerName!,
                            style: AppText.micro(color: colors.text3),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${fmtRp(goal.currentAmount)} / ${fmtRp(goal.targetAmount)}',
                          style: AppText.label(color: colors.text2),
                        ),
                        const SizedBox(height: 6),
                        AppProgressBar(
                          fraction: _fraction,
                          height: 5,
                          normalColor: ringColor,
                          radius: 3,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _remaining > 0
                              ? 'Kurang ${fmtRp(_remaining)}'
                              : 'Tercapai!',
                          style: AppText.micro(
                            color: _remaining > 0 ? colors.text3 : colors.income,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => _showContribute(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ringColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      elevation: 0,
                    ),
                    child: Text(
                      'Sisihkan dana',
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
      ),
    );
  }

  void _showContribute(BuildContext context) {
    final walletOptions = wallets
        .map((w) => WalletOption(
              id: w.id,
              name: w.name,
              balance: w.currentBalance,
            ))
        .toList();

    AmountSheet.show(
      context: context,
      wallets: walletOptions,
      title: 'Sisihkan Dana',
      confirmLabel: 'Sisihkan',
      accentColor:
          HSLColor.fromAHSL(1.0, goal.hue.toDouble(), 0.55, 0.42).toColor(),
      onConfirm: (amount, walletId) async {
        final userId = uid ?? 1;
        await ref.read(goalRepoProvider).contribute(
              goalId: goal.id,
              amount: amount,
              sourceWalletId: walletId,
              recordedBy: userId,
            );
        if (context.mounted) {
          AppToast.show(context, 'Dana berhasil disisihkan');
        }
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Add Goal Sheet
// ---------------------------------------------------------------------------

class _AddGoalSheet extends StatefulWidget {
  const _AddGoalSheet({required this.ref});
  final WidgetRef ref;

  @override
  State<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<_AddGoalSheet> {
  final _nameCtrl = TextEditingController();
  int _targetAmount = 0;
  int? _durationMonths;
  String _scope = 'shared';
  int? _walletId;
  String _icon = 'flag';

  static const _durations = [
    (value: 3, label: '3 bln'),
    (value: 6, label: '6 bln'),
    (value: 12, label: '12 bln'),
    (value: 24, label: '24 bln'),
  ];

  static const _icons = [
    (value: 'shield', label: 'Darurat'),
    (value: 'flag', label: 'Tujuan'),
    (value: 'book', label: 'Pendidikan'),
    (value: 'smartphone', label: 'Gadget'),
    (value: 'gift', label: 'Hadiah'),
    (value: 'account_balance_wallet', label: 'Dompet'),
  ];

  bool get _canSave =>
      _nameCtrl.text.trim().isNotEmpty &&
      _targetAmount > 0 &&
      _durationMonths != null &&
      _walletId != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_canSave) return;
    final now = DateTime.now();
    final targetDate = DateTime(
      now.year,
      now.month + _durationMonths!,
      now.day,
    );

    // Compute a pseudo-id
    final pseudoId = now.millisecondsSinceEpoch % 2147483647;
    final userId = widget.ref.read(currentUserIdProvider).value ?? 1;

    await widget.ref.read(goalRepoProvider).upsert(
          SavingsGoalsCompanion.insert(
            id: Value(pseudoId),
            scope: _scope,
            ownerUserId: Value(_scope == 'personal' ? userId : null),
            name: _nameCtrl.text.trim(),
            targetAmount: _targetAmount,
            currentAmount: 0,
            targetDate: Value(targetDate),
            walletId: _walletId!,
            icon: _icon,
            hue: 162,
          ),
        );

    if (mounted) {
      Navigator.of(context).pop();
      AppToast.show(context, 'Kantong tujuan dibuat');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
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
          Text('Tambah Kantong Tujuan',
              style: AppText.sectionTitle(color: colors.text)),
          const SizedBox(height: 16),
          AppTextInput(
            controller: _nameCtrl,
            label: 'Nama Kantong',
            hint: 'mis. Dana Darurat',
            icon: Icons.flag_outlined,
          ),
          const SizedBox(height: 14),
          RupiahInput(
            label: 'Target',
            onChanged: (v) => setState(() => _targetAmount = v),
          ),
          const SizedBox(height: 14),
          ChipRow<int>(
            label: 'Jangka Waktu',
            items: _durations,
            selected: _durationMonths,
            onSelected: (v) => setState(() => _durationMonths = v),
          ),
          const SizedBox(height: 14),
          // Scope
          Text('Jenis', style: AppText.label(color: colors.text2)),
          const SizedBox(height: 6),
          Row(
            children: [
              _ScopeChip(
                label: 'Bersama',
                selected: _scope == 'shared',
                onTap: () => setState(() => _scope = 'shared'),
              ),
              const SizedBox(width: 8),
              _ScopeChip(
                label: 'Pribadi',
                selected: _scope == 'personal',
                onTap: () => setState(() => _scope = 'personal'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Dompet Penyimpanan', style: AppText.label(color: colors.text2)),
          const SizedBox(height: 6),
          walletsAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, st) => const SizedBox.shrink(),
            data: (wallets) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: wallets.map((w) {
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
                          w.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? colors.primary : colors.text,
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
            label: 'Ikon',
            items: _icons,
            selected: _icon,
            onSelected: (v) => setState(() => _icon = v),
          ),
          const SizedBox(height: 20),
          ListenableBuilder(
            listenable: _nameCtrl,
            builder: (context, _) => SaveButton(
              label: 'Buat Kantong',
              enabled: _canSave,
              onPressed: _save,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScopeChip extends StatelessWidget {
  const _ScopeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.12)
              : colors.surface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? colors.primary : colors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? colors.primary : colors.text2,
          ),
        ),
      ),
    );
  }
}


