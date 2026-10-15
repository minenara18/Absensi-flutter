import 'package:absensi_dashboard/data/models.dart';

/// Deterministic dummy data (fixed seed algorithm, no ambient Random).
///
/// A tiny linear-congruential generator keeps every run identical.
final class DummyData {
  const DummyData._();

  static const List<String> departments = <String>[
    'Teknologi',
    'Operasional',
    'Keuangan',
    'Pemasaran',
    'SDM',
    'Layanan',
  ];

  static const List<String> positions = <String>[
    'Staf',
    'Senior Staf',
    'Supervisor',
    'Manajer',
    'Asisten',
    'Koordinator',
  ];

  static const List<String> names = <String>[
    'Rina Wijaya',
    'Budi Santoso',
    'Siti Rahayu',
    'Agus Prasetyo',
    'Dewi Lestari',
    'Andi Nugroho',
    'Maya Putri',
    'Rudi Hartono',
    'Fitri Handayani',
    'Hendra Gunawan',
    'Nina Kurnia',
    'Dedi Supriadi',
    'Lina Marlina',
    'Eko Saputra',
    'Ratna Sari',
    'Yoga Firmansyah',
    'Intan Permata',
    'Fajar Ramadhan',
    'Wulan Dari',
    'Tono Sucipto',
    'Ayu Lestari',
    'Rizky Maulana',
    'Dian Puspita',
    'Irfan Hakim',
    'Sari Wulandari',
    'Bambang Sutrisno',
    'Yuni Astuti',
    'Danu Wardhana',
    'Eka Pratiwi',
    'Galih Prakoso',
    'Hesti Puspita',
    'Ilham Ramadhan',
    'Joko Susilo',
    'Kirana Dewi',
    'Lukman Nulhakim',
    'Mega Lestari',
    'Nanda Pratama',
    'Oscar Mahendra',
    'Putri Ayu',
    'Qoriatul Hasanah',
  ];

  static int _seed = 42;

  static String _slug(String name) {
    final String lower = name.toLowerCase();
    final String cleaned = lower.replaceAll(RegExp('[^a-z ]'), '');
    return cleaned.trim().replaceAll(' ', '.');
  }

  static int _next(int mod) {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    // Use high bits: low bits of LCGs cycle through tiny periods.
    return (_seed >> 9) % mod;
  }

  static List<Employee> employees() {
    _seed = 42;
    final List<Employee> result = <Employee>[];
    for (int i = 0; i < names.length; i++) {
      final String name = names[i];
      final String dept = departments[_next(departments.length)];
      final String pos = positions[_next(positions.length)];
      final bool active = i != 37; // one inactive for the empty-ish demo
      result.add(
        Employee(
          id: 'emp-${(i + 1).toString().padLeft(2, '0')}',
          name: name,
          position: '$pos $dept',
          department: dept,
          email: '${_slug(name)}@absensiku.id',
          phone: '0812${1000000 + _next(8999999)}',
          active: active,
          joinDate: DateTime(2022 + _next(3), 1 + _next(12), 1 + _next(27)),
        ),
      );
    }
    return result;
  }

  /// 30 days of attendance ending at [today] (date-only part is used).
  static List<AttendanceRecord> attendance(
    List<Employee> staff,
    DateTime today,
  ) {
    _seed = 1337;
    final DateTime base = DateTime(today.year, today.month, today.day);
    final List<AttendanceRecord> rows = <AttendanceRecord>[];
    for (int d = 29; d >= 0; d--) {
      final DateTime day = base.subtract(Duration(days: d));
      final bool weekend =
          day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
      for (final Employee emp in staff) {
        final int roll = _next(100);
        AttendanceStatus status;
        if (weekend) {
          status = roll < 88 ? AttendanceStatus.alpha : AttendanceStatus.leave;
        } else if (roll < 78) {
          status = AttendanceStatus.present;
        } else if (roll < 88) {
          status = AttendanceStatus.late;
        } else if (roll < 95) {
          status = AttendanceStatus.leave;
        } else {
          status = AttendanceStatus.alpha;
        }
        DateTime? checkIn;
        DateTime? checkOut;
        if (status == AttendanceStatus.present ||
            status == AttendanceStatus.late) {
          final int inMinute = status == AttendanceStatus.late
              ? 15 + _next(75)
              : _next(15);
          checkIn = DateTime(day.year, day.month, day.day, 8, inMinute);
          checkOut = DateTime(day.year, day.month, day.day, 17, _next(30));
        }
        rows.add(
          AttendanceRecord(
            id: 'att-${emp.id}-${day.month}${day.day}',
            employeeId: emp.id,
            date: day,
            status: status,
            checkIn: checkIn,
            checkOut: checkOut,
            mode: _next(100) < 82 ? WorkMode.office : WorkMode.wfh,
            note: status == AttendanceStatus.late ? 'Terjebak macet' : '',
          ),
        );
      }
    }
    return rows;
  }

  static List<LeaveRequest> leaves(List<Employee> staff, DateTime today) {
    final List<String> types = <String>['Cuti Tahunan', 'Izin Sakit', 'Izin'];
    final List<LeaveRequest> rows = <LeaveRequest>[];
    for (int i = 0; i < 9; i++) {
      final Employee emp = staff[(i * 4 + 1) % staff.length];
      final DateTime start = DateTime(
        today.year,
        today.month,
        today.day,
      ).add(Duration(days: i - 4));
      rows.add(
        LeaveRequest(
          id: 'leave-0${i + 1}',
          employeeId: emp.id,
          type: types[i % types.length],
          start: start,
          end: start.add(Duration(days: i % 3)),
          reason: i % 3 == 0
              ? 'Keperluan keluarga'
              : i % 3 == 1
              ? 'Demam, istirahat di rumah'
              : 'Acara penting',
          status: i < 3
              ? LeaveStatus.pending
              : i < 6
              ? LeaveStatus.approved
              : LeaveStatus.rejected,
        ),
      );
    }
    return rows;
  }
}
