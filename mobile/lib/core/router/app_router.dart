import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/shell/shell_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/transactions/transactions_screen.dart';
import '../../features/wallets/wallets_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/add_transaction/add_transaction_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => ShellScreen(
        navigationShell: navigationShell,
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/transactions',
              builder: (context, state) => const TransactionsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/wallets',
              builder: (context, state) => const WalletsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/add-transaction',
      pageBuilder: (context, state) => MaterialPage(
        fullscreenDialog: true,
        child: const AddTransactionScreen(),
        key: state.pageKey,
      ),
    ),
  ],
);
