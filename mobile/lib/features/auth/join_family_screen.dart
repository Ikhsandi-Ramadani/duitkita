import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/providers.dart';
import '../../ui/widgets/app_top_bar.dart';

class JoinFamilyScreen extends ConsumerStatefulWidget {
  const JoinFamilyScreen({super.key});

  @override
  ConsumerState<JoinFamilyScreen> createState() => _JoinFamilyScreenState();
}

class _JoinFamilyScreenState extends ConsumerState<JoinFamilyScreen> {
  final List<TextEditingController> _ctrls = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  String get _code => _ctrls.map((c) => c.text).join();

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final valid =
        _code.length == 6 &&
        _nameCtrl.text.trim().isNotEmpty &&
        _emailCtrl.text.trim().contains('@') &&
        _passwordCtrl.text.length >= 8;

    return Scaffold(
      backgroundColor: colors.appBg,
      appBar: AppTopBar(title: 'Gabung Keluarga'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 28),
            Text(
              'Masukkan kode undangan 6 karakter\nyang diberikan oleh pemilik keluarga.',
              style: AppText.body(color: colors.text2),
            ),
            const SizedBox(height: 28),
            // 6 code boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) {
                final filled = _ctrls[i].text.isNotEmpty;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SizedBox(
                      height: 58,
                      child: TextField(
                        controller: _ctrls[i],
                        focusNode: _nodes[i],
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp('[A-Za-z0-9]'),
                          ),
                        ],
                        onChanged: (v) {
                          setState(() {});
                          if (v.isNotEmpty && i < 5) {
                            _nodes[i + 1].requestFocus();
                          }
                        },
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                          filled: true,
                          fillColor: filled
                              ? colors.primaryTint
                              : colors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: filled ? colors.primary : colors.border2,
                              width: filled ? 1.5 : 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: filled ? colors.primary : colors.border2,
                              width: filled ? 1.5 : 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: colors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            _JoinField(
              controller: _nameCtrl,
              label: 'Nama lengkap',
              icon: Icons.person_outline_rounded,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            _JoinField(
              controller: _emailCtrl,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            _JoinField(
              controller: _phoneCtrl,
              label: 'Nomor HP (opsional)',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            _JoinField(
              controller: _passwordCtrl,
              label: 'Kata sandi (minimal 8 karakter)',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscure,
              onChanged: (_) => setState(() {}),
              suffix: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: colors.text3,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: (valid && !_loading) ? _onJoin : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  disabledBackgroundColor: colors.surface3,
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
                        'Gabung Keluarga',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Pastikan kamu sudah mendapat kode dari pemilik keluarga.',
                style: AppText.label(color: colors.text3),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Future<void> _onJoin() async {
    setState(() => _loading = true);
    try {
      final api = ref.read(apiClientProvider);
      final body = <String, dynamic>{
        'invite_code': _code.toUpperCase(),
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'password': _passwordCtrl.text,
      };
      if (_phoneCtrl.text.trim().isNotEmpty) {
        body['phone'] = _phoneCtrl.text.trim();
      }
      await api.join(body);

      // Clear stale local data then do a full pull
      await ref.read(dbProvider).clearAll();
      await ref.read(sessionRepoProvider).clear();
      try {
        await ref.read(syncServiceProvider).initialPull();
      } catch (_) {
        await api.clearToken();
        rethrow;
      }

      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal bergabung: $e')));
      }
    }
  }
}

class _JoinField extends StatelessWidget {
  const _JoinField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffix,
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
    );
  }
}
