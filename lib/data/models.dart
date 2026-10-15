import 'package:meta/meta.dart';

/// Immutable domain models (no JSON, no BuildContext).
enum AttendanceStatus { present, late, leave, alpha }

enum LeaveStatus { pending, approved, rejected }

enum WorkMode { office, wfh }

/// Employee entity.
@immutable
final class Employee {
  const Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.department,
    required this.email,
    required this.phone,
    required this.active,
    required this.joinDate,
  });

  final String id;
  final String name;
  final String position;
  final String department;
  final String email;
  final String phone;
  final bool active;
  final DateTime joinDate;

  Employee copyWith({
    String? name,
    String? position,
    String? department,
    String? email,
    String? phone,
    bool? active,
  }) {
    return Employee(
      id: id,
      name: name ?? this.name,
      position: position ?? this.position,
      department: department ?? this.department,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      active: active ?? this.active,
      joinDate: joinDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Employee &&
          other.id == id &&
          other.name == name &&
          other.position == position &&
          other.department == department &&
          other.email == email &&
          other.phone == phone &&
          other.active == active &&
          other.joinDate == joinDate);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    position,
    department,
    email,
    phone,
    active,
    joinDate,
  );
}

/// One attendance row for one employee on one day.
@immutable
final class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.status,
    required this.checkIn,
    required this.checkOut,
    required this.mode,
    required this.note,
  });

  final String id;
  final String employeeId;
  final DateTime date;
  final AttendanceStatus status;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final WorkMode mode;
  final String note;

  Duration get workDuration {
    final DateTime? start = checkIn;
    final DateTime? end = checkOut;
    if (start == null || end == null) {
      return Duration.zero;
    }
    return end.difference(start);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceRecord &&
          other.id == id &&
          other.employeeId == employeeId &&
          other.date == date &&
          other.status == status &&
          other.checkIn == checkIn &&
          other.checkOut == checkOut &&
          other.mode == mode &&
          other.note == note);

  @override
  int get hashCode => Object.hash(
    id,
    employeeId,
    date,
    status,
    checkIn,
    checkOut,
    mode,
    note,
  );
}

/// Leave / time-off request.
@immutable
final class LeaveRequest {
  const LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.start,
    required this.end,
    required this.reason,
    required this.status,
  });

  final String id;
  final String employeeId;
  final String type;
  final DateTime start;
  final DateTime end;
  final String reason;
  final LeaveStatus status;

  LeaveRequest copyWith({LeaveStatus? status}) {
    return LeaveRequest(
      id: id,
      employeeId: employeeId,
      type: type,
      start: start,
      end: end,
      reason: reason,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LeaveRequest &&
          other.id == id &&
          other.employeeId == employeeId &&
          other.type == type &&
          other.start == start &&
          other.end == end &&
          other.reason == reason &&
          other.status == status);

  @override
  int get hashCode =>
      Object.hash(id, employeeId, type, start, end, reason, status);
}

/// Daily aggregate, derived from records (never stored separately).
@immutable
final class DailySummary {
  const DailySummary({
    required this.total,
    required this.present,
    required this.late,
    required this.leave,
    required this.absent,
  });

  final int total;
  final int present;
  final int late;
  final int leave;
  final int absent;

  double get presentRate => total <= 0 ? 0 : present / total * 100;
}
