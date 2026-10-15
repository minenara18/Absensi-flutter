import 'package:absensi_dashboard/features/dashboard/presentation/dashboard_notifier.dart';
import 'package:absensi_dashboard/features/dashboard/presentation/widgets/dashboard_widgets.dart';
import 'package:absensi_dashboard/features/dashboard/presentation/widgets/quick_access.dart';
import 'package:absensi_dashboard/l10n/gen/app_localizations.dart';
import 'package:absensi_dashboard/shared/widgets/chips.dart';
import 'package:absensi_dashboard/shared/widgets/state_views.dart';
import 'package:absensi_dashboard/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Home dashboard: greeting header, search, quick access, summary,
/// chart, recent activity and promo banners. Watches one notifier.
final class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DashboardData> state = ref.watch(dashboardProvider);
    final AppLocalizations strings = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
          child: _DashboardBody(state: state, strings: strings),
        ),
      ),
    );
  }
}

final class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.state, required this.strings});

  final AsyncValue<DashboardData> state;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (state) {
      case AsyncLoading<DashboardData>(:final bool hasValue):
        final DashboardData? previous = state.value;
        if (hasValue && previous != null) {
          return _Content(data: previous);
        }
        return const SingleChildScrollView(
          padding: EdgeInsetsDirectional.all(AppSpacing.md),
          child: DashboardSkeleton(),
        );
      case AsyncError<DashboardData>():
        return ErrorView(
          title: strings.errorTitle,
          message: strings.errorUnknown,
          retryLabel: strings.retry,
          onRetry: () => ref.invalidate(dashboardProvider),
        );
      case AsyncData<DashboardData>(:final DashboardData value):
        return _Content(data: value);
    }
  }
}

final class _Content extends StatelessWidget {
  const _Content({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      children: <Widget>[
        _Header(data: data),
        const SizedBox(height: AppSpacing.md),
        const _SearchBar(),
        const SizedBox(height: AppSpacing.md),
        QuickAccessSection(pendingCount: data.pendingCount),
        const SizedBox(height: AppSpacing.md),
        Text(
          AppLocalizations.of(context).summaryToday,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        SummaryCards(summary: data.summary, presentDelta: data.presentDelta),
        const SizedBox(height: AppSpacing.md),
        AttendanceChartCard(data: data),
        const SizedBox(height: AppSpacing.md),
        RecentActivityCard(items: data.visibleRecent),
        const SizedBox(height: AppSpacing.md),
        PromoBanners(pendingCount: data.pendingCount),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

final class _Header extends ConsumerWidget {
  const _Header({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final String greeting = switch (data.dayPart) {
      DayPart.morning => strings.greetingMorning,
      DayPart.afternoon => strings.greetingAfternoon,
      DayPart.evening => strings.greetingEvening,
      DayPart.night => strings.greetingNight,
    };
    return Row(
      children: <Widget>[
        InitialAvatar(name: data.adminName, size: 52),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '$greeting, ${data.adminName.split(' ').first}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                data.dateLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Semantics(
          button: true,
          label: strings.notifications,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.notifications_rounded),
                onPressed: () => context.push('/leave'),
              ),
              if (data.pendingCount > 0)
                PositionedDirectional(
                  end: 6,
                  top: 6,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.xxs,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE02424),
                      shape: BoxShape.circle,
                    ),
                    alignment: AlignmentDirectional.center,
                    child: Text(
                      '${data.pendingCount}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFFFFFFFF),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

final class _SearchBar extends ConsumerWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context);
    return Semantics(
      label: strings.searchHint,
      textField: true,
      child: TextField(
        decoration: InputDecoration(
          hintText: strings.searchHint,
          prefixIcon: const Icon(Icons.search_rounded),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
            borderSide: BorderSide.none,
          ),
        ),
        textInputAction: TextInputAction.search,
        onChanged: (String value) =>
            ref.read(dashboardProvider.notifier).setQuery(value),
        onSubmitted: (_) => context.go('/employees'),
      ),
    );
  }
}
