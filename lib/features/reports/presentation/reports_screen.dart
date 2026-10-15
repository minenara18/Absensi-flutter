import 'package:absensi_dashboard/core/clock.dart';
import 'package:absensi_dashboard/core/result.dart';
import 'package:absensi_dashboard/data/models.dart';
import 'package:absensi_dashboard/data/repositories.dart';
import 'package:absensi_dashboard/features/settings/presentation/settings_notifier.dart';
import 'package:absensi_dashboard/l10n/gen/app_localizations.dart';
import 'package:absensi_dashboard/shared/widgets/state_views.dart';
import 'package:absensi_dashboard/theme/tokens.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Export lifecycle for the dummy export buttons.
enum ExportState { idle, preparing, ready }

/// Monthly report view-state (immutable).
final class ReportsData {
  const ReportsData({
    required this.month,
    required this.monthLabel,
    required this.summary,
    required this.daily,
    required this.exportState,
  });

  final DateTime month;
  final String monthLabel;
  final DailySummary summary;
  final List<DailyPoint> daily;
  final ExportState exportState;

  ReportsData copyWith({ExportState? exportState}) {
    return ReportsData(
      month: month,
      monthLabel: monthLabel,
      summary: summary,
      daily: daily,
      exportState: exportState ?? this.exportState,
    );
  }
}

final class ReportsNotifier extends AsyncNotifier<ReportsData> {
  @override
  Future<ReportsData> build() async {
    final DateTime now = ref.watch(clockProvider).now();
    return _load(DateTime(now.year, now.month));
  }

  Future<ReportsData> _load(DateTime month) async {
    final String locale = ref.read(settingsProvider).locale.languageCode;
    final AttendanceRepository attendance = ref.read(
      attendanceRepositoryProvider,
    );
    final DateTime now = ref.read(clockProvider).now();

    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    int present = 0;
    int late = 0;
    int leave = 0;
    int absent = 0;
    final List<DailyPoint> daily = <DailyPoint>[];
    final bool isCurrentMonth =
        month.year == now.year && month.month == now.month;
    final int upto = isCurrentMonth ? now.day : daysInMonth;

    for (int day = 1; day <= daysInMonth; day++) {
      final DateTime date = DateTime(month.year, month.month, day);
      if (day <= upto) {
        final Result<DailySummary> res = await attendance.summaryFor(date);
        final DailySummary s = switch (res) {
          Ok(:final DailySummary value) => value,
          Err() => const DailySummary(
            total: 0,
            present: 0,
            late: 0,
            leave: 0,
            absent: 0,
          ),
        };
        present += s.present;
        late += s.late;
        leave += s.leave;
        absent += s.absent;
        daily.add(DailyPoint(date, s.present, s.late));
      } else {
        daily.add(DailyPoint(date, 0, 0));
      }
    }

    final int total = present + late + leave + absent;
    return ReportsData(
      month: month,
      monthLabel: DateFormat.yMMMM(locale).format(month),
      summary: DailySummary(
        total: total,
        present: present,
        late: late,
        leave: leave,
        absent: absent,
      ),
      daily: daily,
      exportState: ExportState.idle,
    );
  }

  Future<void> previousMonth() async {
    final ReportsData? current = state.value;
    if (current == null) {
      return;
    }
    final DateTime prev = DateTime(current.month.year, current.month.month - 1);
    state = const AsyncLoading<ReportsData>();
    state = AsyncData<ReportsData>(await _load(prev));
  }

  Future<void> nextMonth() async {
    final ReportsData? current = state.value;
    if (current == null) {
      return;
    }
    final DateTime now = ref.read(clockProvider).now();
    final DateTime next = DateTime(current.month.year, current.month.month + 1);
    if (next.isAfter(DateTime(now.year, now.month))) {
      return;
    }
    state = const AsyncLoading<ReportsData>();
    state = AsyncData<ReportsData>(await _load(next));
  }

  Future<void> refresh() async {
    final ReportsData? current = state.value;
    if (current == null) {
      return;
    }
    state = AsyncData<ReportsData>(await _load(current.month));
  }

  /// Simulated export: preparing -> ready after a short delay.
  Future<void> export() async {
    final ReportsData? current = state.value;
    if (current == null || current.exportState == ExportState.preparing) {
      return;
    }
    state = AsyncData<ReportsData>(
      current.copyWith(exportState: ExportState.preparing),
    );
    await Future<void>.delayed(const Duration(seconds: 2));
    final ReportsData? latest = state.value;
    if (latest != null) {
      state = AsyncData<ReportsData>(
        latest.copyWith(exportState: ExportState.ready),
      );
    }
  }

