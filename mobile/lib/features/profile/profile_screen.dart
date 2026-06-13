import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../features/home/providers/home_providers.dart';
import '../../ui/widgets/app_sheet.dart';
import '../../ui/widgets/app_toast.dart';
import '../../ui/widgets/entrance_animation.dart';
import '../../ui/widgets/member_avatar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final userIdAsync = ref.watch(currentUserIdProvider);
    final userId = userIdAsync.value ?? 1;
    final members = ref.watch(membersProvider).value ?? [];
    final householdNameAsync = ref.watch(householdNameProvider);
    final householdName =
        householdNameAsync.value ?? 'Keluarga';

    final currentMember = members.cast<Member?>().firstWhere(
          (m) => m?.id == userId,
          orElse: () => members.isNotEmpty ? members.first : null,
        );

    final isOwner = currentMember?.role == 'owner';

    return Scaffold(
      backgroundColor: colors.appBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text(
                  'Profil',
                  style: AppText.screenTitle(color: colors.text),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Profile card
                  if (currentMember != null)
                    EntranceAnimation(
                      child: _ProfileCard(
                          member: currentMember),
                    ),
                  const SizedBox(height: 12),
                  // Family card
                  EntranceAnimation(
                    delay: const Duration(milliseconds: 60),
                    child: _FamilyCard(
                      householdName: householdName,
                      members: members,
                      currentUserId: userId,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // AKUN section
                  EntranceAnimation(
                    delay: const Duration(milliseconds: 100),
                    child: _SectionTitle(title: 'AKUN'),
                  ),
                  const SizedBox(height: 8),
                  EntranceAnimation(
                    delay: const Duration(milliseconds: 120),
                    child: _SettingsCard(children: [
                      _SettingsTile(
                        icon: Icons.person_outline_rounded,
                        label: 'Edit profil',
                        onTap: () {
                          if (currentMember != null) {
                            AppSheet.show(
                              context: context,
                              child:
                                  _EditProfileSheet(member: currentMember),
                            );
                          }
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.lock_clock_outlined,
                        label: 'Ganti PIN',
                        onTap: () {
                          AppSheet.show(
                            context: context,
                            child: _ChangePinSheet(),
                          );
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.security_outlined,
                        label: 'Keamanan & biometrik',
                        trailing: _BiometricToggle(),
                        onTap: null,
                      ),
                    ]),
                  ),
                  // KELOLA KELUARGA — owner only
                  if (isOwner) ...[
                    const SizedBox(height: 20),
                    EntranceAnimation(
                      delay: const Duration(milliseconds: 160),
                      child: _SectionTitle(
                        title: 'KELOLA KELUARGA',
                        badge: 'Owner',
                      ),
                    ),
                    const SizedBox(height: 8),
                    EntranceAnimation(
                      delay: const Duration(milliseconds: 180),
                      child: _SettingsCard(children: [
                        _SettingsTile(
                          icon: Icons.group_outlined,
                          label: 'Kelola anggota',
                          onTap: () => AppToast.show(
                              context, 'Segera hadir'),
                        ),
                        _SettingsTile(
                          icon: Icons.category_outlined,
                          label: 'Kelola kategori',
                          onTap: () => AppToast.show(
                              context, 'Segera hadir'),
                        ),
                        _SettingsTile(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Kelola dompet',
                          onTap: () => AppToast.show(
                              context, 'Segera hadir'),
                        ),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 20),
                  // APLIKASI section
                  EntranceAnimation(
                    delay: const Duration(milliseconds: 200),
                    child: _SectionTitle(title: 'APLIKASI'),
                  ),
                  const SizedBox(height: 8),
                  EntranceAnimation(
                    delay: const Duration(milliseconds: 220),
                    child: _SettingsCard(children: [
                      _DarkModeToggle(),
                      _SettingsTile(
                        icon: Icons.notifications_outlined,
                        label: 'Notifikasi',
                        onTap: () => context.push('/notifications'),
                      ),
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        label: 'Tentang DuitKita',
                        onTap: () => _showAboutDialog(context),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 24),
                  // Logout button
                  EntranceAnimation(
                    delay: const Duration(milliseconds: 260),
                    child: _LogoutButton(),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final colors = context.appColors;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Tentang DuitKita',
            style: AppText.cardTitle(color: colors.text)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DuitKita', style: AppText.body(color: colors.text).copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Versi 1.4', style: AppText.label(color: colors.text2)),
            const SizedBox(height: 8),
            Text(
              'Aplikasi keuangan keluarga untuk mencatat dan mengelola pengeluaran bersama.',
              style: AppText.body(color: colors.text2),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Tutup',
                style: AppText.body(color: colors.primary)
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile card
// ---------------------------------------------------------------------------

class _ProfileCard extends ConsumerWidget {
  const _ProfileCard({required this.member});
  final Member member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final isOwner = member.role == 'owner';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.borderRadiusBase,
        border: Border.all(color: colors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          MemberAvatar(
            hue: member.avatarHue,
            initial: member.name.isNotEmpty ? member.name[0] : '?',
            size: 60,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.name,
                        style: AppText.cardTitle(color: colors.text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _RoleBadge(isOwner: isOwner),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  member.email,
                  style: AppText.label(color: colors.text3),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              AppSheet.show(
                context: context,
                child: _EditProfileSheet(member: member),
              );
            },
            icon: Icon(Icons.edit_outlined, color: colors.text3, size: 20),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Family card
// ---------------------------------------------------------------------------

class _FamilyCard extends StatelessWidget {
  const _FamilyCard({
    required this.householdName,
    required this.members,
    required this.currentUserId,
  });

  final String householdName;
  final List<Member> members;
  final int currentUserId;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.borderRadiusBase,
        border: Border.all(color: colors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colors.primaryTint,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(Icons.group_outlined,
                      color: colors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(householdName,
                          style: AppText.cardTitle(color: colors.text)),
                      const SizedBox(height: 2),
                      Text(
                        '${members.length} anggota',
                        style: AppText.label(color: colors.text3),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showInviteSheet(context),
                  icon: Icon(Icons.add_rounded,
                      color: colors.primary, size: 16),
                  label: Text(
                    'Undang',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: colors.primaryTint,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.sm)),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.border),
          ...members.asMap().entries.map((entry) {
            final idx = entry.key;
            final m = entry.value;
            final isCurrentUser = m.id == currentUserId;
            final isOwner = m.role == 'owner';

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 11),
                  child: Row(
                    children: [
                      MemberAvatar(
                        hue: m.avatarHue,
                        initial:
                            m.name.isNotEmpty ? m.name[0] : '?',
                        size: 34,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isCurrentUser ? '${m.name} (kamu)' : m.name,
                          style: AppText.body(color: colors.text)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        isOwner ? 'Owner' : 'Anggota',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color:
                              isOwner ? colors.primary : colors.text3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (idx < members.length - 1)
                  Divider(
                    height: 1,
                    color: colors.border,
                    indent: 62,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _showInviteSheet(BuildContext context) {
    AppSheet.show(
      context: context,
      child: const _InviteSheet(),
    );
  }
}

// ---------------------------------------------------------------------------
// Role badge
// ---------------------------------------------------------------------------

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.isOwner});
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOwner ? colors.primaryTint : colors.surface2,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isOwner ? 'Owner' : 'Anggota',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: isOwner ? colors.primary : colors.text2,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section title
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.badge});
  final String title;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: colors.text3,
            letterSpacing: 0.8,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: colors.primaryTint,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              badge!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: colors.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Settings card + tile
// ---------------------------------------------------------------------------

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.borderRadiusBase,
        border: Border.all(color: colors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final idx = entry.key;
          return Column(
            children: [
              entry.value,
              if (idx < children.length - 1)
                Divider(height: 1, color: colors.border, indent: 52),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderRadiusBase,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.surface2,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: colors.text2, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: AppText.body(color: colors.text)
                      .copyWith(fontWeight: FontWeight.w600)),
            ),
            trailing ??
                Icon(Icons.chevron_right_rounded,
                    color: colors.text3, size: 18),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dark mode toggle
// ---------------------------------------------------------------------------

class _DarkModeToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colors.surface2,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(Icons.dark_mode_outlined, color: colors.text2, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Mode gelap',
                style: AppText.body(color: colors.text)
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
          Switch(
            value: isDark,
            onChanged: (v) {
              ref
                  .read(themeModeProvider.notifier)
                  .setThemeMode(v ? ThemeMode.dark : ThemeMode.light);
            },
            activeThumbColor: colors.primary,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Biometric toggle
// ---------------------------------------------------------------------------

class _BiometricToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final biometricAsync = ref.watch(
      StreamProvider.autoDispose<bool>(
        (ref) => ref
            .watch(sessionRepoProvider)
            .watch('biometricEnabled')
            .map((v) => v == 'true'),
      ),
    );
    final enabled = biometricAsync.value ?? false;

    return Switch(
      value: enabled,
      onChanged: (v) async {
        await ref
            .read(sessionRepoProvider)
            .set('biometricEnabled', v.toString());
      },
      activeThumbColor: colors.primary,
    );
  }
}

// ---------------------------------------------------------------------------
// Invite sheet
// ---------------------------------------------------------------------------

class _InviteSheet extends ConsumerWidget {
  const _InviteSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final codeAsync = ref.watch(inviteCodeProvider);
    final code = codeAsync.value ?? '------';
    final hasCode = codeAsync.value != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Undang Anggota',
              style: AppText.screenTitle(color: colors.text)),
          const SizedBox(height: 8),
          Text(
            'Bagikan kode ini kepada anggota keluarga yang ingin bergabung.',
            style: AppText.body(color: colors.text2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: colors.primaryTint,
              borderRadius: BorderRadius.circular(AppRadius.base),
              border: Border.all(color: colors.primaryTint2),
            ),
            child: codeAsync.isLoading
                ? SizedBox(
                    height: 48,
                    child: Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: colors.primary),
                    ),
                  )
                : Text(
                    code,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: hasCode ? colors.primary : colors.text2,
                      letterSpacing: 8,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: hasCode
                        ? () {
                            Clipboard.setData(ClipboardData(text: code));
                            Navigator.of(context).pop();
                            AppToast.show(context, 'Kode disalin ke clipboard');
                          }
                        : null,
                    icon: const Icon(Icons.copy_rounded, size: 17),
                    label: const Text('Salin'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm)),
                      elevation: 0,
                      textStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      AppToast.show(context, 'Segera hadir');
                    },
                    icon: const Icon(Icons.share_outlined, size: 17),
                    label: const Text('Bagikan'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.border2, width: 1.5),
                      foregroundColor: colors.text,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm)),
                      textStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Edit profile sheet
// ---------------------------------------------------------------------------

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet({required this.member});
  final Member member;

  @override
  ConsumerState<_EditProfileSheet> createState() =>
      _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.member.name);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _saving) return;
    setState(() => _saving = true);
    await ref.read(memberRepoProvider).upsert(
          MembersCompanion(
            id: Value(widget.member.id),
            name: Value(name),
            email: Value(widget.member.email),
            role: Value(widget.member.role),
            avatarHue: Value(widget.member.avatarHue),
          ),
        );
    if (mounted) {
      Navigator.of(context).pop();
      AppToast.show(context, 'Profil diperbarui');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edit Profil',
              style: AppText.screenTitle(color: colors.text)),
          const SizedBox(height: 16),
          Text('Nama', style: AppText.label(color: colors.text2)),
          const SizedBox(height: 6),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            style: AppText.body(color: colors.text),
            decoration: InputDecoration(
              filled: true,
              fillColor: colors.surface2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide:
                    BorderSide(color: colors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _nameCtrl.text.trim().isNotEmpty && !_saving
                  ? _save
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                disabledBackgroundColor: colors.surface3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.base),
                ),
                elevation: 0,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Simpan',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Change PIN sheet
// ---------------------------------------------------------------------------

class _ChangePinSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ChangePinSheet> createState() => _ChangePinSheetState();
}

class _ChangePinSheetState extends ConsumerState<_ChangePinSheet> {
  final _ctrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final pin = _ctrl.text.trim();
    if (pin.length != 6 || _saving) return;
    setState(() => _saving = true);
    await ref.read(sessionRepoProvider).set('userPin', pin);
    if (mounted) {
      Navigator.of(context).pop();
      AppToast.show(context, 'PIN berhasil diperbarui');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ganti PIN',
              style: AppText.screenTitle(color: colors.text)),
          const SizedBox(height: 8),
          Text(
            'Masukkan PIN baru (6 digit)',
            style: AppText.body(color: colors.text2),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            autofocus: true,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            style: AppText.body(color: colors.text),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: colors.surface2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide:
                    BorderSide(color: colors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              hintText: '••••••',
              hintStyle: AppText.body(color: colors.text3),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _ctrl.text.length == 6 && !_saving ? _save : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                disabledBackgroundColor: colors.surface3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.base),
                ),
                elevation: 0,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Simpan PIN',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Logout button
// ---------------------------------------------------------------------------

class _LogoutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutConfirm(context, ref),
        icon: Icon(Icons.logout_rounded, color: colors.expense, size: 18),
        label: Text(
          'Keluar',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: colors.expense,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: colors.expenseTint,
          side: BorderSide(color: colors.expense.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.base)),
        ),
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context, WidgetRef ref) {
    AppSheet.show<bool>(
      context: context,
      child: _LogoutConfirmSheet(),
    ).then((confirmed) async {
      if (confirmed == true) {
        await ref.read(sessionRepoProvider).set('currentUserId', '');
        if (context.mounted) {
          context.go('/login');
        }
      }
    });
  }
}

class _LogoutConfirmSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Keluar dari DuitKita',
              style: AppText.screenTitle(color: colors.text)),
          const SizedBox(height: 12),
          Text(
            'Kamu akan keluar dari akun. Data lokal tetap tersimpan di perangkat.',
            style: AppText.body(color: colors.text2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.border2),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.sm)),
                    padding:
                        const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: Text('Batal',
                      style: AppText.body(color: colors.text2)
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.expense,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.sm)),
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: Text('Keluar',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
