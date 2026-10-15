import 'dart:async';
import 'package:absensi_dashboard/core/clock.dart';
import 'package:absensi_dashboard/core/result.dart';
import 'package:absensi_dashboard/data/dummy_data.dart';
import 'package:absensi_dashboard/data/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// ---------------------------------------------------------------------------
/// Repository contracts — only these get interfaces because dummy will be
/// swapped for HTTP implementations later.
/// ---------------------------------------------------------------------------

abstract class AttendanceRepository {
  Future<Result<List<AttendanceRecord>>> recordsFor(DateTime day);
  Future<Result<AttendanceRecord>> recordById(String id);
  Future<Result<DailySummary>> summaryFor(DateTime day);
  Future<Result<List<DailyPoint>>> lastDays(DateTime today, int count);
  Future<Result<List<AttendanceRecord>>> historyOf(
    String employeeId,
    int limit,
  );
}

abstract class EmployeeRepository {
  Future<Result<List<Employee>>> all();
  Future<Result<Employee>> byId(String id);
  Future<Result<Employee>> save(Employee employee);
}

abstract class LeaveRepository {
  Future<Result<List<LeaveRequest>>> all();
  Future<Result<LeaveRequest>> decide(String id, {required bool approve});
}

/// Simple chart point (pure data).
@immutable
final class DailyPoint {
  const DailyPoint(this.day, this.present, this.late);

  final DateTime day;
  final int present;
  final int late;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyPoint &&
          other.day == day &&
          other.present == present &&
          other.late == late);

  @override
  int get hashCode => Object.hash(day, present, late);
}

// ---------------------------------------------------------------------------
// In-memory dummy implementations with a small delay so loading states show.
// ---------------------------------------------------------------------------

final class InMemoryAttendanceRepository implements AttendanceRepository {
  InMemoryAttendanceRepository(this._records, this._total);

  final List<AttendanceRecord> _records;
  final int _total;

  static const Duration delay = Duration(milliseconds: 450);

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Future<Result<List<AttendanceRecord>>> recordsFor(DateTime day) async {
    await Future<void>.delayed(delay);
    final List<AttendanceRecord> rows = _records
        .where((AttendanceRecord r) => _sameDay(r.date, day))
        .toList();
    return Ok<List<AttendanceRecord>>(rows);
  }

  @override
  Future<Result<AttendanceRecord>> recordById(String id) async {
    await Future<void>.delayed(delay);
    for (final AttendanceRecord r in _records) {
      if (r.id == id) {
        return Ok<AttendanceRecord>(r);
      }
    }
    return const Err<AttendanceRecord>(Failure(FailureCode.notFound));
  }

  @override
  Future<Result<DailySummary>> summaryFor(DateTime day) async {
    await Future<void>.delayed(delay);
    final List<AttendanceRecord> rows = _records
        .where((AttendanceRecord r) => _sameDay(r.date, day))
        .toList();
    int present = 0;
    int late = 0;
    int leave = 0;
    for (final AttendanceRecord r in rows) {
      switch (r.status) {
        case AttendanceStatus.present:
          present++;
        case AttendanceStatus.late:
          late++;
        case AttendanceStatus.leave:
          leave++;
        case AttendanceStatus.alpha:
          break;
      }
    }
    final int accounted = present + late + leave;
    return Ok<DailySummary>(
      DailySummary(
        total: _total,
        present: present,
        late: late,
        leave: leave,
        absent: (_total - accounted).clamp(0, _total),
      ),
    );
  }

  @override
  Future<Result<List<DailyPoint>>> lastDays(DateTime today, int count) async {
    await Future<void>.delayed(delay);
    final DateTime base = DateTime(today.year, today.month, today.day);
    final List<DailyPoint> points = <DailyPoint>[];
    for (int i = count - 1; i >= 0; i--) {
      final DateTime day = base.subtract(Duration(days: i));
      final Iterable<AttendanceRecord> rows = _records.where(
        (AttendanceRecord r) => _sameDay(r.date, day),
      );
      int present = 0;
      int late = 0;
      for (final AttendanceRecord r in rows) {
        switch (r.status) {
          case AttendanceStatus.present:
            present++;
          case AttendanceStatus.late:
            late++;
          case AttendanceStatus.leave:
          case AttendanceStatus.alpha:
            break;
        }
      }
      points.add(DailyPoint(day, present, late));
    }
    return Ok<List<DailyPoint>>(points);
  }

