import 'package:absensi_dashboard/core/extensions.dart';
import 'package:absensi_dashboard/data/dummy_data.dart';
import 'package:test/test.dart';

void main() {
  group('AttendanceMath.percent', () {
    test('returns 0 when total is 0', () {
      expect(AttendanceMath.percent(5, 0), 0);
    });

    test('computes part over total', () {
      expect(AttendanceMath.percent(30, 40), closeTo(75, 0.001));
      expect(AttendanceMath.percent(0, 40), 0);
      expect(AttendanceMath.percent(40, 40), 100);
    });
  });

  group('AttendanceMath.formatDuration', () {
    test('formats Indonesian labels', () {
      expect(
        AttendanceMath.formatDuration(
          const Duration(hours: 7, minutes: 32),
          indonesian: true,
        ),
        '7 jam 32 mnt',
      );
      expect(
        AttendanceMath.formatDuration(
          const Duration(minutes: 20),
          indonesian: true,
        ),
        '20 mnt',
      );
    });

    test('formats English labels', () {
      expect(
        AttendanceMath.formatDuration(
          const Duration(hours: 7, minutes: 32),
          indonesian: false,
        ),
        '7h 32min',
      );
    });
  });

  group('DummyData', () {
    test('is deterministic across calls', () {
      final List<String> first = DummyData.employees()
          .map((e) => e.name)
          .toList();
      final List<String> second = DummyData.employees()
          .map((e) => e.name)
          .toList();
      expect(first, second);
      expect(first.length, 40);
    });

    test('covers several departments', () {
      final depts = DummyData.employees().map((e) => e.department).toSet();
      expect(depts.length, greaterThanOrEqualTo(5));
    });

    test('initials helper works', () {
      expect('Rina Wijaya'.initials, 'RW');
      expect('Budi'.initials, 'B');
    });
  });
}
