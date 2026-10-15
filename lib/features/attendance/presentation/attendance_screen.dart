import 'package:absensi_dashboard/core/failures.dart';
import 'package:absensi_dashboard/features/attendance/presentation/attendance_notifier.dart';
import 'package:absensi_dashboard/l10n/gen/app_localizations.dart';
import 'package:absensi_dashboard/shared/widgets/chips.dart';
import 'package:absensi_dashboard/shared/widgets/state_views.dart';
import 'package:absensi_dashboard/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Attendance list: date strip + picker, status chips, search,
/// department filter. Watches one notifier.
final class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final AsyncValue<AttendanceState> state = ref.watch(attendanceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.navAttendance)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(attendanceProvider.notifier).refresh(),
          child: _AttendanceBody(state: state),
        ),
      ),
    );
  }
}

final class _AttendanceBody extends ConsumerWidget {
  const _AttendanceBody({required this.state});

  final AsyncValue<AttendanceState> state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context);
    switch (state) {
      case AsyncLoading<AttendanceState>(:final bool hasValue):
        final AttendanceState? previous = state.value;
        if (hasValue && previous != null) {
          return _ListContent(data: previous);
        }
        return const SingleChildScrollView(
          padding: EdgeInsetsDirectional.all(AppSpacing.md),
          child: LoadingList(rows: 5),
        );
      case AsyncError<AttendanceState>():
        return ErrorView(
          title: strings.errorTitle,
          message: strings.errorUnknown,
          retryLabel: strings.retry,
          onRetry: () => ref.invalidate(attendanceProvider),
        );
      case AsyncData<AttendanceState>(:final AttendanceState value):
        if (value.failure != null) {
          return ErrorView(
            title: strings.errorTitle,
            message: messageForFailure(value.failure!, strings),
            retryLabel: strings.retry,
            onRetry: () => ref.invalidate(attendanceProvider),
          );
        }
        if (value.rows.isEmpty) {
          return EmptyView(
            icon: Icons.fact_check_outlined,
            title: strings.emptyTitle,
            body: strings.emptyBody,
            actionLabel: strings.retry,
            onAction: () => ref.invalidate(attendanceProvider),
          );
        }
        if (value.visible.isEmpty) {
          return Column(
            children: <Widget>[
              _Toolbar(data: value),
              Expanded(
                child: EmptyView(
                  icon: Icons.search_off_rounded,
                  title: strings.noResultTitle,
                  body: strings.noResultBody,
                  actionLabel: strings.resetFilter,
                  onAction: () =>
                      ref.read(attendanceProvider.notifier).resetFilters(),
                ),
              ),
            ],
          );
        }
        return _ListContent(data: value);
    }
  }
}

final class _ListContent extends StatelessWidget {
  const _ListContent({required this.data});

  final AttendanceState data;

  @override
  Widget build(BuildContext context) {
    final List<AttendanceRow> rows = data.visible;
    return ListView.builder(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      itemCount: rows.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return _Toolbar(data: data);
        }
        return _AttendanceTile(row: rows[index - 1]);
      },
    );
  }
}

final class _Toolbar extends ConsumerWidget {
  const _Toolbar({required this.data});

  final AttendanceState data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final AttendanceNotifier notifier = ref.read(attendanceProvider.notifier);
    final List<(AttendanceFilter, String)> chips = <(AttendanceFilter, String)>[
      (AttendanceFilter.all, strings.filterAll),
      (AttendanceFilter.present, strings.statusPresent),
      (AttendanceFilter.late, strings.statusLate),
      (AttendanceFilter.leave, strings.statusLeave),
      (AttendanceFilter.alpha, strings.statusAlpha),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _DateStrip(day: data.day, label: data.dayLabel),
        const SizedBox(height: AppSpacing.xs),
        _WeekStrip(days: data.stripDays, selected: data.day),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          decoration: InputDecoration(
            hintText: strings.searchHint,
            prefixIcon: const Icon(Icons.search_rounded),
          ),
          textInputAction: TextInputAction.search,
          onChanged: notifier.setQuery,
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              for (final (AttendanceFilter, String) chip in chips)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: AppSpacing.xs),
                  child: ChoiceChip(
                    label: Text(chip.$2),
                    selected: data.filter == chip.$1,
                    onSelected: (_) => notifier.setFilter(chip.$1),
                  ),
                ),
              const SizedBox(width: AppSpacing.xs),
              DropdownMenu<String?>(
                initialSelection: data.department,
                label: Text(strings.filterDepartment),
                onSelected: notifier.setDepartment,
                dropdownMenuEntries: <DropdownMenuEntry<String?>>[
                  DropdownMenuEntry<String?>(
                    value: null,
                    label: strings.filterAll,
                  ),
                  for (final String dept in data.departments)
                    DropdownMenuEntry<String?>(value: dept, label: dept),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

final class _DateStrip extends ConsumerWidget {
  const _DateStrip({required this.day, required this.label});

  final DateTime day;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Semantics(
            label: label,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.calendar_month_rounded),
          tooltip: label,
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: day,
              firstDate: day.subtract(const Duration(days: 60)),
              lastDate: day.add(const Duration(days: 1)),
            );
            if (picked != null) {
              await ref.read(attendanceProvider.notifier).selectDay(picked);
            }
          },
        ),
      ],
    );
  }
}

/// Horizontal 7-day strip around the selected day.
final class _WeekStrip extends ConsumerWidget {
  const _WeekStrip({required this.days, required this.selected});

  final List<DateTime> days;
  final DateTime selected;

  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String locale = Localizations.localeOf(context).languageCode;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 68,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (BuildContext context, int index) {
          final DateTime day = days[index];
          final bool active = sameDay(day, selected);
          final String label = '${DateFormat.E(locale).format(day)} ${day.day}';
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: AppSpacing.xs),
            child: Semantics(
              button: true,
              selected: active,
              label: label,
              child: InkWell(
                onTap: () =>
                    ref.read(attendanceProvider.notifier).selectDay(day),
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadius.md),
                ),
                child: Container(
                  width: 52,
                  padding: const EdgeInsetsDirectional.symmetric(
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? scheme.primary
                        : scheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(AppRadius.md),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        DateFormat.E(locale).format(day),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: active
                                  ? scheme.onPrimary
                                  : scheme.onSurfaceVariant,
                            ),
                      ),
                      Text(
                        '${day.day}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: active ? scheme.onPrimary : scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

final class _AttendanceTile extends StatelessWidget {
  const _AttendanceTile({required this.row});

  final AttendanceRow row;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/attendance/record/${row.record.id}'),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
          child: Row(
            children: <Widget>[
              InitialAvatar(name: row.employeeName),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      row.employeeName,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${row.department} • '
                      '${row.checkInLabel}–${row.checkOutLabel} • '
                      '${row.durationLabel} • ${row.modeLabel}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusChip(status: row.record.status),
            ],
          ),
        ),
      ),
    );
  }
}
