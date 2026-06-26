import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  // Step 1: identifier input
  final _identifierCtrl = TextEditingController();

  // Step 2: OTP + new password
  final _otpCtrl        = TextEditingController();
  final _passCtrl       = TextEditingController();
  final _confirmCtrl    = TextEditingController();

  int    _step      = 1;
  bool   _loading   = false;
  bool   _obscure   = true;
  bool   _obscure2  = true;
  String? _error;
  String? _identifier; // locked after step 1

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _otpCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Step 1 — request OTP
  // -------------------------------------------------------------------------
  Future<void> _onSendOtp() async {
    final id = _identifierCtrl.text.trim();
    if (id.isEmpty) {
      setState(() => _error = 'Masukkan email atau nomor HP.');
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      final api  = ref.read(apiClientProvider);
      final data = await api.forgotPassword(id);

      // DEV: show OTP in a snackbar so testers can see it without email.
      final otp = data['otp'] as String?;
      if (otp != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('DEV — OTP kamu: $otp'),
            duration: const Duration(seconds: 10),
          ),
        );
      }

      setState(() {
        _loading    = false;
        _step       = 2;
        _identifier = id;
      });
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data['message'] as String?)
          : null;
      setState(() {
        _loading = false;
        _error   = msg ?? 'Gagal mengirim kode. Periksa koneksi kamu.';
      });
    } catch (e) {
      setState(() { _loading = false; _error = 'Error: $e'; });
    }
  }

  // -------------------------------------------------------------------------
  // Step 2 — verify OTP and reset password
  // -------------------------------------------------------------------------
  Future<void> _onResetPassword() async {
    final otp  = _otpCtrl.text.trim();
    final pass = _passCtrl.text;
    final conf = _confirmCtrl.text;

    if (otp.length != 6) {
      setState(() => _error = 'Masukkan 6 digit kode OTP.');
      return;
    }
    if (pass.length < 8) {
      setState(() => _error = 'Password minimal 8 karakter.');
      return;
    }
    if (pass != conf) {
      setState(() => _error = 'Konfirmasi password tidak cocok.');
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      final api = ref.read(apiClientProvider);
      await api.resetPassword({
        'identifier':            _identifier,
        'otp':                   otp,
        'password':              pass,
        'password_confirmation': conf,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil diubah. Silakan login.')),
      );
      context.go('/login');
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data['message'] as String?)
          : null;
      setState(() {
        _loading = false;
        _error   = msg ?? 'Gagal mereset password.';
      });
    } catch (e) {
      setState(() { _loading = false; _error = 'Error: $e'; });
    }
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.appBg,
      appBar: AppBar(
        backgroundColor: colors.appBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.text, size: 20),
          onPressed: () {
            if (_step == 2) {
              setState(() { _step = 1; _error = null; });
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              // Icon
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colors.primaryTint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.lock_reset_rounded, color: colors.primary, size: 28),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  _step == 1 ? 'Lupa Sandi' : 'Reset Password',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.02 * 27,
                    color: colors.text,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _step == 1
                      ? 'Masukkan email atau nomor HP kamu untuk menerima kode OTP.'
                      : 'Masukkan kode OTP yang dikirim, lalu buat password baru.',
                  textAlign: TextAlign.center,
                  style: AppText.label(color: colors.text3),
                ),
              ),
              const SizedBox(height: 32),

              if (_step == 1) ...[
                _InputField(
                  controller: _identifierCtrl,
                  label: 'Email atau No. HP',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
              ] else ...[
                // OTP field
                _InputField(
                  controller: _otpCtrl,
                  label: 'Kode OTP (6 digit)',
                  icon: Icons.pin_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                // New password
                _InputField(
                  controller: _passCtrl,
                  label: 'Password baru',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscure,
                  suffix: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                      color: colors.text3,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                const SizedBox(height: 12),
                // Confirm password
                _InputField(
                  controller: _confirmCtrl,
                  label: 'Konfirmasi password',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscure2,
                  suffix: IconButton(
                    icon: Icon(
                      _obscure2 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                      color: colors.text3,
                    ),
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                  ),
                ),
              ],

              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.expenseTint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_error!, style: AppText.label(color: colors.expense)),
                ),
              ],

              const SizedBox(height: 20),

              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : (_step == 1 ? _onSendOtp : _onResetPassword),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          _step == 1 ? 'Kirim Kode' : 'Ubah Password',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              if (_step == 2) ...[
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _loading ? null : () {
                      setState(() { _step = 1; _error = null; _otpCtrl.clear(); });
                    },
                    child: Text('Kirim ulang kode', style: AppText.label(color: colors.primary)),
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable input field (same style as login_screen.dart)
// ---------------------------------------------------------------------------
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
  final String                 label;
  final IconData               icon;
  final TextInputType?         keyboardType;
  final bool                   obscure;
  final Widget?                suffix;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      height: 52,
      child: TextField(
        controller:   controller,
        keyboardType: keyboardType,
        obscureText:  obscure,
        style:        AppText.body(color: colors.text),
        decoration: InputDecoration(
          labelText:  label,
          prefixIcon: Icon(icon, size: 20, color: colors.text3),
          suffixIcon: suffix,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          filled:    true,
          fillColor: colors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:   BorderSide(color: colors.border2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:   BorderSide(color: colors.border2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:   BorderSide(color: colors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
