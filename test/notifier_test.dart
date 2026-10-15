import 'package:absensi_dashboard/core/clock.dart';
import 'package:absensi_dashboard/core/result.dart';
import 'package:absensi_dashboard/data/models.dart';
import 'package:absensi_dashboard/data/repositories.dart';
import 'package:absensi_dashboard/features/dashboard/presentation/dashboard_notifier.dart';
import 'package:absensi_dashboard/features/dashboard/presentation/quick_access_notifier.dart';
import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:test/test.dart';

final DateTime testDay = DateTime(2026, 10, 15);

List<Employee> testStaff() => [
  Employee(
    id: 'emp-01',
    name: 'Rina Wijaya',
    position: 'Manajer Teknologi',
    department: 'Teknologi',
    email: 'rina@absensiku.id',
    phone: '0812000001',
    active: true,
    joinDate: DateTime(2023, 1, 10),
  ),
  Employee(
    id: 'emp-02',
    name: 'Budi Santoso',
    position: 'Staf Operasional',
    department: 'Operasional',
    email: 'budi@absensiku.id',
    phone: '0812000002',
    active: true,
    joinDate: DateTime(2023, 2, 10),
  ),
];

List<AttendanceRecord> testRecords() => [
  AttendanceRecord(
    id: 'att-1',
    employeeId: 'emp-01',
    date: testDay,
    status: AttendanceStatus.present,
    checkIn: DateTime(2026, 10, 15, 7, 55),
    checkOut: DateTime(2026, 10, 15, 17, 5),
    mode: WorkMode.office,
    note: '',
  ),
  AttendanceRecord(
    id: 'att-2',
    employeeId: 'emp-02',
    date: testDay,
    status: AttendanceStatus.late,
    checkIn: DateTime(2026, 10, 15, 8, 40),
    checkOut: DateTime(2026, 10, 15, 17, 10),
    mode: WorkMode.wfh,
    note: '',
  ),
];

/// Hand-written fake (no mocks, no codegen).
final class FakeAttendance implements AttendanceRepository {
  FakeAttendance(this.records);

  final List<AttendanceRecord> records;

  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Future<Result<List<AttendanceRecord>>> recordsFor(DateTime day) async =>
      Ok(records.where((r) => sameDay(r.date, day)).toList());

  @override
  Future<Result<AttendanceRecord>> recordById(String id) async =>
      Ok(records.firstWhere((r) => r.id == id));

  @override
  Future<Result<DailySummary>> summaryFor(DateTime day) async => const Ok(
    DailySummary(total: 2, present: 1, late: 1, leave: 0, absent: 0),
  );

  @override
  Future<Result<List<DailyPoint>>> lastDays(
    DateTime today,
    int count,
  ) async => Ok([
    DailyPoint(DateTime(2026, 10, 15), 1, 1),
  ]);

  @override
  Future<Result<List<AttendanceRecord>>> historyOf(
    String employeeId,
    int limit,
  ) async => Ok(records.where((r) => r.employeeId == employeeId).toList());
}

final class FakeEmployees implements EmployeeRepository {
  FakeEmployees(this.staff);

  final List<Employee> staff;

  @override
  Future<Result<List<Employee>>> all() async => Ok(staff);

  @override
  Future<Result<Employee>> byId(String id) async =>
      Ok(staff.firstWhere((e) => e.id == id));

  @override
  Future<Result<Employee>> save(Employee employee) async => Ok(employee);
}

final class FakeLeaves implements LeaveRepository {
  @override
  Future<Result<List<LeaveRequest>>> all() async => const Ok([]);

  @override
  Future<Result<LeaveRequest>> decide(
    String id, {
    required bool approve,
  }) async => const Err(Failure(FailureCode.notFound));
}

ProviderContainer makeContainer() => ProviderContainer(
  overrides: [
    clockProvider.overrideWithValue(Clock.fixed(testDay)),
    attendanceRepositoryProvider.overrideWithValue(
      FakeAttendance(testRecords()),
    ),
    employeeRepositoryProvider.overrideWithValue(FakeEmployees(testStaff())),
    leaveRepositoryProvider.overrideWithValue(FakeLeaves()),
  ],
);

void main() {
  setUpAll(() async {
    // flutter_localizations does this in the app; unit tests must do it.
    await initializeDateFormatting('id');
    await initializeDateFormatting('en');
  });

  group('QuickAccessNotifier', () {
    test('toggle adds and removes favorites', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(quickAccessProvider.notifier);

      expect(
        container.read(quickAccessProvider).favorites.contains('overtime'),
        isTrue,
      );
      notifier.toggle('overtime');
      expect(
        container.read(quickAccessProvider).favorites.contains('overtime'),
        isFalse,
      );
      notifier.toggle('location');
      expect(
        container.read(quickAccessProvider).favorites.last,
        'location',
      );
    });

    test('move reorders with bounds', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(quickAccessProvider.notifier);
      final first = container.read(quickAccessProvider).favorites.first;

      notifier.move(first, -1); // already first: no-op
      expect(container.read(quickAccessProvider).favorites.first, first);

      notifier.move(first, 1);
      expect(container.read(quickAccessProvider).favorites[1], first);
    });
  });

  group('DashboardNotifier', () {
    test('derives summary and recent activity', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      final data = await container.read(dashboardProvider.future);

      expect(data.summary.total, 2);
      expect(data.summary.present, 1);
      expect(data.summary.late, 1);
      expect(data.recent.length, 2);
      expect(data.pendingCount, 0);
      // latest check-in first
      expect(data.recent.first.employeeName, 'Budi Santoso');
    });

    test('search query filters recent activity', () async {
      final container = makeContainer();
      addTearDown(container.dispose);
      await container.read(dashboardProvider.future);

      container.read(dashboardProvider.notifier).setQuery('rina');
      final AsyncValue<DashboardData> state = container.read(
        dashboardProvider,
      );
      switch (state) {
        case AsyncData(:final DashboardData value):
          expect(value.visibleRecent.length, 1);
          expect(value.visibleRecent.first.employeeName, 'Rina Wijaya');
        case AsyncLoading():
        case AsyncError():
          fail('expected dashboard data, got $state');
      }
    });
  });
}
