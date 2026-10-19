import 'package:absensi_dashboard/data/models.dart';
import 'package:absensi_dashboard/data/repositories.dart';
import 'package:absensi_dashboard/features/dashboard/presentation/dashboard_notifier.dart';
import 'package:absensi_dashboard/l10n/gen/app_localizations.dart';
import 'package:absensi_dashboard/shared/widgets/attendance_line_chart.dart';
import 'package:absensi_dashboard/shared/widgets/chips.dart';
import 'package:absensi_dashboard/shared/widgets/state_views.dart';
import 'package:absensi_dashboard/theme/tokens.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

final class SummaryCardsRow extends StatelessWidget {
  const SummaryCardsRow({
    super.key,
    required this.summary,
    required this.presentDelta,
  });

  final DailySummary summary;
  final int presentDelta;

  @override
  Widget build(BuildContext context) {
    final bool vertical =
        MediaQuery.sizeOf(context).width < 340 ||
        MediaQuery.textScalerOf(context).scale(1) >= 1.5;
    final Widget total = TotalEmployeeCard(
      summary: summary,
      presentDelta: presentDelta,
    );
    final Widget breakdown = AttendanceBreakdownCard(summary: summary);
    if (vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          total,
          const SizedBox(height: AppSpacing.sm),
          breakdown,
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(child: total),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: breakdown),
        ],
      ),
    );
  }
}

/// Alias for previous name.
typedef SummaryCards = SummaryCardsRow;

