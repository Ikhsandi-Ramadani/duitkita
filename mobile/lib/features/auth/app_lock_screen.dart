import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../ui/widgets/member_avatar.dart';

class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  final List<String> _digits = [];
  bool _checking = false;
  final _localAuth = LocalAuthentication();

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(membersProvider);
    final userIdAsync = ref.watch(currentUserIdProvider);
    final sessionRepo = ref.watch(sessionRepoProvider);

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
          child: Column(
            children: [
              const Spacer(flex: 2),
              _BrandMark(sessionRepo: sessionRepo),
              const Spacer(flex: 2),
              _UserGreeting(member: member),
              const SizedBox(height: 20),
              _PinDots(count: _digits.length),
              const Spacer(flex: 2),
              _Keypad(
                onDigit: _onDigit,
                onBackspace: _onBackspace,
                onBiometric: _onBiometric,
                memberName: member?.name ?? 'kamu',
                onSwitchAccount: () => context.go('/login'),
              ),
              const Spacer(flex: 1),
            ],
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
    setState(() => _checking = true);
    await Future.delayed(const Duration(milliseconds: 220));
    if (mounted) context.go('/home');
  }

  Future<void> _onBiometric() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return;
      final ok = await _localAuth.authenticate(
        localizedReason: 'Gunakan biometrik untuk masuk ke DuitKita',
      );
      if (ok && mounted) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) context.go('/home');
      }
    } catch (_) {
      // Graceful no-op on Windows or unavailable biometric
    }
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.sessionRepo});
  final dynamic sessionRepo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
          ),
          child: const Icon(Icons.account_balance_wallet_outlined,
              color: Colors.white, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          'DuitKita',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        FutureBuilder<String?>(
          future: sessionRepo.get('householdName') as Future<String?>,
          builder: (_, snap) => Text(
            snap.data ?? 'Keuangan Keluarga',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ),
      ],
    );
  }
}

class _UserGreeting extends StatelessWidget {
  const _UserGreeting({required this.member});
  final Member? member;

  @override
  Widget build(BuildContext context) {
    if (member == null) return const SizedBox.shrink();
    return Column(
      children: [
        MemberAvatar(
          hue: member!.avatarHue,
          initial: member!.name.isNotEmpty ? member!.name[0] : '?',
          size: 64,
          ring: true,
          ringColor: Colors.white,
          ringWidth: 2.5,
        ),
        const SizedBox(height: 12),
        Text(
          'Halo, ${member!.name}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Masukkan PIN kamu',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.78),
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
  final VoidCallback onBiometric;
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
            _KpButton(onTap: onBiometric,
                child: const Icon(Icons.fingerprint_rounded, color: Colors.white, size: 30)),
            const SizedBox(width: 16),
            _KpButton(
                onTap: () => onDigit('0'),
                child: Text('0',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 26, fontWeight: FontWeight.w600, color: Colors.white))),
            const SizedBox(width: 16),
            _KpButton(
                onTap: onBackspace,
                faded: true,
                child: const Icon(Icons.backspace_outlined, color: Colors.white, size: 24)),
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
            child: Text(digits[0],
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 26, fontWeight: FontWeight.w600, color: Colors.white))),
        const SizedBox(width: 16),
        _KpButton(
            onTap: () => onDigit(digits[1]),
            child: Text(digits[1],
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 26, fontWeight: FontWeight.w600, color: Colors.white))),
        const SizedBox(width: 16),
        _KpButton(
            onTap: () => onDigit(digits[2]),
            child: Text(digits[2],
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 26, fontWeight: FontWeight.w600, color: Colors.white))),
      ],
    );
  }
}

class _KpButton extends StatelessWidget {
  const _KpButton({required this.onTap, required this.child, this.faded = false});
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
