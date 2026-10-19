import 'package:absensi_dashboard/features/settings/presentation/settings_notifier.dart';
import 'package:absensi_dashboard/l10n/gen/app_localizations.dart';
import 'package:absensi_dashboard/shared/widgets/chips.dart';
import 'package:absensi_dashboard/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings: admin profile, theme, language, work hours, about, logout.
final class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final SettingsState settings = ref.watch(settingsProvider);
    final AuthState auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                child: Row(
                  children: <Widget>[
                    InitialAvatar(name: auth.name, size: 56),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            auth.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'admin@absensiku.id',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _GroupLabel(text: strings.profileAdmin),
            const SizedBox(height: AppSpacing.sm),
            _ThemeTile(settings: settings),
            const SizedBox(height: AppSpacing.lg),
            _LanguageTile(settings: settings),
            const SizedBox(height: AppSpacing.lg),
            _GroupLabel(text: strings.workHours),
            Card(
              child: ListTile(
                leading: const ExcludeSemantics(
                  child: Icon(Icons.schedule_rounded),
                ),
                title: Text(strings.workHours),
                subtitle: Text(strings.workHoursValue),
                contentPadding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _GroupLabel(text: strings.aboutApp),
            Card(
              child: ListTile(
                leading: const ExcludeSemantics(
                  child: Icon(Icons.info_rounded),
                ),
                title: Text(strings.aboutApp),
                subtitle: Text(strings.aboutBody),
                contentPadding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Semantics(
              button: true,
              label: strings.logout,
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context, ref),
                  icon: const ExcludeSemantics(
                    child: Icon(Icons.logout_rounded),
                  ),
                  label: Text(strings.logout),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTokens.of(context).danger,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final AppLocalizations strings = AppLocalizations.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(strings.logout),
          content: Text(strings.logoutConfirm),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(strings.logout),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      ref.read(authProvider.notifier).logout();
    }
  }
}

final class _GroupLabel extends StatelessWidget {
  const _GroupLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

final class _ThemeTile extends ConsumerWidget {
  const _ThemeTile({required this.settings});

  final SettingsState settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final String label = switch (settings.themeMode) {
      AppThemeMode.light => strings.themeLight,
      AppThemeMode.dark => strings.themeDark,
      AppThemeMode.system => strings.themeSystem,
    };
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                const ExcludeSemantics(
                  child: Icon(Icons.palette_rounded),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    strings.themeLabel,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Text(label),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              strings.themeDescription,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const SizedBox(height: AppSpacing.xs),
            SegmentedButton<AppThemeMode>(
              segments: <ButtonSegment<AppThemeMode>>[
                ButtonSegment<AppThemeMode>(
                  value: AppThemeMode.light,
                  label: Text(strings.themeLight),
                ),
                ButtonSegment<AppThemeMode>(
                  value: AppThemeMode.dark,
                  label: Text(strings.themeDark),
                ),
                ButtonSegment<AppThemeMode>(
                  value: AppThemeMode.system,
                  label: Text(strings.themeSystem),
                ),
              ],
              selected: <AppThemeMode>{settings.themeMode},
              onSelectionChanged: (Set<AppThemeMode> next) {
                ref.read(settingsProvider.notifier).setThemeMode(next.first);
              },
            ),
          ],
        ),
      ),
    );
  }
}

final class _LanguageTile extends ConsumerWidget {
  const _LanguageTile({required this.settings});

  final SettingsState settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                const ExcludeSemantics(
                  child: Icon(Icons.language_rounded),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    strings.languageLabel,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              strings.languageDescription,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<String>(
              segments: const <ButtonSegment<String>>[
                ButtonSegment<String>(
                  value: 'id',
                  label: Text('Indonesia'),
                ),
                ButtonSegment<String>(
                  value: 'en',
                  label: Text('English'),
                ),
              ],
              selected: <String>{settings.locale.languageCode},
              onSelectionChanged: (Set<String> next) {
                ref
                    .read(settingsProvider.notifier)
                    .setLocale(Locale(next.first));
              },
            ),
          ],
        ),
      ),
    );
  }
}
