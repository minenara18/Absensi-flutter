import 'package:absensi_dashboard/data/repositories.dart';
import 'package:meta/meta.dart';

/// Pure helpers for attendance charts. No BuildContext.
@immutable
final class ChartPoint {
  const ChartPoint({
    required this.day,
    required this.attendance,
    this.total = 40,
  });

  final DateTime day;

  /// `null` means a gap (future day or non-working day).
  final double? attendance;

  final int total;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChartPoint &&
          other.day == day &&
          other.attendance == attendance &&
          other.total == total);

  @override
  int get hashCode => Object.hash(day, attendance, total);
}

@immutable
final class ChartSummary {
  const ChartSummary({
    required this.average,
    required this.highestDay,
    required this.highestValue,
    required this.lowestDay,
    required this.lowestValue,
  });

  final double average;
  final DateTime? highestDay;
  final double highestValue;
  final DateTime? lowestDay;
  final double lowestValue;
}

abstract final class ChartMath {
  static bool isWorkingDay(DateTime day) =>
      day.weekday != DateTime.saturday && day.weekday != DateTime.sunday;

  static List<ChartPoint> attendancePoints(
    List<DailyPoint> points,
    DateTime today,
  ) {
    final DateTime cutoff = DateTime(today.year, today.month, today.day);
    final List<ChartPoint> result = <ChartPoint>[];
    for (final DailyPoint point in points) {
      final DateTime day = DateTime(
        point.day.year,
        point.day.month,
        point.day.day,
      );
      if (day.isAfter(cutoff)) {
        result.add(ChartPoint(day: day, attendance: null));
      } else if (!isWorkingDay(day)) {
        result.add(ChartPoint(day: day, attendance: null));
      } else {
        result.add(
          ChartPoint(
            day: day,
            attendance: (point.present + point.late).toDouble(),
          ),
        );
      }
    }
    return result;
  }

  static ChartSummary summary(List<ChartPoint> points) {
    final List<ChartPoint> valid = points
        .where((ChartPoint p) => p.attendance != null)
        .toList();
    if (valid.isEmpty) {
      return const ChartSummary(
        average: 0,
        highestDay: null,
        highestValue: 0,
        lowestDay: null,
        lowestValue: 0,
      );
    }
    final double total = valid.fold<double>(
      0,
      (double a, ChartPoint p) => a + (p.attendance ?? 0),
    );
    final double average = total / valid.length;
    ChartPoint highest = valid.first;
    ChartPoint lowest = valid.first;
    for (final ChartPoint point in valid) {
      if ((point.attendance ?? 0) > (highest.attendance ?? 0)) {
        highest = point;
      }
      if ((point.attendance ?? 0) < (lowest.attendance ?? 0)) {
        lowest = point;
      }
    }
    return ChartSummary(
      average: average,
      highestDay: highest.day,
      highestValue: highest.attendance ?? 0,
      lowestDay: lowest.day,
      lowestValue: lowest.attendance ?? 0,
    );
  }

  static double roundUpMax(double value, {int step = 10}) {
    if (value <= 0) {
      return step.toDouble();
    }
    final double base = (value / step).ceil() * step.toDouble();
    return base + (base * 0.1);
  }

  static List<int> monthXLabels(int lastDay) {
    final Set<int> labels = <int>{1, 5, 10, 15, 20, 25, lastDay};
    final List<int> result =
        labels.where((int i) => i >= 1 && i <= lastDay).toList()..sort();
    return result;
  }
}
