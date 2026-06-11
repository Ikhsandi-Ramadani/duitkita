import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_dimens.dart';

// Note: lucide_icons 0.257.0 is incompatible with Dart 3.12 (IconData is final).
// Using Material Icons as fallback — tracked for lucide replacement when compatible version ships.

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onAddTap,
  });

  final int currentIndex;
  final VoidCallback onAddTap;

  static const _navItems = [
    _NavItem(label: 'Beranda', icon: Icons.home_outlined, activeIcon: Icons.home),
    _NavItem(label: 'Transaksi', icon: Icons.swap_horiz_outlined, activeIcon: Icons.swap_horiz),
    _NavItem(label: 'Dompet', icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet),
    _NavItem(label: 'Profil', icon: Icons.person_outline, activeIcon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.border, width: 1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, -6),
            blurRadius: 24,
          ),
        ],
      ),
      child: SizedBox(
        height: 76 + bottomPadding,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _NavButton(
                  item: _navItems[0],
                  isActive: currentIndex == 0,
                  onTap: () => _onTap(context, 0),
                ),
              ),
              Expanded(
                child: _NavButton(
                  item: _navItems[1],
                  isActive: currentIndex == 1,
                  onTap: () => _onTap(context, 1),
                ),
              ),
              SizedBox(
                width: 72,
                child: Center(
                  child: _FabButton(onTap: onAddTap, colors: colors),
                ),
              ),
              Expanded(
                child: _NavButton(
                  item: _navItems[2],
                  isActive: currentIndex == 2,
                  onTap: () => _onTap(context, 2),
                ),
              ),
              Expanded(
                child: _NavButton(
                  item: _navItems[3],
                  isActive: currentIndex == 3,
                  onTap: () => _onTap(context, 3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    const routes = ['/home', '/transactions', '/wallets', '/profile'];
    context.go(routes[index]);
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = isActive ? colors.primary : colors.text3;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isActive ? item.activeIcon : item.icon,
            color: color,
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: AppText.micro(color: color).copyWith(
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FabButton extends StatelessWidget {
  const _FabButton({required this.onTap, required this.colors});

  final VoidCallback onTap;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.only(bottom: 22),
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: AppRadius.borderRadiusBase,
          boxShadow: AppShadows.primaryShadow,
        ),
        child: Icon(
          Icons.add,
          color: colors.onPrimary,
          size: 28,
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}
