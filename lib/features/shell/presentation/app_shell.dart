import 'package:absensi_dashboard/l10n/gen/app_localizations.dart';
import 'package:absensi_dashboard/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Adaptive navigation shell driven by available width:
/// <600 bottom bar, 600-840 rail, >=840 extended rail.
final class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  void _goBranch(int index) {
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final List<({String label, IconData icon, IconData activeIcon})> tabs =
        <({String label, IconData icon, IconData activeIcon})>[
          (
            label: strings.navHome,
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
          ),
          (
            label: strings.navAttendance,
            icon: Icons.fact_check_outlined,
            activeIcon: Icons.fact_check_rounded,
          ),
          (
            label: strings.navEmployees,
            icon: Icons.group_outlined,
            activeIcon: Icons.group_rounded,
          ),
          (
            label: strings.navReports,
            icon: Icons.bar_chart_outlined,
            activeIcon: Icons.bar_chart_rounded,
          ),
          (
            label: strings.navSettings,
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
          ),
        ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        if (width < AppBreakpoints.compactMax) {
          return Scaffold(
            body: SafeArea(top: false, child: shell),
            bottomNavigationBar: NavigationBar(
              selectedIndex: shell.currentIndex,
              onDestinationSelected: _goBranch,
              destinations: <NavigationDestination>[
                for (int i = 0; i < tabs.length; i++)
                  NavigationDestination(
                    icon: Icon(
                      shell.currentIndex == i
                          ? tabs[i].activeIcon
                          : tabs[i].icon,
                    ),
                    selectedIcon: Icon(tabs[i].activeIcon),
                    label: tabs[i].label,
                  ),
              ],
            ),
          );
        }
        final bool extended = width >= AppBreakpoints.mediumMax;
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: <Widget>[
                NavigationRail(
                  selectedIndex: shell.currentIndex,
                  extended: extended,
                  minExtendedWidth: 220,
                  onDestinationSelected: _goBranch,
                  leading: extended
                      ? const Padding(
                          padding: EdgeInsetsDirectional.all(AppSpacing.md),
                          child: AppLogo(),
                        )
                      : const Padding(
                          padding: EdgeInsetsDirectional.all(AppSpacing.xs),
                          child: AppLogoMark(),
                        ),
                  destinations: <NavigationRailDestination>[
                    for (int i = 0; i < tabs.length; i++)
                      NavigationRailDestination(
                        icon: Icon(
                          shell.currentIndex == i
                              ? tabs[i].activeIcon
                              : tabs[i].icon,
                        ),
                        label: Text(tabs[i].label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: shell),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Product wordmark for the extended rail / wide layouts.
final class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AppLogoMark(),
        SizedBox(width: AppSpacing.xs),
        Text(
          'AbsensiKu',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: AppFontSize.titleSmall,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

/// Rounded brand mark.
final class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'AbsensiKu',
      image: true,
      child: Container(
        width: AppTouch.minTarget,
        height: AppTouch.minTarget,
        decoration: const BoxDecoration(
          color: AppPalette.primary,
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
        ),
        alignment: AlignmentDirectional.center,
        child: const ExcludeSemantics(
          child: Icon(
            Icons.fingerprint_rounded,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ),
    );
  }
}
