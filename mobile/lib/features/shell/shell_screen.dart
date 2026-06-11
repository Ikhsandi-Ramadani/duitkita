import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/app_bottom_nav.dart';

class ShellScreen extends StatelessWidget {
  const ShellScreen({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onAddTap: () => context.push('/add-transaction'),
      ),
    );
  }
}
