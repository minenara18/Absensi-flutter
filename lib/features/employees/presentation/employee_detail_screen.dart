import 'package:absensi_dashboard/core/extensions.dart';
import 'package:absensi_dashboard/core/result.dart';
import 'package:absensi_dashboard/data/models.dart';
import 'package:absensi_dashboard/data/repositories.dart';
import 'package:absensi_dashboard/l10n/gen/app_localizations.dart';
import 'package:absensi_dashboard/shared/widgets/chips.dart';
import 'package:absensi_dashboard/shared/widgets/state_views.dart';
import 'package:absensi_dashboard/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router/go_router.dart';

/// Detail view-model for one employee.
final class EmployeeDetailData {
  const EmployeeDetailData({
    required this.employee,
    required this.history,
    required this.presentCount,
    required this.totalCount,
  });

  final Employee employee;
  final List<AttendanceRecord> history;
  final int presentCount;
  final int totalCount;

  double get rate => AttendanceMath.percent(presentCount, totalCount);
}

final class EmployeeDetailNotifier extends AsyncNotifier<EmployeeDetailData> {
  EmployeeDetailNotifier(this.employeeIdArg);

  final String employeeIdArg;

  @override
  Future<EmployeeDetailData> build() async {
    final String arg = employeeIdArg;
    final EmployeeRepository employees = ref.watch(employeeRepositoryProvider);
    final AttendanceRepository attendance = ref.watch(
      attendanceRepositoryProvider,
    );

    final Result<Employee> empRes = await employees.byId(arg);
    final Employee employee = switch (empRes) {
      Ok(:final Employee value) => value,
      Err(:final Failure failure) => throw StateError(
        'employee-detail:${failure.code.name}',
      ),
    };
    final Result<List<AttendanceRecord>> historyRes = await attendance
        .historyOf(arg, 30);
    final List<AttendanceRecord> history = switch (historyRes) {
      Ok(:final List<AttendanceRecord> value) => value,
      Err() => <AttendanceRecord>[],
    };
    final List<AttendanceRecord> workdays = history
        .where(
          (AttendanceRecord r) =>
              r.date.weekday != DateTime.saturday &&
              r.date.weekday != DateTime.sunday,
        )
        .toList();
    final int present = workdays
        .where(
          (AttendanceRecord r) =>
              r.status == AttendanceStatus.present ||
              r.status == AttendanceStatus.late,
        )
        .length;
    return EmployeeDetailData(
      employee: employee,
      history: history.take(6).toList(),
      presentCount: present,
      totalCount: workdays.length,
    );
  }
}

final AsyncNotifierProviderFamily<
  EmployeeDetailNotifier,
  EmployeeDetailData,
  String
>
employeeDetailProvider =
    AsyncNotifierProvider.family<
      EmployeeDetailNotifier,
      EmployeeDetailData,
      String
    >(
      EmployeeDetailNotifier.new,
    );

/// Employee profile + monthly attendance donut + short history.
final class EmployeeDetailScreen extends ConsumerWidget {
  const EmployeeDetailScreen({super.key, required this.employeeId});

  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final AsyncValue<EmployeeDetailData> state = ref.watch(
      employeeDetailProvider(employeeId),
    );

    return Scaffold(
      appBar: AppBar(title: Text(strings.employeeDetail)),
      body: SafeArea(
        child: switch (state) {
          AsyncLoading<EmployeeDetailData>() => const SingleChildScrollView(
            padding: EdgeInsetsDirectional.all(AppSpacing.md),
            child: LoadingList(rows: 3),
          ),
          AsyncError<EmployeeDetailData>() => ErrorView(
            title: strings.errorTitle,
            message: strings.errorNotFound,
            retryLabel: strings.retry,
            onRetry: () => ref.invalidate(
              employeeDetailProvider(employeeId),
            ),
          ),
          AsyncData<EmployeeDetailData>(:final EmployeeDetailData value) =>
            _DetailContent(data: value),
        },
      ),
    );
  }
}

final class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.data});

  final EmployeeDetailData data;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            child: Row(
              children: <Widget>[
                InitialAvatar(name: data.employee.name, size: 64),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        data.employee.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${data.employee.position}\n'
                        '${data.employee.department} • ${data.employee.email}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  strings.attendanceThisMonth,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: CircularProgressIndicator(
                        value: data.totalCount <= 0
                            ? 0
                            : data.presentCount / data.totalCount,
                        strokeWidth: 8,
                        color: AppTokens.of(context).success,
                        backgroundColor: AppTokens.of(
                          context,
                        ).success.withValues(alpha: 0.15),
                        semanticsLabel: strings.attendanceThisMonth,
                        semanticsValue: '${data.rate.toStringAsFixed(0)}%',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        '${data.presentCount}/${data.totalCount} • ${data.rate.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  strings.history,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                for (final AttendanceRecord record in data.history)
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            MaterialLocalizations.of(
                              context,
                            ).formatMediumDate(record.date),
                          ),
                        ),
                        StatusChip(status: record.status),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () =>
                context.push('/employees/${data.employee.id}/edit'),
            child: Text(strings.edit),
          ),
        ),
      ],
    );
  }
}
