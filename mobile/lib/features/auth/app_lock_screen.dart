import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../ui/widgets/app_toast.dart';
import '../../ui/widgets/member_avatar.dart';

class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  final List<String> _digits = [];
  bool _checking = false;
  bool _loadingPinCheck = true;
  String? _errorMsg;
  final _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _checkPinSetup();
  }

  Future<void> _checkPinSetup() async {
    final sessionRepo = ref.read(sessionRepoProvider);
    if (await sessionRepo.get('demoMode') == 'true') {
      if (mounted) context.go('/home');
      return;
    }
    final localHasPinValue = await sessionRepo.get('hasPin');
    try {
      final me = await ref.read(apiClientProvider).me();
      final user = me['user'] as Map<String, dynamic>?;
      final hasPin = user?['has_pin'] == true;
      await sessionRepo.set('hasPin', hasPin.toString());
      if (!mounted) return;
      if (!hasPin) {
        // Server explicitly says no PIN — safe to skip lock
        context.go('/home');
        return;
      }
      setState(() {
        _loadingPinCheck = false;
      });
    } on DioException {
      if (!mounted) return;
      if (localHasPinValue == 'false') {
        context.go('/home');
        return;
      }
      setState(() {
        _loadingPinCheck = false;
      });
    } catch (_) {
      // Any other error — fail closed
      if (mounted) {
        setState(() {
          _loadingPinCheck = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingPinCheck) {
      return const Scaffold(
        backgroundColor: Color(0xFF036249),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    final membersAsync = ref.watch(membersProvider);
    final userIdAsync = ref.watch(currentUserIdProvider);
    final biometricEnabled = ref.watch(biometricEnabledProvider).value ?? false;

    final currentUserId = userIdAsync.value;
    final members = membersAsync.value ?? [];
    final Member? member = members.cast<Member?>().firstWhere(
      (m) => m?.id == currentUserId,
      orElse: () => members.isNotEmpty ? members.first : null,
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.55, 1.0],
            colors: [Color(0xFF058564), Color(0xFF036249), Color(0xFF024C39)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(flex: 3),
                      _UserGreeting(member: member, checking: _checking),
                      const SizedBox(height: 24),
                      _PinDots(count: _digits.length),
                      const SizedBox(height: 12),
                      if (_errorMsg != null)
                        Text(
                          _errorMsg!,
                          style: TextStyle(
                            color: Colors.red.shade300,
                            fontSize: 13,
                          ),
                        ),
                      const Spacer(flex: 3),
                      _Keypad(
                        onDigit: _onDigit,
                        onBackspace: _onBackspace,
                        onBiometric: biometricEnabled ? _onBiometric : null,
                        memberName: member?.name ?? 'kamu',
                        onSwitchAccount: _switchAccount,
                      ),
                      const Spacer(flex: 1),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onDigit(String d) {
    if (_digits.length >= 6 || _checking) return;
    HapticFeedback.selectionClick();
    setState(() => _digits.add(d));
    if (_digits.length == 6) _verifyPin();
  }

  void _onBackspace() {
    if (_digits.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _digits.removeLast());
  }

  Future<void> _verifyPin() async {
    setState(() {
      _checking = true;
      _errorMsg = null;
    });
    try {
      final ok = await ref.read(apiClientProvider).verifyPin(_digits.join());
      if (!mounted) return;
      if (ok) {
        context.go('/home');
      } else {
        HapticFeedback.vibrate();
        setState(() {
          _digits.clear();
          _checking = false;
          _errorMsg = 'PIN salah';
        });
      }
    } on DioException catch (e) {
      if (!mounted) return;
      if (e.response?.statusCode == 401 || e.response?.statusCode == 422) {
        // Wrong PIN — server confirmed
        HapticFeedback.vibrate();
        setState(() {
          _digits.clear();
          _checking = false;
          _errorMsg = 'PIN salah';
        });
      } else if (e.response != null) {
        // Other server error
        HapticFeedback.vibrate();
        setState(() {
          _digits.clear();
          _checking = false;
          _errorMsg = 'Terjadi kesalahan, coba lagi';
        });
      } else {
        // No connectivity — do NOT go home
        setState(() {
          _digits.clear();
          _checking = false;
          _errorMsg = 'Tidak ada koneksi, coba lagi';
        });
      }
    } catch (_) {
      if (!mounted) return;
      HapticFeedback.vibrate();
      setState(() {
        _digits.clear();
        _checking = false;
        _errorMsg = 'Terjadi kesalahan, coba lagi';
      });
    }
  }

  Future<void> _onBiometric() async {
    try {
      final enabled =
          await ref.read(sessionRepoProvider).get('biometricEnabled') == 'true';
      if (!enabled) {
        if (mounted) {
          AppToast.show(context, 'Aktifkan biometrik dari halaman Profil');
        }
        return;
      }
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) {
        if (mounted) AppToast.show(context, 'HP ini tidak mendukung biometrik');
        return;
      }
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) {
        if (mounted) {
          AppToast.show(context, 'Biometrik tidak aktif di pengaturan HP');
        }
        return;
      }
      final available = await _localAuth.getAvailableBiometrics();
      if (available.isEmpty) {
        if (mounted) {
          AppToast.show(context, 'Belum ada sidik jari/wajah terdaftar di HP');
        }
        return;
      }
      final ok = await _localAuth.authenticate(
        localizedReason: 'Gunakan biometrik untuk masuk ke DuitKita',
      );
      if (ok && mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (kDebugMode) print('[Biometric] error: $e');
      if (mounted) {
        AppToast.show(context, 'Gagal membuka biometrik. Coba lagi.');
      }
    }
  }

  Future<void> _switchAccount() async {
    final sync = ref.read(syncServiceProvider);
    if (await sync.hasPendingSync()) {
      await sync.pushAllPending();
      if (await sync.hasPendingSync()) {
        if (mounted) {
          AppToast.show(
            context,
            'Masih ada data belum tersinkron. Ganti akun dibatalkan.',
            success: false,
          );
        }
        return;
      }
    }

    final api = ref.read(apiClientProvider);
    try {
      await api.logout();
    } catch (_) {
      await api.clearToken();
    }
    await ref.read(dbProvider).clearAll();
    await ref.read(sessionRepoProvider).clear();
    if (mounted) context.go('/login');
  }
}

class _UserGreeting extends StatelessWidget {
  const _UserGreeting({required this.member, this.checking = false});
  final Member? member;
  final bool checking;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MemberAvatar(
          hue: member?.avatarHue ?? 162,
          initial: member?.name.isNotEmpty == true ? member!.name[0] : '?',
          size: 72,
          ring: true,
          ringColor: Colors.white,
          ringWidth: 2.5,
        ),
        const SizedBox(height: 16),
        Text(
          member != null ? 'Halo, ${member!.name}' : 'DuitKita',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          checking ? 'Memverifikasi...' : 'Masukkan PIN kamu',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}

class _PinDots extends StatelessWidget {
  const _PinDots({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        final filled = i < count;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.45),
                width: 1.5,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({
    required this.onDigit,
    required this.onBackspace,
    required this.onBiometric,
    required this.memberName,
    required this.onSwitchAccount,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onBiometric;
  final String memberName;
  final VoidCallback onSwitchAccount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row(['1', '2', '3']),
        const SizedBox(height: 12),
        _row(['4', '5', '6']),
        const SizedBox(height: 12),
        _row(['7', '8', '9']),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (onBiometric != null)
              _KpButton(
                onTap: onBiometric!,
                child: const Icon(
                  Icons.fingerprint_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              )
            else
              const SizedBox(width: 72, height: 72),
            const SizedBox(width: 16),
            _KpButton(
              onTap: () => onDigit('0'),
              child: Text(
                '0',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            _KpButton(
              onTap: onBackspace,
              faded: true,
              child: const Icon(
                Icons.backspace_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: onSwitchAccount,
          child: Text(
            'Bukan $memberName? Ganti akun',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.68),
              decoration: TextDecoration.underline,
              decorationColor: Colors.white.withValues(alpha: 0.38),
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _KpButton(
          onTap: () => onDigit(digits[0]),
          child: Text(
            digits[0],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        _KpButton(
          onTap: () => onDigit(digits[1]),
          child: Text(
            digits[1],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        _KpButton(
          onTap: () => onDigit(digits[2]),
          child: Text(
            digits[2],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _KpButton extends StatelessWidget {
  const _KpButton({
    required this.onTap,
    required this.child,
    this.faded = false,
  });
  final VoidCallback onTap;
  final Widget child;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: faded ? 0.08 : 0.13),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
