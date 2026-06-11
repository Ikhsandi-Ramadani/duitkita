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
import '../../ui/widgets/app_sheet.dart';
import '../../ui/widgets/app_toast.dart';
import '../../ui/widgets/app_top_bar.dart';
import '../../ui/widgets/cat_icon.dart';
import '../../ui/widgets/member_avatar.dart';
import '../../ui/widgets/scope_badge.dart';
import '../../ui/widgets/tx_type_meta.dart';

// ---------------------------------------------------------------------------
// Transaction Detail Screen
// ---------------------------------------------------------------------------

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final txAsync = ref.watch(_txProvider(clientId));
    final currentUserId = ref.watch(currentUserIdProvider).value;

    return txAsync.when(
      loading: () => Scaffold(
        backgroundColor: colors.appBg,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: colors.appBg,
        body: Center(child: Text('Error: $e')),
      ),
      data: (tx) {
        if (tx == null) {
          return Scaffold(
            backgroundColor: colors.appBg,
            appBar: AppTopBar(title: 'Detail Transaksi'),
            body: const Center(child: Text('Transaksi tidak ditemukan.')),
          );
        }

        final isOwner = tx.recordedBy == currentUserId;
        final members = ref.watch(membersProvider).value ?? [];
        final wallets = ref.watch(walletsProvider).value ?? [];
        final cats = ref.watch(categoriesProvider).value ?? [];

        final cat = tx.categoryId != null
            ? cats.firstWhereOrNull((c) => c.id == tx.categoryId)
            : null;
        final wallet = wallets.firstWhereOrNull((w) => w.id == tx.walletId);
        final targetWallet = tx.targetWalletId != null
            ? wallets.firstWhereOrNull((w) => w.id == tx.targetWalletId)
            : null;
        final recorder =
            members.firstWhereOrNull((m) => m.id == tx.recordedBy);
        final spentByMember = tx.spentBy != null
            ? members.firstWhereOrNull((m) => m.id == tx.spentBy)
            : null;

        final meta = TxTypeMeta.of(tx.type, colors);

        // Determine display amount string
        final int displayAmt = tx.amount;
        final String amtStr;
        switch (tx.type) {
          case 'income':
            amtStr = '+${fmtRp(displayAmt.abs())}';
          case 'expense':
            amtStr = '−${fmtRp(displayAmt.abs())}';
          case 'adjustment':
            amtStr = displayAmt >= 0
                ? '+${fmtRp(displayAmt)}'
                : '−${fmtRp(displayAmt.abs())}';
          default:
            amtStr = fmtRp(displayAmt.abs());
        }

        return Scaffold(
          backgroundColor: colors.appBg,
          appBar: AppTopBar(
            title: 'Detail Transaksi',
            action: isOwner
                ? TextButton(
                    onPressed: () {
                      context.push('/add-transaction?edit=${tx.clientId}');
                    },
                    child: Text(
                      'Edit',
                      style: AppText.body(color: colors.primary).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : null,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Hero ──────────────────────────────────────────────────
                const SizedBox(height: 12),
                _HeroSection(
                  tx: tx,
                  cat: cat,
                  meta: meta,
                  amtStr: amtStr,
                  colors: colors,
                ),
                const SizedBox(height: 24),

                // ── Field card ───────────────────────────────────────────
                _FieldCard(
                  tx: tx,
                  cat: cat,
                  wallet: wallet,
                  targetWallet: targetWallet,
                  recorder: recorder,
                  spentByMember: spentByMember,
                  meta: meta,
                  colors: colors,
                ),
                const SizedBox(height: 20),

                // ── Ownership section ────────────────────────────────────
                if (isOwner)
                  _OwnerActions(
                    tx: tx,
                    colors: colors,
                    ref: ref,
                    context: context,
                  )
                else
                  _NotOwnerInfo(
                    recorderName: recorder?.name ?? 'Anggota lain',
                    colors: colors,
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final _txProvider = StreamProvider.family<Transaction?, String>((ref, clientId) {
  final db = ref.watch(dbProvider);
  return (db.select(db.transactions)
        ..where((t) => t.clientId.equals(clientId)))
      .watchSingleOrNull();
});

// ---------------------------------------------------------------------------
// Hero section
// ---------------------------------------------------------------------------

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.tx,
    required this.cat,
    required this.meta,
    required this.amtStr,
    required this.colors,
  });

  final Transaction tx;
  final Category? cat;
  final TxTypeMeta meta;
  final String amtStr;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final iconKey = cat?.icon ?? _fallbackIcon(tx.type);
    final hue = cat?.hue ?? _fallbackHue(tx.type);

    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: meta.tintColor,
            borderRadius: BorderRadius.circular(22),
          ),
          child: CatIcon(
            iconKey: iconKey,
            hue: hue,
            size: 64,
            iconSize: 30,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          cat?.name ?? meta.label,
          style: AppText.cardTitle(color: meta.color),
        ),
        const SizedBox(height: 6),
        Text(
          amtStr,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 38,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.02 * 38,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: meta.color,
          ),
        ),
        if (tx.note != null && tx.note!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            tx.note!,
            style: AppText.body(color: colors.text2),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  String _fallbackIcon(String type) {
    switch (type) {
      case 'income':
        return 'briefcase';
      case 'transfer':
        return 'dots';
      default:
        return 'dots';
    }
  }

  int _fallbackHue(String type) {
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
// Field card
// ---------------------------------------------------------------------------

class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.tx,
    required this.cat,
    required this.wallet,
    required this.targetWallet,
    required this.recorder,
    required this.spentByMember,
    required this.meta,
    required this.colors,
  });

  final Transaction tx;
  final Category? cat;
  final Wallet? wallet;
  final Wallet? targetWallet;
  final Member? recorder;
  final Member? spentByMember;
  final TxTypeMeta meta;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    // Jenis
    rows.add(_row(
      colors: colors,
      label: 'Jenis',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, size: 16, color: meta.color),
          const SizedBox(width: 6),
          Text(meta.label, style: AppText.body(color: meta.color)),
        ],
      ),
    ));

    rows.add(_divider());

    // Dompet
    rows.add(_row(
      colors: colors,
      label: 'Dompet',
      child: tx.type == 'transfer'
          ? Text(
              '${wallet?.name ?? '?'} → ${targetWallet?.name ?? '?'}',
              style: AppText.body(color: colors.text),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(wallet?.name ?? '?',
                    style: AppText.body(color: colors.text)),
                const SizedBox(width: 6),
                ScopeBadge(scope: wallet?.scope ?? 'personal'),
              ],
            ),
    ));

    rows.add(_divider());

    // Tanggal
    rows.add(_row(
      colors: colors,
      label: 'Tanggal',
      child: Text(dayLabel(tx.date), style: AppText.body(color: colors.text)),
    ));

    rows.add(_divider());

    // Waktu
    rows.add(_row(
      colors: colors,
      label: 'Waktu',
      child: Text(
        '${timeLabel(tx.date)} WIB',
        style: AppText.body(color: colors.text),
      ),
    ));

    rows.add(_divider());

    // Dicatat oleh
    rows.add(_row(
      colors: colors,
      label: 'Dicatat oleh',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (recorder != null)
            MemberAvatar(
              hue: recorder!.avatarHue,
              initial: recorder!.name,
              size: 24,
            ),
          const SizedBox(width: 8),
          Text(
            recorder?.name ?? '?',
            style: AppText.body(color: colors.text),
          ),
        ],
      ),
    ));

    // Untuk (spentBy)
    if (spentByMember != null) {
      rows.add(_divider());
      rows.add(_row(
        colors: colors,
        label: 'Untuk',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MemberAvatar(
              hue: spentByMember!.avatarHue,
              initial: spentByMember!.name,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              spentByMember!.name,
              style: AppText.body(color: colors.text),
            ),
          ],
        ),
      ));
    }

    // Struk placeholder
    rows.add(_divider());
    rows.add(_row(
      colors: colors,
      label: 'Struk',
      child: Text('Tidak ada', style: AppText.body(color: colors.text3)),
    ));

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.borderRadiusBase,
        border: Border.all(color: colors.border),
      ),
      child: Column(children: rows),
    );
  }

  Widget _row({
    required AppColors colors,
    required String label,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Text(label, style: AppText.body(color: colors.text2)),
          const Spacer(),
          child,
        ],
      ),
    );
  }

  Widget _divider() => Builder(
        builder: (ctx) {
          final colors = ctx.appColors;
          return Divider(height: 1, thickness: 1, color: colors.border);
        },
      );
}