  @override
  Future<Result<List<AttendanceRecord>>> historyOf(
    String employeeId,
    int limit,
  ) async {
    await Future<void>.delayed(delay);
    final List<AttendanceRecord> rows =
        _records
            .where((AttendanceRecord r) => r.employeeId == employeeId)
            .toList()
          ..sort(
            (AttendanceRecord a, AttendanceRecord b) =>
                b.date.compareTo(a.date),
          );
    return Ok<List<AttendanceRecord>>(rows.take(limit).toList());
  }
}

final class InMemoryEmployeeRepository implements EmployeeRepository {
  InMemoryEmployeeRepository(List<Employee> seed)
    : _staff = List<Employee>.of(seed);

  final List<Employee> _staff;

  static const Duration delay = Duration(milliseconds: 450);

  @override
  Future<Result<List<Employee>>> all() async {
    await Future<void>.delayed(delay);
    return Ok<List<Employee>>(List<Employee>.unmodifiable(_staff));
  }

  @override
  Future<Result<Employee>> byId(String id) async {
    await Future<void>.delayed(delay);
    for (final Employee e in _staff) {
      if (e.id == id) {
        return Ok<Employee>(e);
      }
    }
    return const Err<Employee>(Failure(FailureCode.notFound));
  }

  @override
  Future<Result<Employee>> save(Employee employee) async {
    await Future<void>.delayed(delay);
    if (employee.name.trim().isEmpty) {
      return const Err<Employee>(
        Failure(FailureCode.validation, 'name-empty'),
      );
    }
    final int index = _staff.indexWhere((Employee e) => e.id == employee.id);
    if (index >= 0) {
      _staff[index] = employee;
    } else {
      _staff.add(employee);
    }
    return Ok<Employee>(employee);
  }
}

final class InMemoryLeaveRepository implements LeaveRepository {
  InMemoryLeaveRepository(List<LeaveRequest> seed)
    : _rows = List<LeaveRequest>.of(seed);

  final List<LeaveRequest> _rows;

  static const Duration delay = Duration(milliseconds: 450);

  @override
  Future<Result<List<LeaveRequest>>> all() async {
    await Future<void>.delayed(delay);
    return Ok<List<LeaveRequest>>(List<LeaveRequest>.unmodifiable(_rows));
  }

  @override
  Future<Result<LeaveRequest>> decide(
    String id, {
    required bool approve,
  }) async {
    await Future<void>.delayed(delay);
    final int index = _rows.indexWhere((LeaveRequest r) => r.id == id);
    if (index < 0) {
      return const Err<LeaveRequest>(Failure(FailureCode.notFound));
    }
    final LeaveRequest updated = _rows[index].copyWith(
      status: approve ? LeaveStatus.approved : LeaveStatus.rejected,
    );
    _rows[index] = updated;
    return Ok<LeaveRequest>(updated);
  }
}

// ---------------------------------------------------------------------------
// Providers. Concrete instances are installed via ProviderScope overrides
// in bootstrap(); defaults below make tests/widgets usable standalone.
// ---------------------------------------------------------------------------

final Provider<AttendanceRepository> attendanceRepositoryProvider =
    Provider<AttendanceRepository>((Ref ref) {
      final DateTime today = ref.watch(clockProvider).now();
      final List<Employee> staff = DummyData.employees();
      return InMemoryAttendanceRepository(
        DummyData.attendance(staff, today),
        staff.length,
      );
    });

final Provider<EmployeeRepository> employeeRepositoryProvider =
    Provider<EmployeeRepository>((Ref ref) {
      return InMemoryEmployeeRepository(DummyData.employees());
    });

final Provider<LeaveRepository> leaveRepositoryProvider =
    Provider<LeaveRepository>((Ref ref) {
      final DateTime today = ref.watch(clockProvider).now();
      return InMemoryLeaveRepository(
        DummyData.leaves(DummyData.employees(), today),
      );
    });

/// Lookup helper so rows can resolve employee names locally.
final FutureProvider<List<Employee>> allEmployeesProvider =
    FutureProvider<List<Employee>>((Ref ref) async {
      final EmployeeRepository repo = ref.watch(employeeRepositoryProvider);
      final Result<List<Employee>> result = await repo.all();
      switch (result) {
        case Ok(:final List<Employee> value):
          return value;
        case Err(:final Failure failure):
          throw StateError('employees:${failure.code.name}');
      }
    });
