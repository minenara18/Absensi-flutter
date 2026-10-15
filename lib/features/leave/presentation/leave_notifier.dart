import 'package:absensi_dashboard/core/result.dart';
import 'package:absensi_dashboard/data/models.dart';
import 'package:absensi_dashboard/data/repositories.dart';
import 'package:absensi_dashboard/features/settings/presentation/settings_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

/// One leave card with display fields pre-formatted by the notifier.
@immutable
final class LeaveCardData {
  const LeaveCardData({
    required this.request,
    required this.employeeName,
    required this.rangeLabel,
  });

  final LeaveRequest request;
  final String employeeName;
  final String rangeLabel;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LeaveCardData &&
          other.request == request &&
          other.employeeName == employeeName &&
          other.rangeLabel == rangeLabel);

  @override
  int get hashCode => Object.hash(request, employeeName, rangeLabel);
}

/// Immutable leave state; tab filtering is derived.
@immutable
final class LeaveState {
  const LeaveState({required this.cards, this.lastAction});

  final List<LeaveCardData> cards;

  /// Last decision, for the Undo snackbar (request + previous status).
  final ({LeaveRequest request, LeaveStatus previous})? lastAction;

  List<LeaveCardData> forStatus(LeaveStatus status) {
    return cards
        .where((LeaveCardData c) => c.request.status == status)
        .toList();
  }

  int get pendingCount => cards
      .where((LeaveCardData c) => c.request.status == LeaveStatus.pending)
      .length;

  LeaveState copyWith({
    List<LeaveCardData>? cards,
    ({LeaveRequest request, LeaveStatus previous})? lastAction,
    bool clearAction = false,
  }) {
    return LeaveState(
      cards: cards ?? this.cards,
      lastAction: clearAction ? null : (lastAction ?? this.lastAction),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is LeaveState && other.cards == cards);

  @override
  int get hashCode => cards.hashCode;
}

final class LeaveNotifier extends AsyncNotifier<LeaveState> {
  @override
  Future<LeaveState> build() async {
    final LeaveRepository repo = ref.watch(leaveRepositoryProvider);
    final EmployeeRepository employees = ref.watch(employeeRepositoryProvider);
    final String locale = ref.watch(settingsProvider).locale.languageCode;

    final Result<List<LeaveRequest>> result = await repo.all();
    final Result<List<Employee>> staffRes = await employees.all();
    final Map<String, String> names = switch (staffRes) {
      Ok(:final List<Employee> value) => <String, String>{
        for (final Employee e in value) e.id: e.name,
      },
      Err() => <String, String>{},
    };
    final DateFormat fmt = DateFormat.yMMMd(locale);
    switch (result) {
      case Ok(:final List<LeaveRequest> value):
        return LeaveState(
          cards: value
              .map(
                (LeaveRequest r) => LeaveCardData(
                  request: r,
                  employeeName: names[r.employeeId] ?? r.employeeId,
                  rangeLabel: '${fmt.format(r.start)} – ${fmt.format(r.end)}',
                ),
              )
              .toList(),
        );
      case Err(:final Failure failure):
        throw StateError('leave:${failure.code.name}');
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Decide + remember previous status so the UI can offer Undo.
  Future<void> decide(LeaveCardData card, {required bool approve}) async {
    final LeaveState? current = state.value;
    if (current == null) {
      return;
    }
    final LeaveRepository repo = ref.read(leaveRepositoryProvider);
    final Result<LeaveRequest> result = await repo.decide(
      card.request.id,
      approve: approve,
    );
    final LeaveState? latest = state.value;
    if (latest == null) {
      return;
    }
    switch (result) {
      case Ok(:final LeaveRequest value):
        final List<LeaveCardData> next = latest.cards
            .map(
              (LeaveCardData c) => c.request.id == value.id
                  ? LeaveCardData(
                      request: value,
                      employeeName: c.employeeName,
                      rangeLabel: c.rangeLabel,
                    )
                  : c,
            )
            .toList();
        state = AsyncData<LeaveState>(
          latest.copyWith(
            cards: next,
            lastAction: (
              request: card.request,
              previous: card.request.status,
            ),
          ),
        );
      case Err():
        break;
    }
  }

  /// Restore the previous status (Undo). Dummy repo has no "revert",
  /// so this re-applies via decide back to the recorded status.
  Future<void> undoLast() async {
    final LeaveState? current = state.value;
    final action = current?.lastAction;
    if (current == null || action == null) {
      return;
    }
    final LeaveRepository repo = ref.read(leaveRepositoryProvider);
    final bool backToApproved = action.previous == LeaveStatus.approved;
    // Pending cannot be restored through decide(); re-add locally instead.
    if (action.previous == LeaveStatus.pending) {
      final List<LeaveCardData> next = current.cards
          .map(
            (LeaveCardData c) => c.request.id == action.request.id
                ? LeaveCardData(
                    request: action.request,
                    employeeName: c.employeeName,
                    rangeLabel: c.rangeLabel,
                  )
                : c,
          )
          .toList();
      state = AsyncData<LeaveState>(
        current.copyWith(cards: next, clearAction: true),
      );
      return;
    }
    final Result<LeaveRequest> result = await repo.decide(
      action.request.id,
      approve: backToApproved,
    );
    final LeaveState? latest = state.value;
    if (latest == null) {
      return;
    }
    switch (result) {
      case Ok(:final LeaveRequest value):
        final List<LeaveCardData> next = latest.cards
            .map(
              (LeaveCardData c) => c.request.id == value.id
                  ? LeaveCardData(
                      request: value,
                      employeeName: c.employeeName,
                      rangeLabel: c.rangeLabel,
                    )
                  : c,
            )
            .toList();
        state = AsyncData<LeaveState>(
          latest.copyWith(cards: next, clearAction: true),
        );
      case Err():
        break;
    }
  }

  void consumeAction() {
    final LeaveState? current = state.value;
    if (current != null) {
      state = AsyncData<LeaveState>(current.copyWith(clearAction: true));
    }
  }
}

final AsyncNotifierProvider<LeaveNotifier, LeaveState> leaveProvider =
    AsyncNotifierProvider<LeaveNotifier, LeaveState>(LeaveNotifier.new);
