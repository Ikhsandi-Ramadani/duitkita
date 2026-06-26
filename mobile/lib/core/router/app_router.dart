import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers.dart';
import '../../features/shell/shell_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/transactions/transactions_screen.dart';
import '../../features/wallets/wallets_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/add_transaction/add_transaction_screen.dart';
import '../../features/auth/app_lock_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/create_family_screen.dart';
import '../../features/auth/join_family_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/budget/budget_screen.dart';
import '../../features/goals/goals_screen.dart';
import '../../features/debts/debts_screen.dart';
import '../../features/recurring/recurring_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/transactions/transaction_detail_screen.dart';
import '../../features/wallets/wallet_detail_screen.dart';
import '../../features/goals/goal_detail_screen.dart';
import '../../features/debts/debt_detail_screen.dart';
import '../../features/categories/categories_screen.dart';

// Router provider so we can inject Riverpod for the redirect guard.
final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      final userId = await ref.read(sessionRepoProvider).getCurrentUserId();
      final loc = state.matchedLocation;

      // Always allow splash to render
      if (loc.startsWith('/splash')) return null;

      // No session user → force login
      if (userId == null) {
        if (loc.startsWith('/login')) return null;
        if (loc.startsWith('/forgot-password')) return null;
        return '/login';
      }

      // Has session user but on login → send to lock
      if (loc.startsWith('/login')) {
        return '/lock';
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth routes (no shell)
      GoRoute(
        path: '/lock',
        builder: (context, state) => const AppLockScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) => const CreateFamilyScreen(),
          ),
          GoRoute(
            path: 'join',
            builder: (context, state) => const JoinFamilyScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main shell with bottom nav (4 branches)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ShellScreen(navigationShell: navigationShell),
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

      // Full-screen routes (no shell / bottom nav)
      GoRoute(
        path: '/add-transaction',
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          key: state.pageKey,
          child: const AddTransactionScreen(),
        ),
      ),
      GoRoute(
        path: '/budget',
        builder: (context, state) => const BudgetScreen(),
      ),
      GoRoute(
        path: '/goals',
        builder: (context, state) => const GoalsScreen(),
      ),
      GoRoute(
        path: '/debts',
        builder: (context, state) => const DebtsScreen(),
      ),
      GoRoute(
        path: '/recurring',
        builder: (context, state) => const RecurringScreen(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesScreen(),
      ),

      // Detail routes (pushed, no bottom nav)
      GoRoute(
        path: '/transaction/:clientId',
        builder: (context, state) => TransactionDetailScreen(
          clientId: state.pathParameters['clientId']!,
        ),
      ),
      GoRoute(
        path: '/wallet/:id',
        builder: (context, state) => WalletDetailScreen(
          walletId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/goal/:id',
        builder: (context, state) => GoalDetailScreen(
          goalId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/debt/:id',
        builder: (context, state) => DebtDetailScreen(
          debtId: int.parse(state.pathParameters['id']!),
        ),
      ),
    ],
  );
  return router;
});
