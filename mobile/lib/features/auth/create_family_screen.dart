import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/providers.dart';
import '../../ui/widgets/app_top_bar.dart';

class CreateFamilyScreen extends ConsumerStatefulWidget {
  const CreateFamilyScreen({super.key});

  @override
  ConsumerState<CreateFamilyScreen> createState() => _CreateFamilyScreenState();
}

class _CreateFamilyScreenState extends ConsumerState<CreateFamilyScreen> {
  final _nameCtrl = TextEditingController();
  final _familyCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _familyCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final canSubmit =
        _nameCtrl.text.isNotEmpty &&
        _familyCtrl.text.isNotEmpty &&
        _emailCtrl.text.isNotEmpty &&
        _passCtrl.text.isNotEmpty;

    return Scaffold(
      backgroundColor: colors.appBg,
      appBar: AppTopBar(title: 'Buat Keluarga'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              'Mulai perjalanan keuangan keluargamu',
              style: AppText.sectionTitle(color: colors.text2),
            ),
            const SizedBox(height: 20),
            _Field(
              ctrl: _nameCtrl,
              label: 'Nama kamu',
              icon: Icons.person_outline,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            _Field(
              ctrl: _familyCtrl,
              label: 'Nama keluarga',
              icon: Icons.home_outlined,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            _Field(
              ctrl: _emailCtrl,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            _Field(
              ctrl: _phoneCtrl,
              label: 'No. HP (opsional)',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            _Field(
              ctrl: _passCtrl,
              label: 'Kata sandi',
              icon: Icons.lock_outline_rounded,
              obscure: _obscure,
              onChanged: (_) => setState(() {}),
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
            const SizedBox(height: 16),
            // Info box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.primaryTint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: colors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Kamu akan menjadi pemilik keluarga dan bisa mengundang anggota lain lewat kode undangan.',
                      style: AppText.label(color: colors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: (!canSubmit || _loading) ? null : _onSubmit,
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
                        'Buat & Mulai',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    setState(() => _loading = true);
    try {
      final api = ref.read(apiClientProvider);
      final body = {
        'name': _nameCtrl.text.trim(),
        'family_name': _familyCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'password': _passCtrl.text,
      };
      if (_phoneCtrl.text.trim().isNotEmpty) {
        body['phone'] = _phoneCtrl.text.trim();
      }
      await api.register(body);

      // Pull fresh data from server
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
        ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
    this.onChanged,
  });

  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      height: 52,
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        obscureText: obscure,
        onChanged: onChanged,
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
