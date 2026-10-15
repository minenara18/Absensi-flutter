import 'package:absensi_dashboard/core/clock.dart';
import 'package:absensi_dashboard/core/result.dart';
import 'package:absensi_dashboard/data/models.dart';
import 'package:absensi_dashboard/data/repositories.dart';
import 'package:absensi_dashboard/features/settings/presentation/settings_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

/// Which part of the day it is (view maps to a localized greeting).
enum DayPart { morning, afternoon, evening, night }

/// Chart range filter.
enum ChartRange { week, month }

/// One recent check-in/out row with the display name resolved.
@immutable
final class RecentActivity {
  const RecentActivity({
    required this.record,
    required this.employeeName,
    required this.department,
  });

  final AttendanceRecord record;
  final String employeeName;
  final String department;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentActivity &&
          other.record == record &&
          other.employeeName == employeeName &&
          other.department == department);

  @override
  int get hashCode => Object.hash(record, employeeName, department);
}

/// Immutable dashboard view-state. Totals/percentages are derived,
/// never stored separately.
@immutable
final class DashboardData {
  const DashboardData({
    required this.dayPart,
    required this.dateLabel,
    required this.timeLabel,
    required this.adminName,
    required this.summary,
    required this.presentDelta,
    required this.recent,
    required this.chart,
    required this.chartRange,
    required this.pendingCount,
    required this.searchQuery,
  });

  final DayPart dayPart;
  final String dateLabel;
  final String timeLabel;
  final String adminName;
  final DailySummary summary;

  /// Checked-in today (present + late) minus yesterday. Derived, not stored.
  final int presentDelta;
  final List<RecentActivity> recent;
  final List<DailyPoint> chart;
  final ChartRange chartRange;
  final int pendingCount;
  final String searchQuery;

  /// Recent rows filtered by the search box (derived, not stored).
  List<RecentActivity> get visibleRecent {
    final String query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return recent;
    }
    return recent
        .where(
          (RecentActivity a) =>
              a.employeeName.toLowerCase().contains(query) ||
              a.department.toLowerCase().contains(query),
        )
        .toList();
  }

  DashboardData copyWith({
    ChartRange? chartRange,
    List<DailyPoint>? chart,
    String? searchQuery,
  }) {
    return DashboardData(
      dayPart: dayPart,
      dateLabel: dateLabel,
      timeLabel: timeLabel,
      adminName: adminName,
      summary: summary,
      presentDelta: presentDelta,
      recent: recent,
      chart: chart ?? this.chart,
      chartRange: chartRange ?? this.chartRange,
      pendingCount: pendingCount,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DashboardData &&
          other.dayPart == dayPart &&
          other.dateLabel == dateLabel &&
          other.timeLabel == timeLabel &&
          other.adminName == adminName &&
          other.summary == summary &&
          other.presentDelta == presentDelta &&
          other.recent == recent &&
          other.chart == chart &&
          other.chartRange == chartRange &&
          other.pendingCount == pendingCount &&
          other.searchQuery == searchQuery);

  @override
  int get hashCode => Object.hash(
    dayPart,
    dateLabel,
    timeLabel,
    adminName,
    summary,
    presentDelta,
    recent,
    chart,
    chartRange,
    pendingCount,
    searchQuery,
  );
}

final class DashboardNotifier extends AsyncNotifier<DashboardData> {
  @override
  Future<DashboardData> build() async {
    ref
      ..watch(clockProvider)
      ..watch(settingsProvider)
      ..watch(authProvider)
      ..watch(attendanceRepositoryProvider)
      ..watch(employeeRepositoryProvider)
      ..watch(leaveRepositoryProvider);
    return _load(ChartRange.week, '');
  }