  void dismissExport() {
    final ReportsData? current = state.value;
    if (current != null) {
      state = AsyncData<ReportsData>(
        current.copyWith(exportState: ExportState.idle),
      );
    }
  }
}

final AsyncNotifierProvider<ReportsNotifier, ReportsData> reportsProvider =
    AsyncNotifierProvider<ReportsNotifier, ReportsData>(ReportsNotifier.new);

/// Monthly summary + chart + dummy export. Watches one notifier.
final class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final AsyncValue<ReportsData> state = ref.watch(reportsProvider);

    ref.listen<AsyncValue<ReportsData>>(
      reportsProvider,
      (AsyncValue<ReportsData>? previous, AsyncValue<ReportsData> next) {
        final ExportState? prevState = previous?.value?.exportState;
        final ExportState? currState = next.value?.exportState;
        if (currState != null &&
            currState != prevState &&
            currState != ExportState.idle &&
            context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                currState == ExportState.preparing
                    ? strings.exportPreparing
                    : strings.exportReady,
              ),
            ),
          );
        }
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text(strings.reportsTitle)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(reportsProvider.notifier).refresh(),
          child: switch (state) {
            AsyncLoading<ReportsData>() => const SingleChildScrollView(
              padding: EdgeInsetsDirectional.all(AppSpacing.md),
              child: LoadingList(),
            ),
            AsyncError<ReportsData>() => ErrorView(
              title: strings.errorTitle,
              message: strings.errorUnknown,
              retryLabel: strings.retry,
              onRetry: () => ref.invalidate(reportsProvider),
            ),
            AsyncData<ReportsData>(:final ReportsData value) => _ReportsContent(
              data: value,
            ),
          },
        ),
      ),
    );
  }
}

final class _ReportsContent extends ConsumerWidget {
  const _ReportsContent({required this.data});

  final ReportsData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final ReportsNotifier notifier = ref.read(reportsProvider.notifier);
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  tooltip: MaterialLocalizations.of(
                    context,
                  ).previousMonthTooltip,
                  onPressed: notifier.previousMonth,
                ),
                Expanded(
                  child: Text(
                    '${strings.monthlySummary}\n${data.monthLabel}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  tooltip: MaterialLocalizations.of(context).nextMonthTooltip,
                  onPressed: notifier.nextMonth,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            child: Column(
              children: <Widget>[
                _SummaryRow(
                  label: strings.statPresent,
                  value: data.summary.present,
                  color: scheme.primary,
                  total: data.summary.total,
                ),
                _SummaryRow(
                  label: strings.statLate,
                  value: data.summary.late,
                  color: AppTokens.of(context).warning,
                  total: data.summary.total,
                ),
                _SummaryRow(
                  label: strings.statLeave,
                  value: data.summary.leave,
                  color: AppTokens.of(context).leave,
                  total: data.summary.total,
                ),
                _SummaryRow(
                  label: strings.statAbsent,
                  value: data.summary.absent,
                  color: AppTokens.of(context).danger,
                  total: data.summary.total,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            child: SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(
                    topTitles: AxisTitles(),
                    rightTitles: AxisTitles(),
                    leftTitles: AxisTitles(),
                    bottomTitles: AxisTitles(),
                  ),
                  lineBarsData: <LineChartBarData>[
                    LineChartBarData(
                      spots: <FlSpot>[
                        for (int i = 0; i < data.daily.length; i++)
                          FlSpot(
                            i.toDouble(),
                            (data.daily[i].present + data.daily[i].late)
                                .toDouble(),
                          ),
                      ],
                      isCurved: true,
                      color: scheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: scheme.primary.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: <Widget>[
            Expanded(
              child: FilledButton.icon(
                onPressed: data.exportState == ExportState.preparing
                    ? null
                    : notifier.export,
                icon: data.exportState == ExportState.preparing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const ExcludeSemantics(
                        child: Icon(Icons.picture_as_pdf_rounded),
                      ),
                label: Text(
                  data.exportState == ExportState.preparing
                      ? strings.exportPreparing
                      : strings.exportPdf,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: data.exportState == ExportState.preparing
                    ? null
                    : notifier.export,
                icon: const ExcludeSemantics(
                  child: Icon(Icons.table_chart_rounded),
                ),
                label: Text(strings.exportExcel),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

final class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
    required this.total,
  });

  final String label;
  final int value;
  final Color color;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          ExcludeSemantics(
            child: Icon(Icons.circle, size: 12, color: color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label)),
          Text(
            '$value',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}
