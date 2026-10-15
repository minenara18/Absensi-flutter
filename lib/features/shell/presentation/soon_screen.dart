import 'package:absensi_dashboard/l10n/gen/app_localizations.dart';
import 'package:absensi_dashboard/shared/widgets/state_views.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Honest placeholder for shortcuts without a dedicated screen yet
/// (overtime, shifts, office location). Deep-linkable via `/soon/:key`.
final class SoonScreen extends StatelessWidget {
  const SoonScreen({super.key, required this.soonKey});

  final String soonKey;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(_titleFor(soonKey, strings))),
      body: SafeArea(
        child: EmptyView(
          icon: Icons.construction_rounded,
          title: strings.emptyTitle,
          body: strings.emptyBody,
          actionLabel: strings.backHome,
          onAction: () => context.go('/home'),
        ),
      ),
    );
  }

  static String _titleFor(String key, AppLocalizations strings) {
    switch (key) {
      case 'overtime':
        return strings.qaOvertime;
      case 'schedule':
        return strings.qaSchedule;
      case 'location':
        return strings.qaLocation;
      default:
        return strings.appTitle;
    }
  }
}
