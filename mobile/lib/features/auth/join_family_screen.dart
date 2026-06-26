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
  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;

  String get _code => _ctrls.map((c) => c.text).join();

  @override
  void dispose() {
    for (final c in _ctrls) { c.dispose(); }
    for (final n in _nodes) { n.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final filled = _code.length == 6;

    return Scaffold(
      backgroundColor: colors.appBg,
      appBar: AppTopBar(title: 'Gabung Keluarga'),
      body: Padding(
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
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: SizedBox(
                    width: 46,
                    height: 58,
                    child: TextField(
                      controller: _ctrls[i],
                      focusNode: _nodes[i],
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
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
                        fillColor: filled ? colors.primaryTint : colors.surface,
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
                          borderSide:
                              BorderSide(color: colors.primary, width: 2),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: (filled && !_loading) ? _onJoin : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  disabledBackgroundColor: colors.surface3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text('Gabung Keluarga',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
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
          ],
        ),
      ),
    );
  }

  Future<void> _onJoin() async {
    setState(() => _loading = true);
    try {
      final api = ref.read(apiClientProvider);
      final data = await api.join({'code': _code.toUpperCase()});

      // Persist token returned by join
      final token = data['token'] as String?;
      if (token != null) await api.persistToken(token);

      // Save current user id
      final sessionRepo = ref.read(sessionRepoProvider);
      final userId = data['user']?['id'] as int?;
      if (userId != null) await sessionRepo.setCurrentUserId(userId);

      // Save invite code for this household
      final inviteCode = data['household']?['invite_code'] as String?;
      if (inviteCode != null) await sessionRepo.setInviteCode(inviteCode);

      // Clear stale local data then do a full pull
      await ref.read(dbProvider).clearAll();
      await ref.read(syncServiceProvider).initialPull();

      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal bergabung: $e')),
        );
      }
    }
  }
}
