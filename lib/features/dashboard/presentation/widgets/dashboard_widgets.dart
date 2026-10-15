import 'package:absensi_dashboard/core/extensions.dart';
import 'package:absensi_dashboard/data/models.dart';
import 'package:absensi_dashboard/data/repositories.dart';
import 'package:absensi_dashboard/features/dashboard/presentation/dashboard_notifier.dart';
import 'package:absensi_dashboard/l10n/gen/app_localizations.dart';
import 'package:absensi_dashboard/shared/widgets/chips.dart';
import 'package:absensi_dashboard/shared/widgets/state_views.dart';
import 'package:absensi_dashboard/theme/tokens.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Horizontally scrolling summary cards with counts + percentages.
final class SummaryCards extends StatelessWidget {
  const SummaryCards({
    super.key,
    required this.summary,
    required this.presentDelta,
  });

  final DailySummary summary;
  final int presentDelta;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final List<({String label, int value, Color color, IconData icon})> cards =
        <({String label, int value, Color color, IconData icon})>[
          (
            label: strings.statPresent,
            value: summary.present,
            color: AppTokens.of(context).success,
            icon: Icons.check_circle_rounded,
          ),
          (
            label: strings.statLate,
            value: summary.late,
            color: AppTokens.of(context).warning,
            icon: Icons.watch_later_rounded,
          ),
          (
            label: strings.statLeave,
            value: summary.leave,
            color: AppTokens.of(context).leave,
            icon: Icons.event_busy_rounded,
          ),
          (
            label: strings.statAbsent,
            value: summary.absent,
            color: AppTokens.of(context).danger,
            icon: Icons.cancel_rounded,
          ),
        ];
    return SizedBox(
      height: 132,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _TotalCard(summary: summary, presentDelta: presentDelta);
          }
          final ({String label, int value, Color color, IconData icon}) card =
              cards[index - 1];
          return _StatCard(
            label: card.label,
            value: card.value,
            total: summary.total,
            color: card.color,
            icon: card.icon,
          );
        },
      ),
    );
  }
}