final class TotalEmployeeCard extends StatelessWidget {
  const TotalEmployeeCard({
    super.key,
    required this.summary,
    required this.presentDelta,
  });

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
    return Card(
      color: scheme.primary,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.group_rounded,
              color: scheme.onPrimary,
              size: 28,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${summary.total}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: scheme.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              strings.statTotal,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${summary.present + summary.late}/${summary.total}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onPrimary.withValues(alpha: 0.92),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Semantics(
              label: trend.label,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ExcludeSemantics(
                    child: Icon(
                      trend.icon,
                      size: 14,
                      color: scheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    '${presentDelta >= 0 ? '+' : ''}$presentDelta '
                    '${trend.label}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class AttendanceBreakdownCard extends StatelessWidget {
  const AttendanceBreakdownCard({super.key, required this.summary});

  final DailySummary summary;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final AppTokens tokens = AppTokens.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _BreakdownRow(
              first: BreakdownCell(
                icon: Icons.check_circle_rounded,
                color: tokens.success,
                label: AppLocalizations.of(context).statPresent,
                value: summary.present,
              ),
              second: BreakdownCell(
                icon: Icons.watch_later_rounded,
                color: tokens.warning,
                label: AppLocalizations.of(context).statLate,
                value: summary.late,
              ),
            ),
            Container(height: 1, color: scheme.outlineVariant),
            _BreakdownRow(
              first: BreakdownCell(
                icon: Icons.event_busy_rounded,
                color: tokens.leave,
                label: AppLocalizations.of(context).statLeave,
                value: summary.leave,
              ),
              second: BreakdownCell(
                icon: Icons.cancel_rounded,
                color: tokens.danger,
                label: AppLocalizations.of(context).statAbsent,
                value: summary.absent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(child: first),
          Container(width: 1, color: scheme.outlineVariant),
          Expanded(child: second),
        ],
      ),
    );
  }
}

final class BreakdownCell extends StatelessWidget {
  const BreakdownCell({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: color, size: 18),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '$value',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

final class AttendanceChartCard extends ConsumerWidget {
  const AttendanceChartCard({super.key, required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String locale = Localizations.localeOf(context).languageCode;
    final List<DailyPoint> points = data.chart;
    final bool isMonth = data.chartRange == ChartRange.month;
    final String title = isMonth
        ? strings.monthlyChartTitle
        : strings.chartWeekTitle;
    final String subtitle = strings.chartSubtitle;
    final double total = data.summary.total <= 0
        ? 40
        : data.summary.total.toDouble();
    final double yInterval = _yInterval(total);
    final int todayIndex = points.isEmpty ? -1 : points.length - 1;
    final ChartStats stats = data.chartStats;
    final String avgText = strings.chartAverage(
      stats.average.toStringAsFixed(1),
    );
    final String peakText = stats.peakDay == null
        ? ''
        : strings.chartPeak(
            DateFormat.E(locale).format(stats.peakDay!),
            '${stats.peakValue}',
          );
    final String lowText = stats.lowDay == null
        ? ''
        : strings.chartLow(
            DateFormat.E(locale).format(stats.lowDay!),
            '${stats.lowValue}',
          );

    final Widget chart = isMonth
        ? AttendanceLineChart(
            points: data.chartPoints,
            stats: data.chartSummary,
            locale: locale,
            lineColor: scheme.primary,
          )
        : _WeekBarChart(
            points: points,
            total: total,
            yInterval: yInterval,
            todayIndex: todayIndex,
          );

    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                _FilterChips(range: data.chartRange, ref: ref),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (isMonth)
              Text(
                DateFormat.yMMMM(
                  locale,
                ).format(points.isEmpty ? DateTime.now() : points.first.day),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Semantics(
              label: '$title. $subtitle. $avgText. $peakText. $lowText',
              child: SizedBox(
                height: 200,
                child: AnimatedSwitcher(
                  duration: AppDurations.of(context, AppDurations.normal),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: KeyedSubtree(
                    key: ValueKey<ChartRange>(data.chartRange),
                    child: chart,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: <Widget>[
                _LegendDot(color: scheme.primary, label: strings.chartLegend),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              peakText.isEmpty ? '' : '$peakText - $lowText - $avgText',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static double _yInterval(double total) {
    if (total <= 8) {
      return 1;
    }
    if (total <= 20) {
      return 2;
    }
    if (total <= 60) {
      return 10;
    }
    return 20;
  }
}

final class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.range, required this.ref});

  final ChartRange range;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Semantics(
          button: true,
          label: strings.filterWeek,
          child: ChoiceChip(
            label: Text(strings.filterWeek),
            selected: range == ChartRange.week,
            onSelected: (_) =>
                ref.read(dashboardProvider.notifier).setRange(ChartRange.week),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Semantics(
          button: true,
          label: strings.filterMonth,
          child: ChoiceChip(
            label: Text(strings.filterMonth),
            selected: range == ChartRange.month,
            onSelected: (_) =>
                ref.read(dashboardProvider.notifier).setRange(ChartRange.month),
          ),
        ),
      ],
    );
  }
}

final class _WeekBarChart extends StatelessWidget {
  const _WeekBarChart({
    required this.points,
    required this.total,
    required this.yInterval,
    required this.todayIndex,
  });

  final List<DailyPoint> points;
  final double total;
  final double yInterval;
  final int todayIndex;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).languageCode;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return BarChart(
      BarChartData(
        maxY: total,
        minY: 0,
        gridData: FlGridData(
          horizontalInterval: yInterval,
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: yInterval,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (double value, TitleMeta meta) {
                final int i = value.toInt();
                if (i < 0 || i >= points.length) {
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
                  toY: (points[i].present + points[i].late).toDouble(),
                  width: 18,
                  color: i == todayIndex
                      ? scheme.primary
                      : scheme.primary.withValues(alpha: 0.45),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.sm),
                  ),
                ),
              ],
            ),
        ],
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem:
                (
                  BarChartGroupData group,
                  int groupIndex,
                  BarChartRodData rod,
                  int rodIndex,
                ) {
                  final int index = group.x;
                  if (index < 0 || index >= points.length) {
                    return null;
                  }
                  final DailyPoint p = points[index];
                  final double pct = total <= 0 ? 0 : rod.toY / total * 100;
                  return BarTooltipItem(
                    '${DateFormat.MMMd(locale).format(p.day)}\n'
                    '${p.present + p.late} (${pct.toStringAsFixed(0)}%)',
                    TextStyle(color: scheme.onPrimary),
                  );
                },
          ),
        ),
      ),
    );
  }
}

final class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
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
                    ? 'â€”'
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
                              '${activity.department} â€¢ $time',
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
