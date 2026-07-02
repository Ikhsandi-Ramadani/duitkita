import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/update_service.dart';
import '../../data/providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () async {
      final updateService = ref.read(updateServiceProvider);
      final update = await updateService.checkUpdate();
      if (update != null && mounted) {
        await showDialog<void>(
          context: context,
          barrierDismissible: !update.force,
          builder: (_) => _UpdateDialog(
            update: update,
            updateService: updateService,
          ),
        );
      }
      if (mounted) context.go('/lock');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: colors.onPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 48,
                    color: colors.onPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'DuitKita',
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kelola keuangan bersama',
                  style: TextStyle(
                    color: colors.onPrimary.withValues(alpha: 0.75),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Update dialog — info -> in-app download with progress -> launch installer
// ---------------------------------------------------------------------------

enum _UpdateStage { info, downloading, error }

class _UpdateDialog extends StatefulWidget {
  const _UpdateDialog({required this.update, required this.updateService});
  final UpdateInfo update;
  final UpdateService updateService;

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  _UpdateStage _stage = _UpdateStage.info;
  double _progress = 0;

  Future<void> _startDownload() async {
    setState(() {
      _stage = _UpdateStage.downloading;
      _progress = 0;
    });

    try {
      final path = await widget.updateService.downloadApk(
        widget.update.url,
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
      if (!mounted) return;
      final result = await OpenFilex.open(path);
      if (result.type != ResultType.done && mounted) {
        setState(() => _stage = _UpdateStage.error);
        return;
      }
      // Installer is now showing over the app — close the dialog behind it.
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (kDebugMode) print('[Update] download error: $e');
      if (mounted) setState(() => _stage = _UpdateStage.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final update = widget.update;

    return AlertDialog(
      title: Text(_stage == _UpdateStage.info
          ? 'Update Tersedia 🎉'
          : _stage == _UpdateStage.downloading
              ? 'Mengunduh Update…'
              : 'Unduhan Gagal'),
      content: switch (_stage) {
        _UpdateStage.info => Text('Versi ${update.version} tersedia\n\n${update.notes}'),
        _UpdateStage.downloading => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 10),
              Text('${(_progress * 100).toStringAsFixed(0)}%'),
            ],
          ),
        _UpdateStage.error => const Text(
            'Gagal mengunduh update. Periksa koneksi internet dan coba lagi.'),
      },
      actions: switch (_stage) {
        _UpdateStage.info => [
            if (!update.force)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Nanti'),
              ),
            FilledButton(
              onPressed: _startDownload,
              child: const Text('Update Sekarang'),
            ),
          ],
        _UpdateStage.downloading => [],
        _UpdateStage.error => [
            if (!update.force)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Nanti'),
              ),
            FilledButton(
              onPressed: _startDownload,
              child: const Text('Coba Lagi'),
            ),
          ],
      },
    );
  }
}
