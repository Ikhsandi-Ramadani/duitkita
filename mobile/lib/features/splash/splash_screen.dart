import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
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
        await _showUpdateDialog(update);
      }
      if (mounted) context.go('/lock');
    });
  }

  Future<void> _showUpdateDialog(UpdateInfo update) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: !update.force,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Tersedia 🎉'),
        content: Text(
          'Versi ${update.version} tersedia\n\n${update.notes}',
        ),
        actions: [
          if (!update.force)
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Nanti'),
            ),
          FilledButton(
            onPressed: () async {
              await launchUrl(
                Uri.parse(update.url),
                mode: LaunchMode.externalApplication,
              );
            },
            child: const Text('Update Sekarang'),
          ),
        ],
      ),
    );
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
