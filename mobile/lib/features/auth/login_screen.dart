import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/providers.dart';
import '../../data/db/seed.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.appBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Brand mark
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colors.primaryTint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    'assets/branding/duitkita-mark-transparent-1024.png',
                    fit: BoxFit.contain,
                    semanticLabel: 'Logo DuitKita',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Masuk ke DuitKita',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.02 * 27,
                    color: colors.text,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Email field
              _InputField(
                controller: _emailCtrl,
                label: 'Email atau No. HP',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              // Password field
              _InputField(
                controller: _passCtrl,
                label: 'Kata sandi',
                icon: Icons.lock_outline_rounded,
                obscure: _obscure,
                suffix: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: colors.text3,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: Text(
                    'Lupa sandi?',
                    style: AppText.label(color: colors.primary),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colors.expenseTint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _error!,
                    style: AppText.label(color: colors.expense),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              // Masuk button
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Masuk',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _onDemoLogin,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Masuk Demo (offline)',
                      style: AppText.body(
                        color: colors.primary,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: colors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Pertama kali pakai?',
                      style: AppText.label(color: colors.text3),
                    ),
                  ),
                  Expanded(child: Divider(color: colors.border)),
                ],
              ),
              const SizedBox(height: 16),
              // Option cards
              _OptionCard(
                icon: Icons.group_outlined,
                title: 'Buat Keluarga Baru',
                sub: 'Kamu jadi pemilik keluarga',
                onTap: () => context.push('/login/create'),
              ),
              const SizedBox(height: 10),
              _OptionCard(
                icon: Icons.qr_code_scanner_rounded,
                title: 'Gabung Keluarga',
                sub: 'Masukkan kode undangan',
                onTap: () => context.push('/login/join'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final syncService = ref.read(syncServiceProvider);
      final hasPending = await syncService.hasPendingSync();
      if (hasPending) {
        final oldToken = await api.getToken();
        if (oldToken == null) {
          if (!mounted) return;
          setState(() {
            _loading = false;
            _error =
                'Ada data lokal dari sesi sebelumnya yang belum '
                'tersinkron. Masuk ke akun asal saat online sebelum berganti akun.';
          });
          return;
        }
        await syncService.pushAllPending();
        if (await syncService.hasPendingSync()) {
          if (!mounted) return;
          setState(() {
            _loading = false;
            _error =
                'Ada data belum tersinkron. Login dibatalkan supaya data '
                'tidak masuk ke akun yang salah. Coba lagi saat online.';
          });
          return;
        }
      }

      await api.login(_emailCtrl.text.trim(), _passCtrl.text);

      // The new token is active now. Remove every account-scoped local value
      // before pulling so no data or invite code leaks across accounts.
      await ref.read(dbProvider).clearAll();
      await ref.read(sessionRepoProvider).clear();
      try {
        await syncService.initialPull();
      } on DioException catch (syncErr) {
        await api.clearToken();
        await ref.read(sessionRepoProvider).clear();
        final syncMsg = syncErr.response?.data is Map
            ? (syncErr.response!.data['message'] as String?)
            : null;
        final detail =
            '[sync ${syncErr.response?.statusCode}] ${syncMsg ?? syncErr.message}';
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = 'Login berhasil tapi sync gagal: $detail';
        });
        return;
      } catch (syncErr) {
        await api.clearToken();
        await ref.read(sessionRepoProvider).clear();
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = 'Login berhasil tapi sync error: $syncErr';
        });
        return;
      }

      if (mounted) context.go('/home');
    } on DioException catch (e) {
      final serverMsg = e.response?.data is Map
          ? (e.response!.data['message'] as String?)
          : null;
      final debugInfo =
          '[${e.type.name}] ${e.response?.statusCode ?? ''} '
          '${e.response?.data ?? e.message}';
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = serverMsg ?? 'Error: $debugInfo';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Error: $e';
      });
    }
  }

  Future<void> _onDemoLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final db = ref.read(dbProvider);
    final sync = ref.read(syncServiceProvider);
    if (await sync.hasPendingSync()) {
      final api = ref.read(apiClientProvider);
      if (await api.getToken() != null) {
        await sync.pushAllPending();
      }
      if (await sync.hasPendingSync()) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error =
              'Mode demo dibatalkan karena masih ada data nyata yang '
              'belum tersinkron.';
        });
        return;
      }
    }
    // Wipe any previous account's local data so demo mode never shows
    // someone else's real transactions/debts/recurrings.
    await db.clearAll();
    // Delete existing session data and re-seed
    await db.delete(db.sessionKv).go();
    // Clear any stale auth token so API calls don't use a real session
    await ref.read(apiClientProvider).clearToken();
    // Re-seed if needed
    await seedIfEmpty(db);
    final sessionRepo = ref.read(sessionRepoProvider);
    await sessionRepo.setCurrentUserId(1);
    await sessionRepo.set('demoMode', 'true');
    await sessionRepo.set('hasPin', 'false');
    if (mounted) context.go('/home');
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      height: 52,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        style: AppText.body(color: colors.text),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: colors.text3),
          suffixIcon: suffix,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          filled: true,
          fillColor: colors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colors.border2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colors.border2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.sub,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.primaryTint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: colors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(sub, style: AppText.label(color: colors.text3)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.text3, size: 20),
          ],
        ),
      ),
    );
  }
}
