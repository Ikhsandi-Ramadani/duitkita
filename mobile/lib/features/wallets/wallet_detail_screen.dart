import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
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
import '../../features/home/providers/home_providers.dart';
import '../../ui/widgets/app_sheet.dart';
import '../../ui/widgets/app_toast.dart';
import '../../ui/widgets/app_top_bar.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/entrance_animation.dart';
import '../../ui/widgets/tx_row.dart';

class WalletDetailScreen extends ConsumerWidget {
  const WalletDetailScreen({super.key, required this.walletId});

  final int walletId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final walletAsync = ref.watch(
      StreamProvider.autoDispose<Wallet?>((ref) =>
          ref.watch(walletRepoProvider).watchById(walletId)),
    );

    return walletAsync.when(
      data: (wallet) {
        if (wallet == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Dompet')),
            body: const Center(child: Text('Dompet tidak ditemukan')),
          );
        }
        return _WalletDetailBody(wallet: wallet);
      },
      loading: () => Scaffold(
        backgroundColor: colors.appBg,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Dompet')),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _WalletDetailBody extends ConsumerWidget {
  const _WalletDetailBody({required this.wallet});
  final Wallet wallet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final userIdAsync = ref.watch(currentUserIdProvider);
    final userId = userIdAsync.value ?? 1;
    final members = ref.watch(membersProvider).value ?? [];
    final hiddenAsync = ref.watch(balanceHiddenProvider);
    final hidden = hiddenAsync.value ?? false;

    final isShared = wallet.scope == 'shared';
    final isOwn = wallet.ownerUserId == userId || isShared;

    final owner = wallet.ownerUserId != null
        ? members.cast<Member?>().firstWhere(
              (m) => m?.id == wallet.ownerUserId,
              orElse: () => null,
            )
        : null;

    final ownerLabel = isShared
        ? 'Bersama'
        : (owner?.name ?? 'Tidak diketahui');

    final typeLabel = _typeLabel(wallet.type);

    return Scaffold(
      backgroundColor: colors.appBg,
      body: Column(
        children: [
          AppTopBar(
            title: wallet.name,
            action: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: colors.text),
              onSelected: (v) async {
                if (v == 'edit') {
                  _showEditNameSheet(context, ref, wallet);
                } else if (v == 'delete') {
                  // delete only if zero transactions
                  final txList = await ref
                      .read(transactionRepoProvider)
                      .watchByWallet(wallet.id)
                      .first;
                  if (!context.mounted) return;
                  if (txList.isEmpty) {
                    _showDeleteConfirm(context, ref, wallet);
                  } else {
                    AppToast.show(
                      context,
                      'Dompet masih memiliki transaksi, tidak bisa dihapus',
                      success: false,
                    );
                  }
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit nama')),
                const PopupMenuItem(
                    value: 'delete', child: Text('Hapus dompet')),
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Hero balance card
                      EntranceAnimation(
                        child: _HeroBalanceCard(
                          wallet: wallet,
                          typeLabel: typeLabel,
                          ownerLabel: ownerLabel,
                          hidden: hidden,
                          isShared: isShared,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Actions
                      EntranceAnimation(
                        delay: const Duration(milliseconds: 60),
                        child: isOwn
                            ? _ActionButtons(wallet: wallet)
                            : _ReadOnlyNotice(),
                      ),
                      const SizedBox(height: 24),
                      // Transaction history
                      EntranceAnimation(
                        delay: const Duration(milliseconds: 100),
                        child: _WalletHistory(
                          walletId: wallet.id,
                          hidden: hidden,
                          members: members,
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _typeLabel(String type) {
    switch (type) {
      case 'bank':
        return 'Bank';
      case 'ewallet':
        return 'Dompet Digital';
      case 'cash':
      default:
        return 'Tunai';
    }
  }



  void _showEditNameSheet(
      BuildContext context, WidgetRef ref, Wallet wallet) {
    AppSheet.show(
      context: context,
      child: _EditNameSheet(wallet: wallet),
    );
  }

  void _showDeleteConfirm(
      BuildContext context, WidgetRef ref, Wallet wallet) {
    AppSheet.show<bool>(
      context: context,
      child: _DeleteConfirmSheet(wallet: wallet),
    ).then((confirmed) async {
      if (confirmed == true) {
        try {
          await ref.read(apiClientProvider).deleteWallet(wallet.id);
        } catch (e) {
          // API call failed — still soft-delete locally (offline-first)
          if (kDebugMode) print('[WalletDetail] deleteWallet error: $e');
        }
        await ref.read(walletRepoProvider).upsert(
              WalletsCompanion(
                id: Value(wallet.id),
                deleted: const Value(true),
              ),
            );
        if (context.mounted) {
          AppToast.show(context, 'Dompet dihapus');
          context.pop();
        }
      }
    });
  }
}

// ---------------------------------------------------------------------------
// Hero balance card
// ---------------------------------------------------------------------------

class _HeroBalanceCard extends StatelessWidget {
  const _HeroBalanceCard({
    required this.wallet,
    required this.typeLabel,
    required this.ownerLabel,
    required this.hidden,
    required this.isShared,
  });

  final Wallet wallet;
  final String typeLabel;
  final String ownerLabel;
  final bool hidden;
  final bool isShared;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final cardDecoration = isShared
        ? BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF058564), Color(0xFF036249)],
            ),
            borderRadius: AppRadius.borderRadiusBase,
            boxShadow: const [
              BoxShadow(
                color: Color(0x52047857),
                blurRadius: 20,
                offset: Offset(0, 6),
              ),
            ],
          )
        : BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.borderRadiusBase,
            border: Border.all(color: colors.border),
            boxShadow: AppShadows.base,
          );

    final textColor = isShared ? Colors.white : colors.text;
    final mutedColor = isShared
        ? Colors.white.withValues(alpha: 0.75)
        : colors.text2;
    final iconBg = isShared
        ? Colors.white.withValues(alpha: 0.18)
        : colors.primaryTint;
    final iconColor = isShared ? Colors.white : colors.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconFor(wallet.type),
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$typeLabel · $ownerLabel',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: mutedColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Saldo saat ini',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: mutedColor,
            ),
          ),
          const SizedBox(height: 4),
          hidden
              ? Text(
                  '••••••',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: 3,
                  ),
                )
              : RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Rp',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: isShared
                              ? Colors.white.withValues(alpha: 0.82)
                              : colors.text2,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      TextSpan(
                        text: fmtRp(wallet.currentBalance)
                            .replaceFirst('Rp', ''),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -0.02 * 36,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  static IconData _iconFor(String type) {
    switch (type) {
      case 'bank':
        return Icons.account_balance_outlined;
      case 'ewallet':
        return Icons.account_balance_wallet_outlined;
      case 'cash':
      default:
        return Icons.payments_outlined;
    }
  }
}

// ---------------------------------------------------------------------------
// Action buttons
// ---------------------------------------------------------------------------

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.wallet});
  final Wallet wallet;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () =>
                  context.push('/add-transaction'),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Transaksi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                elevation: 0,
                textStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 46,
            child: OutlinedButton.icon(
              onPressed: () => context
                  .push('/add-transaction?preset=adjust'),
              icon: const Icon(Icons.tune_rounded, size: 18),
              label: const Text('Sesuaikan'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.text,
                side: BorderSide(color: colors.border2, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                textStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: colors.text3, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Dompet ini hanya bisa dilihat — bukan milikmu.',
              style: AppText.body(color: colors.text2),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Transaction history
// ---------------------------------------------------------------------------

class _WalletHistory extends ConsumerWidget {
  const _WalletHistory({
    required this.walletId,
    required this.hidden,
    required this.members,
  });

  final int walletId;
  final bool hidden;
  final List<Member> members;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final txAsync = ref.watch(txByWalletProvider(walletId));
    final categories = ref.watch(categoriesProvider).value ?? [];
    final wallets = ref.watch(walletsProvider).value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Riwayat', style: AppText.sectionTitle(color: colors.text)),
        const SizedBox(height: 12),
        txAsync.when(
          data: (txList) {
            if (txList.isEmpty) {
              return EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Belum ada transaksi',
                sub: 'Transaksi dompet ini akan muncul di sini',
              );
            }

            // Group by date
            final Map<DateTime, List<Transaction>> grouped = {};
            for (final tx in txList) {
              final key = DateTime(tx.date.year, tx.date.month, tx.date.day);
              grouped.putIfAbsent(key, () => []).add(tx);
            }
            final sortedDates = grouped.keys.toList()
              ..sort((a, b) => b.compareTo(a));

            return Column(
              children: sortedDates.map((date) {
                final dayTxs = grouped[date]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        relDay(date),
                        style: AppText.label(color: colors.text3),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: AppRadius.borderRadiusBase,
                        border: Border.all(color: colors.border),
                        boxShadow: AppShadows.sm,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        children: dayTxs.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final tx = entry.value;

                          final recorder =
                              members.cast<Member?>().firstWhere(
                                    (m) => m?.id == tx.recordedBy,
                                    orElse: () => null,
                                  );
                          final spentBy = tx.spentBy != null
                              ? members.cast<Member?>().firstWhere(
                                    (m) => m?.id == tx.spentBy,
                                    orElse: () => null,
                                  )
                              : null;
                          final wallet = wallets.cast<Wallet?>().firstWhere(
                                (w) => w?.id == tx.walletId,
                                orElse: () => null,
                              );
                          final Category? category = tx.categoryId != null
                              ? categories.cast<Category?>().firstWhere(
                                    (c) => c?.id == tx.categoryId,
                                    orElse: () => null,
                                  )
                              : null;

                          final catName =
                              category?.name ?? _typeLabel(tx.type);
                          final catIconKey =
                              category?.icon ?? _typeIconKey(tx.type);
                          final catHue = category?.hue ?? 162;

                          return Column(
                            children: [
                              TxRow(
                                type: tx.type,
                                categoryName: catName,
                                categoryIconKey: catIconKey,
                                categoryHue: catHue,
                                recorderInitial: recorder?.name.isNotEmpty ==
                                        true
                                    ? recorder!.name[0]
                                    : '?',
                                recorderHue: recorder?.avatarHue ?? 162,
                                title: catName,
                                walletName: wallet?.name ?? 'Dompet',
                                note: tx.note,
                                spentByName: spentBy?.name,
                                amount: tx.amount,
                                hidden: hidden,
                                onTap: () =>
                                    context.push('/transaction/${tx.clientId}'),
                              ),
                              if (idx < dayTxs.length - 1)
                                Divider(color: colors.border, height: 1),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  static String _typeLabel(String type) {
    switch (type) {
      case 'income':
        return 'Pemasukan';
      case 'expense':
        return 'Pengeluaran';
      case 'transfer':
        return 'Transfer';
      default:
        return 'Penyesuaian';
    }
  }

  static String _typeIconKey(String type) {
    switch (type) {
      case 'income':
        return 'briefcase';
      case 'transfer':
        return 'signal';
      default:
        return 'dots';
    }
  }
}

// ---------------------------------------------------------------------------
// Edit name sheet
// ---------------------------------------------------------------------------

class _EditNameSheet extends ConsumerStatefulWidget {
  const _EditNameSheet({required this.wallet});
  final Wallet wallet;

  @override
  ConsumerState<_EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends ConsumerState<_EditNameSheet> {
  late final TextEditingController _ctrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.wallet.name);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      await ref.read(apiClientProvider).updateWallet(
        widget.wallet.id,
        {'name': name},
      );
      await ref.read(walletRepoProvider).upsert(
            WalletsCompanion(
              id: Value(widget.wallet.id),
              name: Value(name),
            ),
          );
      if (mounted) {
        Navigator.of(context).pop();
        AppToast.show(context, 'Nama dompet diperbarui');
      }
    } catch (e) {
      if (kDebugMode) print('[WalletDetail] updateWallet error: $e');
      if (mounted) {
        AppToast.show(context, 'Gagal memperbarui dompet', success: false);
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edit Nama Dompet',
              style: AppText.screenTitle(color: colors.text)),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            autofocus: true,
            style: AppText.body(color: colors.text),
            decoration: InputDecoration(
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
                borderSide:
                    BorderSide(color: colors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _ctrl.text.trim().isNotEmpty && !_saving
                  ? _save
                  : null,
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
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
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
// Delete confirm sheet
// ---------------------------------------------------------------------------

class _DeleteConfirmSheet extends StatelessWidget {
  const _DeleteConfirmSheet({required this.wallet});
  final Wallet wallet;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Hapus Dompet',
              style: AppText.screenTitle(color: colors.text)),
          const SizedBox(height: 12),
          Text(
            'Dompet "${wallet.name}" akan dihapus secara permanen. Tindakan ini tidak bisa dibatalkan.',
            style: AppText.body(color: colors.text2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.border2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: Text('Batal',
                      style: AppText.body(color: colors.text2)
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.expense,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: Text('Hapus',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
