import 'dart:async';
import 'package:absensi_dashboard/app.dart';
import 'package:absensi_dashboard/core/clock.dart';
import 'package:absensi_dashboard/data/dummy_data.dart';
import 'package:absensi_dashboard/data/models.dart';
import 'package:absensi_dashboard/data/repositories.dart';
import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// Composition root: error handlers + infra overrides, then first frame.
Future<void> bootstrap() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  WidgetsBinding.instance.platformDispatcher.onError =
      (Object error, StackTrace stack) {
        debugPrint('uncaught async: $error');
        return true;
      };

  // Build the dummy world once so every repository shares one dataset.
  final DateTime now = const Clock().now();
  final DummyWorld world = DummyWorld.build(now);

  runApp(
    ProviderScope(
      overrides: <Override>[
        attendanceRepositoryProvider.overrideWithValue(world.attendance),
        employeeRepositoryProvider.overrideWithValue(world.employees),
        leaveRepositoryProvider.overrideWithValue(world.leaves),
        clockProvider.overrideWithValue(Clock.fixed(now)),
      ],
      child: const AbsensiApp(),
    ),
  );
}

/// Shared in-memory dataset behind the dummy repositories.
final class DummyWorld {
  DummyWorld._({
    required this.attendance,
    required this.employees,
    required this.leaves,
  });

  factory DummyWorld.build(DateTime now) {
    final List<Employee> staff = DummyData.employees();
    return DummyWorld._(
      attendance: InMemoryAttendanceRepository(
        DummyData.attendance(staff, now),
        staff.length,
      ),
      employees: InMemoryEmployeeRepository(staff),
      leaves: InMemoryLeaveRepository(DummyData.leaves(staff, now)),
    );
  }

  final AttendanceRepository attendance;
  final EmployeeRepository employees;
  final LeaveRepository leaves;
}
