import 'package:absensi_dashboard/features/attendance/presentation/attendance_detail_screen.dart';
import 'package:absensi_dashboard/features/attendance/presentation/attendance_screen.dart';
import 'package:absensi_dashboard/features/auth/presentation/login_screen.dart';
import 'package:absensi_dashboard/features/auth/presentation/splash_screen.dart';
import 'package:absensi_dashboard/features/dashboard/presentation/dashboard_screen.dart';
import 'package:absensi_dashboard/features/employees/presentation/employee_detail_screen.dart';
import 'package:absensi_dashboard/features/employees/presentation/employee_form_screen.dart';
import 'package:absensi_dashboard/features/employees/presentation/employees_screen.dart';
import 'package:absensi_dashboard/features/leave/presentation/leave_screen.dart';
import 'package:absensi_dashboard/features/reports/presentation/reports_screen.dart';
import 'package:absensi_dashboard/features/settings/presentation/settings_notifier.dart';
import 'package:absensi_dashboard/features/settings/presentation/settings_screen.dart';
import 'package:absensi_dashboard/features/shell/presentation/app_shell.dart';
import 'package:absensi_dashboard/features/shell/presentation/soon_screen.dart';
import 'package:absensi_dashboard/l10n/gen/app_localizations.dart';
import 'package:absensi_dashboard/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Notifier bridge so go_router can refresh on auth changes.
final class _RouterRefresh extends ChangeNotifier {
  void ping() => notifyListeners();
}

/// Single GoRouter for the whole app, exposed via Riverpod.
final Provider<GoRouter> appRouterProvider = Provider<GoRouter>(
  (Ref ref) {
    final _RouterRefresh refresh = _RouterRefresh();
    ref.listen<bool>(
      authProvider.select((AuthState value) => value.loggedIn),
      (bool? previous, bool next) => refresh.ping(),
    );

    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: refresh,
      redirect: (BuildContext context, GoRouterState state) {
        final bool loggedIn = ref.read(authProvider).loggedIn;
        final String location = state.matchedLocation;
        const List<String> public = <String>['/splash', '/login'];
        if (!loggedIn && !public.contains(location)) {
          return '/login';
        }
        if (loggedIn && location == '/login') {
          return '/home';
        }
        return null;
      },
      errorBuilder: (BuildContext context, GoRouterState state) =>
          const NotFoundScreen(),
      routes: <RouteBase>[
        GoRoute(
          path: '/splash',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              motionPage(
                context: context,
                state: state,
                child: const SplashScreen(),
              ),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              motionPage(
                context: context,
                state: state,
                child: const LoginScreen(),
              ),
        ),
        GoRoute(
          path: '/leave',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              motionPage(
                context: context,
                state: state,
                child: const LeaveScreen(),
              ),
        ),
        GoRoute(
          path: '/soon/:key',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              motionPage(
                context: context,
                state: state,
                child: SoonScreen(
                  key: ValueKey<String>(state.pathParameters['key'] ?? 'soon'),
                  soonKey: state.pathParameters['key'] ?? 'soon',
                ),
              ),
        ),
        StatefulShellRoute.indexedStack(
          builder:
              (
                BuildContext context,
                GoRouterState state,
                StatefulNavigationShell shell,
              ) {
                return AppShell(shell: shell);
              },
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/home',
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      motionPage(
                        context: context,
                        state: state,
                        child: const DashboardScreen(),
                      ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/attendance',
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      motionPage(
                        context: context,
                        state: state,
                        child: const AttendanceScreen(),
                      ),
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'record/:id',
                      pageBuilder:
                          (BuildContext context, GoRouterState state) =>
                              motionPage(
                                context: context,
                                state: state,
                                child: AttendanceDetailScreen(
                                  recordId: state.pathParameters['id'] ?? '',
                                ),
                              ),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/employees',
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      motionPage(
                        context: context,
                        state: state,
                        child: const EmployeesScreen(),
                      ),
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'new',
                      pageBuilder:
                          (BuildContext context, GoRouterState state) =>
                              motionPage(
                                context: context,
                                state: state,
                                child: const EmployeeFormScreen(),
                              ),
                    ),
                    GoRoute(
                      path: ':id',
                      pageBuilder:
                          (BuildContext context, GoRouterState state) =>
                              motionPage(
                                context: context,
                                state: state,
                                child: EmployeeDetailScreen(
                                  employeeId: state.pathParameters['id'] ?? '',
                                ),
                              ),
                      routes: <RouteBase>[
                        GoRoute(
                          path: 'edit',
                          pageBuilder:
                              (
                                BuildContext context,
                                GoRouterState state,
                              ) => motionPage(
                                context: context,
                                state: state,
                                child: EmployeeFormScreen(
                                  employeeId: state.pathParameters['id'],
                                ),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/reports',
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      motionPage(
                        context: context,
                        state: state,
                        child: const ReportsScreen(),
                      ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/settings',
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      motionPage(
                        context: context,
                        state: state,
                        child: const SettingsScreen(),
                      ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  },
);

/// Page with a fade/slide transition that becomes instant when the
/// platform requests reduced motion.
CustomTransitionPage<void> motionPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  final bool reduce = MediaQuery.of(context).disableAnimations;
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: reduce ? Duration.zero : AppDurations.normal,
    reverseTransitionDuration: reduce ? Duration.zero : AppDurations.fast,
    transitionsBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          if (MediaQuery.of(context).disableAnimations) {
            return child;
          }
          final CurvedAnimation curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
  );
}

/// 404 page served via go_router errorBuilder.
final class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '404',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  strings.notFoundTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(strings.notFoundBody),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: () => context.go('/home'),
                  child: Text(strings.backHome),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
