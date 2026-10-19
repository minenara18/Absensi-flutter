import 'package:absensi_dashboard/core/chart_math.dart';
import 'package:absensi_dashboard/l10n/gen/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final class AttendanceLineChart extends StatelessWidget {
  const AttendanceLineChart({
    super.key,
    required this.points,
    required this.stats,
    required this.locale,
    required this.lineColor,
  });

  final List<ChartPoint> points;
  final ChartSummary stats;
  final String locale;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    final int lastDay = points.isEmpty
        ? 1
        : points
              .map((ChartPoint p) => p.day.day)
              .reduce(
                (int a, int b) => a > b ? a : b,
              );
    final double maxY = ChartMath.roundUpMax(stats.highestValue);
    const double minY = 0;
    final double interval = maxY <= 20 ? 5 : (maxY / 4).roundToDouble();
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return LineChart(
      LineChartData(
        minX: 1,
        maxX: lastDay.toDouble(),
        minY: minY,
        maxY: maxY,
        clipData: const FlClipData.all(),
        gridData: FlGridData(
          horizontalInterval: interval,
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: interval,
              getTitlesWidget: (double value, TitleMeta meta) =>
                  SideTitleWidget(
                    meta: meta,
                    child: Text(
                      value.toStringAsFixed(0),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                final int day = value.toInt();
                if (!ChartMath.monthXLabels(lastDay).contains(day)) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    '$day',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            spots: <FlSpot>[
              for (final ChartPoint point in points)
                point.attendance == null
                    ? FlSpot.nullSpot
                    : FlSpot(
                        point.day.day.toDouble(),
                        point.attendance!,
                      ),
            ],
            isCurved: true,
            curveSmoothness: 0.18,
            preventCurveOverShooting: true,
            color: lineColor,
            barWidth: 2.5,
            dotData: FlDotData(
              getDotPainter:
                  (
                    FlSpot spot,
                    double xPercentage,
                    LineChartBarData bar,
                    int index,
                  ) => FlDotCirclePainter(
                    radius: 2.5,
                    color: lineColor,
                    strokeWidth: 1,
                    strokeColor: scheme.surface,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: <Color>[
                  lineColor.withValues(alpha: 0.18),
                  lineColor.withValues(alpha: 0.02),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot spot) {
                final int index = spot.x.toInt() - 1;
                if (index < 0 || index >= points.length) {
                  return null;
                }
                final ChartPoint point = points[index];
                if (point.attendance == null) {
                  return null;
                }
                final int value = point.attendance!.round();
                final double percent = point.total <= 0
                    ? 0
                    : (point.attendance! / point.total * 100).clamp(0, 100);
                final AppLocalizations strings = AppLocalizations.of(context);
                return LineTooltipItem(
                  '${DateFormat.MMMd(locale).format(point.day)}: '
                  '$value ${strings.statPresent.toLowerCase()} '
                  '(${percent.toStringAsFixed(0)}%)',
                  TextStyle(color: scheme.onPrimary),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