  Future<DashboardData> _load(ChartRange range, String query) async {
    final DateTime now = ref.read(clockProvider).now();
    final String locale = ref.read(settingsProvider).locale.languageCode;
    final String adminName = ref.read(authProvider).name;

    final AttendanceRepository attendance = ref.read(
      attendanceRepositoryProvider,
    );
    final EmployeeRepository employees = ref.read(employeeRepositoryProvider);
    final LeaveRepository leaves = ref.read(leaveRepositoryProvider);

    final Result<DailySummary> summaryRes = await attendance.summaryFor(now);
    final DateTime yesterday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 1));
    final Result<DailySummary> yesterdayRes = await attendance.summaryFor(
      yesterday,
    );
    final Result<List<AttendanceRecord>> todayRes = await attendance.recordsFor(
      now,
    );
    final Result<List<Employee>> staffRes = await employees.all();
    final Result<List<DailyPoint>> chartRes = await attendance.lastDays(
      now,
      range == ChartRange.week ? 7 : 30,
    );
    final Result<List<LeaveRequest>> leaveRes = await leaves.all();

    final List<Employee> staff = switch (staffRes) {
      Ok(:final List<Employee> value) => value,
      Err() => <Employee>[],
    };
    final Map<String, Employee> byId = <String, Employee>{
      for (final Employee e in staff) e.id: e,
    };

    final List<RecentActivity> recent =
        switch (todayRes) {
              Ok(:final List<AttendanceRecord> value) =>
                value
                    .where(
                      (AttendanceRecord r) =>
                          r.checkIn != null &&
                          (byId[r.employeeId]?.active ?? false),
                    )
                    .toList()
                  ..sort(
                    (AttendanceRecord a, AttendanceRecord b) =>
                        (b.checkIn?.millisecondsSinceEpoch ?? 0).compareTo(
                          a.checkIn?.millisecondsSinceEpoch ?? 0,
                        ),
                  ),
              Err() => <AttendanceRecord>[],
            }
            .take(8)
            .map(
              (AttendanceRecord r) => RecentActivity(
                record: r,
                employeeName: byId[r.employeeId]?.name ?? r.employeeId,
                department: byId[r.employeeId]?.department ?? '',
              ),
            )
            .toList();

    final DailySummary summary = switch (summaryRes) {
      Ok(:final DailySummary value) => value,
      Err() => const DailySummary(
        total: 0,
        present: 0,
        late: 0,
        leave: 0,
        absent: 0,
      ),
    };
    final List<DailyPoint> chart = switch (chartRes) {
      Ok(:final List<DailyPoint> value) => value,
      Err() => <DailyPoint>[],
    };
    final int pending = switch (leaveRes) {
      Ok(:final List<LeaveRequest> value) =>
        value.where((LeaveRequest r) => r.status == LeaveStatus.pending).length,
      Err() => 0,
    };
    final DailySummary yesterdaySummary = switch (yesterdayRes) {
      Ok(:final DailySummary value) => value,
      Err() => const DailySummary(
        total: 0,
        present: 0,
        late: 0,
        leave: 0,
        absent: 0,
      ),
    };
    final int presentDelta =
        (summary.present + summary.late) -
        (yesterdaySummary.present + yesterdaySummary.late);

    final int hour = now.hour;
    final DayPart part = hour < 11
        ? DayPart.morning
        : hour < 15
        ? DayPart.afternoon
        : hour < 18
        ? DayPart.evening
        : DayPart.night;

    return DashboardData(
      dayPart: part,
      dateLabel: DateFormat.yMMMMEEEEd(locale).format(now),
      timeLabel: DateFormat.Hm(locale).format(now),
      adminName: adminName,
      summary: summary,
      presentDelta: presentDelta,
      recent: recent,
      chart: chart,
      chartRange: range,
      pendingCount: pending,
      searchQuery: query,
    );
  }

  /// Pull-to-refresh keeps old content: re-fetch without emitting loading.
  Future<void> refresh() async {
    final DashboardData? current = state.value;
    final DashboardData fresh = await _load(
      current?.chartRange ?? ChartRange.week,
      current?.searchQuery ?? '',
    );
    state = AsyncData<DashboardData>(fresh);
  }

  Future<void> setRange(ChartRange range) async {
    final DashboardData? current = state.value;
    if (current == null || current.chartRange == range) {
      return;
    }
    state = AsyncData<DashboardData>(current.copyWith(chartRange: range));
    final Result<List<DailyPoint>> res = await ref
        .read(attendanceRepositoryProvider)
        .lastDays(
          ref.read(clockProvider).now(),
          range == ChartRange.week ? 7 : 30,
        );
    final DashboardData? latest = state.value;
    if (latest == null) {
      return;
    }
    switch (res) {
      case Ok(:final List<DailyPoint> value):
        state = AsyncData<DashboardData>(latest.copyWith(chart: value));
      case Err():
        break;
    }
  }

  void setQuery(String query) {
    final DashboardData? current = state.value;
    if (current == null) {
      return;
    }
    state = AsyncData<DashboardData>(current.copyWith(searchQuery: query));
  }
}

final AsyncNotifierProvider<DashboardNotifier, DashboardData>
dashboardProvider = AsyncNotifierProvider<DashboardNotifier, DashboardData>(
  DashboardNotifier.new,
);
