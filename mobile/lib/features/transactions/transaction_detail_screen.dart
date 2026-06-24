import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

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

// Base URL for receipt thumbnails — strips the /api suffix from the API base.
// e.g. 'http://localhost:8000/api' → 'http://localhost:8000'
const _kReceiptBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000/api',
);

String _storageBase() {
  final base = _kReceiptBaseUrl;
  if (base.endsWith('/api')) return base.substring(0, base.length - 4);
  return base;
}

// ---------------------------------------------------------------------------
// Transaction Detail Screen
// ---------------------------------------------------------------------------

class TransactionDetailScreen extends ConsumerStatefulWidget {
  const TransactionDetailScreen({super.key, required this.clientId});

  final String clientId;

  @override
  ConsumerState<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState
    extends ConsumerState<TransactionDetailScreen> {
  bool _uploadingReceipt = false;

  Future<void> _pickAndUploadReceipt(Transaction tx) async {
    // serverId is required to call the server endpoint
    if (tx.serverId == null) {
      AppToast.show(
        context,
        'Transaksi belum tersinkron. Coba lagi setelah sinkron.',
        success: false,
      );
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    if (!mounted) return;

    setState(() => _uploadingReceipt = true);
    try {
      final api = ref.read(apiClientProvider);
      final serverPath =
          await api.uploadReceipt(tx.serverId!, File(picked.path));

      await ref
          .read(transactionRepoProvider)
          .updateReceiptPath(tx.clientId, serverPath);

      if (mounted) {
        AppToast.show(context, 'Struk berhasil diunggah');
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(context, 'Gagal mengunggah struk', success: false);
      }
    } finally {
      if (mounted) setState(() => _uploadingReceipt = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final txAsync = ref.watch(_txProvider(widget.clientId));
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
                const SizedBox(height: 16),

                // ── Receipt section ──────────────────────────────────────
                _ReceiptSection(
                  tx: tx,
                  uploading: _uploadingReceipt,
                  colors: colors,
                  onUpload: () => _pickAndUploadReceipt(tx),
                ),
                const SizedBox(height: 16),

                // ── Split section ─────────────────────────────────────────
                if (tx.type == 'expense') ...[
                  _SplitSection(
                    tx: tx,
                    isOwner: isOwner,
                    members: members,
                    colors: colors,
                  ),
                  const SizedBox(height: 16),
                ],

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

/// Fetches splits for a synced transaction (API-only, no local cache).
final _splitsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((ref, serverId) {
  return ref.read(apiClientProvider).getTransactionSplits(serverId);
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
// Receipt section
// ---------------------------------------------------------------------------

class _ReceiptSection extends StatelessWidget {
  const _ReceiptSection({
    required this.tx,
    required this.uploading,
    required this.colors,
    required this.onUpload,
  });

  final Transaction tx;
  final bool uploading;
  final AppColors colors;
  final VoidCallback onUpload;

  void _showFullscreen(BuildContext context, String imageUrl) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, e, st) => const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white54,
                  size: 64,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final receiptPath = tx.receiptPath;
    final imageUrl = receiptPath != null
        ? '${_storageBase()}$receiptPath'
        : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.borderRadiusBase,
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Struk',
            style: AppText.body(color: colors.text2),
          ),
          const SizedBox(height: 12),

          // Thumbnail (shown when receipt exists)
          if (imageUrl != null) ...[
            GestureDetector(
              onTap: () => _showFullscreen(context, imageUrl),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return SizedBox(
                      height: 160,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                              : null,
                          color: colors.primary,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, e, st) => Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: colors.surface2,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(Icons.broken_image_outlined,
                          color: colors.text3, size: 40),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ketuk gambar untuk memperbesar',
              style: AppText.micro(color: colors.text3),
            ),
            const SizedBox(height: 12),
          ],

          // Upload / replace button
          SizedBox(
            width: double.infinity,
            child: uploading
                ? const Center(
                    child: SizedBox(
                      height: 36,
                      width: 36,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  )
                : OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.border),
                      foregroundColor: colors.text,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: Text(
                      imageUrl != null ? 'Ganti Struk' : 'Tambah Struk',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: onUpload,
                  ),
          ),
        ],
      ),
    );
  }
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
// Split section
// ---------------------------------------------------------------------------

class _SplitSection extends ConsumerWidget {
  const _SplitSection({
    required this.tx,
    required this.isOwner,
    required this.members,
    required this.colors,
  });

  final Transaction tx;
  final bool isOwner;
  final List<Member> members;
  final AppColors colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverId = tx.serverId;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.borderRadiusBase,
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Bagi Tagihan', style: AppText.body(color: colors.text2)),
              const Spacer(),
              if (isOwner && serverId != null)
                GestureDetector(
                  onTap: () => _openSplitSheet(context, ref, serverId),
                  child: Text(
                    'Atur',
                    style: AppText.body(color: colors.primary).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (serverId == null)
            _emptyHint(
              'Sinkronkan transaksi terlebih dahulu untuk mengatur pembagian.',
              colors,
            )
          else
            _SplitList(
              serverId: serverId,
              members: members,
              colors: colors,
            ),
        ],
      ),
    );
  }

  Widget _emptyHint(String msg, AppColors colors) {
    return Text(msg, style: AppText.body(color: colors.text3));
  }

  Future<void> _openSplitSheet(
      BuildContext context, WidgetRef ref, int serverId) async {
    await AppSheet.show<void>(
      context: context,
      child: _SplitSheet(
        tx: tx,
        serverId: serverId,
        members: members,
        colors: colors,
        onSaved: () => ref.invalidate(_splitsProvider(serverId)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Split list (async load)
// ---------------------------------------------------------------------------

class _SplitList extends ConsumerWidget {
  const _SplitList({
    required this.serverId,
    required this.members,
    required this.colors,
  });

  final int serverId;
  final List<Member> members;
  final AppColors colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splitsAsync = ref.watch(_splitsProvider(serverId));

    return splitsAsync.when(
      loading: () => const Center(
        child: SizedBox(
          height: 32,
          width: 32,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, e) => Text(
        'Gagal memuat pembagian tagihan.',
        style: AppText.body(color: colors.text3),
      ),
      data: (splits) {
        if (splits.isEmpty) {
          return Text(
            'Belum ada pembagian tagihan.',
            style: AppText.body(color: colors.text3),
          );
        }
        return Column(
          children: splits.map((s) {
            final userId = s['user_id'] as int?;
            final amount = s['amount'] as int? ?? 0;
            final user = s['user'] as Map<String, dynamic>?;
            final name = user?['name'] as String? ?? 'Anggota';
            final hue = user?['avatar_hue'] as int? ?? 200;

            // prefer local member data if available
            final localMember = members.cast<Member?>().firstWhere(
                  (m) => m?.id == userId,
                  orElse: () => null,
                );

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  MemberAvatar(
                    hue: localMember?.avatarHue ?? hue,
                    initial: localMember?.name ?? name,
                    size: 32,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      localMember?.name ?? name,
                      style: AppText.body(color: colors.text),
                    ),
                  ),
                  Text(
                    fmtRp(amount),
                    style: AppText.body(color: colors.text).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Split sheet
// ---------------------------------------------------------------------------

class _SplitSheet extends ConsumerStatefulWidget {
  const _SplitSheet({
    required this.tx,
    required this.serverId,
    required this.members,
    required this.colors,
    required this.onSaved,
  });

  final Transaction tx;
  final int serverId;
  final List<Member> members;
  final AppColors colors;
  final VoidCallback onSaved;

  @override
  ConsumerState<_SplitSheet> createState() => _SplitSheetState();
}

class _SplitSheetState extends ConsumerState<_SplitSheet> {
  /// Members checked for splitting
  late List<Member> _selected;

  /// Amount controllers keyed by member id
  final Map<int, TextEditingController> _controllers = {};

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selected = [];
    _initControllersForSelected();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _initControllersForSelected() {
    // Remove controllers for deselected members
    final selectedIds = _selected.map((m) => m.id).toSet();
    _controllers.removeWhere((id, c) {
      if (!selectedIds.contains(id)) {
        c.dispose();
        return true;
      }
      return false;
    });

    // Add controllers for newly selected members
    for (final m in _selected) {
      if (!_controllers.containsKey(m.id)) {
        _controllers[m.id] = TextEditingController();
      }
    }

    // Distribute equal splits
    if (_selected.isNotEmpty) {
      final each = widget.tx.amount.abs() ~/ _selected.length;
      for (final m in _selected) {
        _controllers[m.id]!.text = each.toString();
      }
    }
  }

  int get _totalEntered {
    int total = 0;
    for (final c in _controllers.values) {
      total += int.tryParse(c.text.replaceAll('.', '')) ?? 0;
    }
    return total;
  }

  bool get _isValid =>
      _selected.isNotEmpty && _totalEntered <= widget.tx.amount.abs();

  void _toggleMember(Member m, bool selected) {
    setState(() {
      if (selected) {
        _selected = [..._selected, m];
      } else {
        _selected = _selected.where((s) => s.id != m.id).toList();
      }
      _initControllersForSelected();
    });
  }

  Future<void> _save() async {
    if (!_isValid) return;

    setState(() => _saving = true);
    try {
      final splits = _selected.map((m) {
        final raw = _controllers[m.id]!.text.replaceAll('.', '');
        return {
          'user_id': m.id,
          'amount': int.tryParse(raw) ?? 0,
        };
      }).toList();

      await ref.read(apiClientProvider).updateSplits(widget.serverId, splits);

      widget.onSaved();
      if (mounted) {
        Navigator.of(context).pop();
        AppToast.show(context, 'Pembagian tagihan disimpan');
      }
    } catch (_) {
      if (mounted) {
        AppToast.show(context, 'Gagal menyimpan pembagian', success: false);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final txAmount = widget.tx.amount.abs();
    final remaining = txAmount - _totalEntered;
    final overBudget = _totalEntered > txAmount;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Bagi Tagihan',
              style: AppText.cardTitle(color: colors.text),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Total: ${fmtRp(txAmount)}',
              style: AppText.body(color: colors.text2),
            ),
          ),
          const SizedBox(height: 16),

          // Member list with checkboxes
          ...widget.members.map((m) {
            final isSelected = _selected.any((s) => s.id == m.id);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isSelected,
                  onChanged: (v) => _toggleMember(m, v ?? false),
                  secondary: MemberAvatar(
                    hue: m.avatarHue,
                    initial: m.name,
                    size: 36,
                  ),
                  title: Text(m.name, style: AppText.body(color: colors.text)),
                  activeColor: colors.primary,
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
                if (isSelected && _controllers.containsKey(m.id))
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 52, right: 0, bottom: 8),
                    child: TextField(
                      controller: _controllers[m.id],
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
                        prefixStyle: AppText.body(color: colors.text2),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: colors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: colors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: colors.primary, width: 1.5),
                        ),
                      ),
                      style: AppText.body(color: colors.text),
                    ),
                  ),
              ],
            );
          }),

          const SizedBox(height: 8),

          // Running total indicator
          if (_selected.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: overBudget ? colors.expense.withValues(alpha: 0.08) : colors.surface2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: overBudget ? colors.expense : colors.border,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Total dibagi:',
                    style: AppText.body(color: colors.text2),
                  ),
                  const Spacer(),
                  Text(
                    fmtRp(_totalEntered),
                    style: AppText.body(
                      color:
                          overBudget ? colors.expense : colors.text,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (!overBudget && remaining > 0) ...[
                    const SizedBox(width: 6),
                    Text(
                      '(sisa ${fmtRp(remaining)})',
                      style: AppText.label(color: colors.text3),
                    ),
                  ],
                ],
              ),
            ),

          if (overBudget)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Total melebihi jumlah transaksi.',
                style: AppText.label(color: colors.expense),
              ),
            ),

          const SizedBox(height: 20),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: colors.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: (_isValid && !_saving) ? _save : null,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
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
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 46,
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
