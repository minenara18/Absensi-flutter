import 'package:absensi_dashboard/core/result.dart';
import 'package:absensi_dashboard/data/models.dart';
import 'package:absensi_dashboard/data/repositories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// Immutable employees list state; [visible] is derived from [query].
@immutable
final class EmployeesState {
  const EmployeesState({
    required this.staff,
    this.query = '',
    this.failure,
  });

  final List<Employee> staff;
  final String query;
  final Failure? failure;

  List<Employee> get visible {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return staff;
    }
    return staff
        .where(
          (Employee e) =>
              e.name.toLowerCase().contains(q) ||
              e.department.toLowerCase().contains(q) ||
              e.position.toLowerCase().contains(q),
        )
        .toList();
  }

  EmployeesState copyWith({
    List<Employee>? staff,
    String? query,
    Failure? failure,
  }) {
    return EmployeesState(
      staff: staff ?? this.staff,
      query: query ?? this.query,
      failure: failure,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmployeesState &&
          other.staff == staff &&
          other.query == query &&
          other.failure == failure);

  @override
  int get hashCode => Object.hash(staff, query, failure);
}

final class EmployeesNotifier extends AsyncNotifier<EmployeesState> {
  @override
  Future<EmployeesState> build() async {
    final EmployeeRepository repo = ref.watch(employeeRepositoryProvider);
    final Result<List<Employee>> result = await repo.all();
    switch (result) {
      case Ok(:final List<Employee> value):
        return EmployeesState(staff: value);
      case Err(:final Failure failure):
        return EmployeesState(
          staff: const <Employee>[],
          failure: failure,
        );
    }
  }

  Future<void> refresh() async {
    final EmployeesState? current = state.value;
    final EmployeeRepository repo = ref.read(employeeRepositoryProvider);
    final Result<List<Employee>> result = await repo.all();
    switch (result) {
      case Ok(:final List<Employee> value):
        state = AsyncData<EmployeesState>(
          EmployeesState(staff: value, query: current?.query ?? ''),
        );
      case Err(:final Failure failure):
        state = AsyncData<EmployeesState>(
          EmployeesState(
            staff: current?.staff ?? const <Employee>[],
            query: current?.query ?? '',
            failure: failure,
          ),
        );
    }
  }

  void setQuery(String query) {
    final EmployeesState? current = state.value;
    if (current != null) {
      state = AsyncData<EmployeesState>(current.copyWith(query: query));
    }
  }
}

final AsyncNotifierProvider<EmployeesNotifier, EmployeesState>
employeesProvider = AsyncNotifierProvider<EmployeesNotifier, EmployeesState>(
  EmployeesNotifier.new,
);