final class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.summary, required this.presentDelta});

  final DailySummary summary;
  final int presentDelta;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final ({IconData icon, String label}) trend = presentDelta > 0
        ? (icon: Icons.trending_up_rounded, label: strings.trendUp)
        : presentDelta < 0
        ? (icon: Icons.trending_down_rounded, label: strings.trendDown)
        : (icon: Icons.trending_flat_rounded, label: strings.trendFlat);
    return Container(
      width: 168,
      margin: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const ExcludeSemantics(
            child: Icon(Icons.group_rounded, color: Color(0xFFFFFFFF)),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${summary.total}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFFFFFFFF),
            ),
          ),
          Text(
            strings.statTotal,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFFFFFFFF),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Semantics(
            label: trend.label,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ExcludeSemantics(
                  child: Icon(
                    trend.icon,
                    size: 16,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
                const SizedBox(width: AppSpacing.xxs),
                Text(
                  '${presentDelta >= 0 ? '+' : ''}$presentDelta ${trend.label}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
    required this.icon,
  });

  final String label;
  final int value;
  final int total;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final double pct = AttendanceMath.percent(value, total);
    return Card(
      child: Container(
        width: 152,
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                ExcludeSemantics(child: Icon(icon, color: color, size: 20)),
                const SizedBox(width: AppSpacing.xxs),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$value',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xxs),
            ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(AppRadius.pill),
              ),
              child: LinearProgressIndicator(
                value: total <= 0 ? 0 : value / total,
                color: color,
                backgroundColor: color.withValues(alpha: 0.15),
                minHeight: 6,
                semanticsLabel: label,
                semanticsValue: '${pct.toStringAsFixed(0)}%',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 7-day / 30-day bar chart with a range filter.
final class AttendanceChartCard extends ConsumerWidget {
  const AttendanceChartCard({super.key, required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String locale = Localizations.localeOf(context).languageCode;

    final List<DailyPoint> points = data.chart;
    final double maxY = points.fold<double>(
      8,
      (double acc, DailyPoint p) =>
          (p.present + p.late) > acc ? (p.present + p.late).toDouble() : acc,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    strings.attendance7d,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Semantics(
                  label: strings.filterWeek,
                  button: true,
                  child: ChoiceChip(
                    label: Text(strings.filterWeek),
                    selected: data.chartRange == ChartRange.week,
                    onSelected: (_) => ref
                        .read(dashboardProvider.notifier)
                        .setRange(ChartRange.week),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Semantics(
                  label: strings.filterMonth,
                  button: true,
                  child: ChoiceChip(
                    label: Text(strings.filterMonth),
                    selected: data.chartRange == ChartRange.month,
                    onSelected: (_) => ref
                        .read(dashboardProvider.notifier)
                        .setRange(ChartRange.month),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final int i = value.toInt();
                          if (i < 0 || i >= points.length) {
                            return const SizedBox.shrink();
                          }
                          if (data.chartRange == ChartRange.month &&
                              i % 5 != 0) {
                            return const SizedBox.shrink();
                          }
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              DateFormat.E(locale).format(points[i].day),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: <BarChartGroupData>[
                    for (int i = 0; i < points.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: <BarChartRodData>[
                          BarChartRodData(
                            toY: points[i].present.toDouble(),
                            color: scheme.primary,
                            width: data.chartRange == ChartRange.week ? 18 : 6,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(AppRadius.sm),
                            ),
                          ),
                          BarChartRodData(
                            toY: points[i].late.toDouble(),
                            color: AppTokens.of(context).warning,
                            width: data.chartRange == ChartRange.week ? 18 : 6,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(AppRadius.sm),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Latest check-ins with status chips.
final class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({super.key, required this.items});

  final List<RecentActivity> items;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final String locale = Localizations.localeOf(context).languageCode;
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Column(
          children: <Widget>[
            SectionHeader(
              title: strings.recentActivity,
              actionLabel: strings.seeAll,
              onAction: () => context.go('/attendance'),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                final RecentActivity activity = items[index];
                final DateTime? checkIn = activity.record.checkIn;
                final String time = checkIn == null
                    ? '—'
                    : DateFormat.Hm(locale).format(checkIn);
                return Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    children: <Widget>[
                      InitialAvatar(name: activity.employeeName, size: 44),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              activity.employeeName,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              '${activity.department} • $time',
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
                      StatusChip(status: activity.record.status),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Small promo/banner cards with an action.
final class PromoBanners extends StatelessWidget {
  const PromoBanners({super.key, required this.pendingCount});

  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Column(
      children: <Widget>[
        if (pendingCount > 0)
          Card(
            color: scheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsetsDirectional.all(AppSpacing.md),
              child: Row(
                children: <Widget>[
                  ExcludeSemantics(
                    child: Icon(
                      Icons.mark_as_unread_rounded,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      strings.pendingBanner(pendingCount),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: () => context.push('/leave'),
                    child: Text(strings.reviewNow),
                  ),
                ],
              ),
            ),
          ),
        if (pendingCount > 0) const SizedBox(height: AppSpacing.sm),
        Card(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            child: Row(
              children: <Widget>[
                ExcludeSemantics(
                  child: Icon(
                    Icons.download_rounded,
                    color: AppTokens.of(context).success,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(strings.promoTitle)),
                const SizedBox(width: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () => context.go('/reports'),
                  child: Text(strings.promoAction),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Skeleton shaped like the dashboard while first loading.
final class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SkeletonBlock(width: double.infinity, height: 64, radius: AppRadius.lg),
        SizedBox(height: AppSpacing.md),
        SkeletonBlock(
          width: double.infinity,
          height: 120,
          radius: AppRadius.lg,
        ),
        SizedBox(height: AppSpacing.md),
        LoadingList(rows: 3),
      ],
    );
  }
}
