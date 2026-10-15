import 'package:absensi_dashboard/core/clock.dart';
import 'package:absensi_dashboard/core/extensions.dart';
import 'package:absensi_dashboard/core/result.dart';
import 'package:absensi_dashboard/data/models.dart';
import 'package:absensi_dashboard/data/repositories.dart';
import 'package:absensi_dashboard/features/settings/presentation/settings_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

/// Filter chips for the attendance list.
enum AttendanceFilter { all, present, late, leave, alpha }

/// One row with display fields pre-formatted by the notifier.
@immutable
final class AttendanceRow {
  const AttendanceRow({
    required this.record,
    required this.employeeName,
    required this.department,
    required this.checkInLabel,
    required this.checkOutLabel,
    required this.durationLabel,
    required this.modeLabel,
  });

  final AttendanceRecord record;
  final String employeeName;
  final String department;
  final String checkInLabel;
  final String checkOutLabel;
  final String durationLabel;
  final String modeLabel;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceRow &&
          other.record == record &&
          other.employeeName == employeeName &&
          other.department == department &&
          other.checkInLabel == checkInLabel &&
          other.checkOutLabel == checkOutLabel &&
          other.durationLabel == durationLabel &&
          other.modeLabel == modeLabel);

  @override
  int get hashCode => Object.hash(
    record,
    employeeName,
    department,
    checkInLabel,
    checkOutLabel,
    durationLabel,
    modeLabel,
  );
}

/// Immutable list state: filters are inputs, rows are derived.
@immutable
final class AttendanceState {
  const AttendanceState({
    required this.day,
    required this.dayLabel,
    required this.stripDays,
    required this.rows,
    required this.departments,
    this.filter = AttendanceFilter.all,
    this.query = '',
    this.department,
    this.failure,
  });

  final DateTime day;
  final String dayLabel;

  /// Seven day strip centered on [day] (derived, not stored separately
  /// from the selection).
  final List<DateTime> stripDays;
  final List<AttendanceRow> rows;
  final List<String> departments;
  final AttendanceFilter filter;
  final String query;
  final String? department;
  final Failure? failure;

  /// Rows after applying status filter + search + department (derived).
  List<AttendanceRow> get visible {
    final String q = query.trim().toLowerCase();
    return rows.where((AttendanceRow row) {
      switch (filter) {
        case AttendanceFilter.all:
          break;
        case AttendanceFilter.present:
          if (row.record.status != AttendanceStatus.present) {
            return false;
          }
        case AttendanceFilter.late:
          if (row.record.status != AttendanceStatus.late) {
            return false;
          }
        case AttendanceFilter.leave:
          if (row.record.status != AttendanceStatus.leave) {
            return false;
          }
        case AttendanceFilter.alpha:
          if (row.record.status != AttendanceStatus.alpha) {
            return false;
          }
      }
      if (department != null && row.department != department) {
        return false;
      }
      if (q.isNotEmpty &&
          !row.employeeName.toLowerCase().contains(q) &&
          !row.department.toLowerCase().contains(q)) {
        return false;
      }
      return true;
    }).toList();
  }

  AttendanceState copyWith({
    DateTime? day,
    String? dayLabel,
    List<AttendanceRow>? rows,
    List<String>? departments,
    AttendanceFilter? filter,
    String? query,
    String? department,
    bool clearDepartment = false,
    Failure? failure,
  }) {
    return AttendanceState(
      day: day ?? this.day,
      dayLabel: dayLabel ?? this.dayLabel,
      stripDays: stripDays,
      rows: rows ?? this.rows,
      departments: departments ?? this.departments,
      filter: filter ?? this.filter,
      query: query ?? this.query,
      department: clearDepartment ? null : (department ?? this.department),
      failure: failure,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceState &&
          other.day == day &&
          other.dayLabel == dayLabel &&
          other.stripDays == stripDays &&
          other.rows == rows &&
          other.departments == departments &&
          other.filter == filter &&
          other.query == query &&
          other.department == department &&
          other.failure == failure);

  @override
  int get hashCode => Object.hash(
    day,
    dayLabel,
    stripDays,
    rows,
    departments,
    filter,
    query,
    department,
    failure,
  );
}

final class AttendanceNotifier extends AsyncNotifier<AttendanceState> {
  @override
  Future<AttendanceState> build() async {
    final DateTime now = ref.watch(clockProvider).now();
    ref.watch(settingsProvider);
    final DateTime today = DateTime(now.year, now.month, now.day);
    return _load(today);
  }