// ---------------------------------------------------------------------------
// Owner actions
// ---------------------------------------------------------------------------

class _OwnerActions extends StatelessWidget {
  const _OwnerActions({
    required this.tx,
    required this.colors,
    required this.ref,
    required this.context,
  });

  final Transaction tx;
  final AppColors colors;
  final WidgetRef ref;
  final BuildContext context;

  Future<void> _confirmDelete() async {
    await AppSheet.show<void>(
      context: context,
      child: _DeleteConfirmSheet(
        colors: colors,
        onConfirm: () async {
          Navigator.of(context).pop(); // close sheet
          try {
            await ref.read(transactionRepoProvider).deleteTransaction(tx.clientId);
            if (context.mounted) {
              AppToast.show(context, 'Transaksi dihapus');
              context.pop();
            }
          } catch (e) {
            if (context.mounted) {
              AppToast.show(context, 'Gagal menghapus', success: false);
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colors.expense),
              foregroundColor: colors.expense,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _confirmDelete,
            child: Text(
              'Hapus',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              context.push('/add-transaction?edit=${tx.clientId}');
            },
            child: Text(
              'Edit',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Not owner info box
// ---------------------------------------------------------------------------

class _NotOwnerInfo extends StatelessWidget {
  const _NotOwnerInfo({
    required this.recorderName,
    required this.colors,
  });

  final String recorderName;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: AppRadius.borderRadiusSm,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: colors.text3, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Hanya $recorderName yang dapat mengubah transaksi ini.',
              style: AppText.body(color: colors.text2),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Delete confirmation sheet
// ---------------------------------------------------------------------------

class _DeleteConfirmSheet extends StatelessWidget {
  const _DeleteConfirmSheet({
    required this.colors,
    required this.onConfirm,
  });

  final AppColors colors;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Hapus transaksi?',
            style: AppText.cardTitle(color: colors.text),
          ),
          const SizedBox(height: 8),
          Text(
            'Tindakan ini tidak dapat dibatalkan. Saldo dompet akan dikembalikan.',
            style: AppText.body(color: colors.text2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.expense,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onConfirm,
              child: Text(
                'Hapus',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.border),
                foregroundColor: colors.text2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
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