  Future<AttendanceState> _load(DateTime day) async {
    final String locale = ref.read(settingsProvider).locale.languageCode;
    final List<DateTime> strip = <DateTime>[
      for (int i = -3; i <= 3; i++) DateTime(day.year, day.month, day.day + i),
    ];
    final AttendanceRepository attendance = ref.read(
      attendanceRepositoryProvider,
    );
    final EmployeeRepository employees = ref.read(employeeRepositoryProvider);

    final Result<List<AttendanceRecord>> recordsRes = await attendance
        .recordsFor(day);
    final Result<List<Employee>> staffRes = await employees.all();

    switch (recordsRes) {
      case Err(:final Failure failure):
        final AttendanceState? current = state.value;
        final AttendanceState base =
            current ??
            AttendanceState(
              day: day,
              dayLabel: DateFormat.yMMMMEEEEd(locale).format(day),
              stripDays: strip,
              rows: const <AttendanceRow>[],
              departments: const <String>[],
              failure: failure,
            );
        state = AsyncData<AttendanceState>(base.copyWith(failure: failure));
        return base.copyWith(failure: failure);
      case Ok():
        break;
    }
    // Promoted to Ok by the switch above.
    final List<AttendanceRecord> records = recordsRes.value;
    final Map<String, Employee> byId = switch (staffRes) {
      Ok(:final List<Employee> value) => <String, Employee>{
        for (final Employee e in value) e.id: e,
      },
      Err() => <String, Employee>{},
    };

    final bool indonesian = locale == 'id';
    final List<AttendanceRow> rows =
        records.map((AttendanceRecord r) {
          final Employee? emp = byId[r.employeeId];
          final DateTime? checkIn = r.checkIn;
          final DateTime? checkOut = r.checkOut;
          return AttendanceRow(
            record: r,
            employeeName: emp?.name ?? r.employeeId,
            department: emp?.department ?? '—',
            checkInLabel: checkIn == null
                ? '—'
                : DateFormat.Hm(locale).format(checkIn),
            checkOutLabel: checkOut == null
                ? '—'
                : DateFormat.Hm(locale).format(checkOut),
            durationLabel: AttendanceMath.formatDuration(
              r.workDuration,
              indonesian: indonesian,
            ),
            modeLabel: r.mode == WorkMode.office
                ? (indonesian ? 'Kantor' : 'Office')
                : 'WFH',
          );
        }).toList()..sort(
          (AttendanceRow a, AttendanceRow b) =>
              a.employeeName.compareTo(b.employeeName),
        );

    final List<String> departments =
        byId.values.map((Employee e) => e.department).toSet().toList()..sort();

    final AttendanceState? current = state.value;
    return AttendanceState(
      day: day,
      dayLabel: DateFormat.yMMMMEEEEd(locale).format(day),
      stripDays: strip,
      rows: rows,
      departments: departments,
      filter: current?.filter ?? AttendanceFilter.all,
      query: current?.query ?? '',
      department: current?.department,
    );
  }

  Future<void> selectDay(DateTime day) async {
    final DateTime normalized = DateTime(day.year, day.month, day.day);
    state = const AsyncLoading<AttendanceState>();
    state = AsyncData<AttendanceState>(await _load(normalized));
  }

  Future<void> refresh() async {
    final AttendanceState? current = state.value;
    if (current == null) {
      final DateTime now = ref.read(clockProvider).now();
      state = AsyncData<AttendanceState>(
        await _load(DateTime(now.year, now.month, now.day)),
      );
      return;
    }
    final AttendanceState fresh = await _load(current.day);
    state = AsyncData<AttendanceState>(
      fresh.copyWith(
        filter: current.filter,
        query: current.query,
        department: current.department,
      ),
    );
  }

  void setFilter(AttendanceFilter filter) {
    final AttendanceState? current = state.value;
    if (current != null) {
      state = AsyncData<AttendanceState>(current.copyWith(filter: filter));
    }
  }

  void setQuery(String query) {
    final AttendanceState? current = state.value;
    if (current != null) {
      state = AsyncData<AttendanceState>(current.copyWith(query: query));
    }
  }

  void setDepartment(String? department) {
    final AttendanceState? current = state.value;
    if (current != null) {
      if (department == null) {
        state = AsyncData<AttendanceState>(
          current.copyWith(clearDepartment: true),
        );
      } else {
        state = AsyncData<AttendanceState>(
          current.copyWith(department: department),
        );
      }
    }
  }

  void resetFilters() {
    final AttendanceState? current = state.value;
    if (current != null) {
      state = AsyncData<AttendanceState>(
        current.copyWith(
          filter: AttendanceFilter.all,
          query: '',
          clearDepartment: true,
        ),
      );
    }
  }
}

final AsyncNotifierProvider<AttendanceNotifier, AttendanceState>
attendanceProvider = AsyncNotifierProvider<AttendanceNotifier, AttendanceState>(
  AttendanceNotifier.new,
);
