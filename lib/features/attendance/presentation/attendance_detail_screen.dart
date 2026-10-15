import 'package:absensi_dashboard/core/extensions.dart';
import 'package:absensi_dashboard/core/result.dart';
import 'package:absensi_dashboard/data/models.dart';
import 'package:absensi_dashboard/data/repositories.dart';
import 'package:absensi_dashboard/features/settings/presentation/settings_notifier.dart';
import 'package:absensi_dashboard/l10n/gen/app_localizations.dart';
import 'package:absensi_dashboard/shared/widgets/chips.dart';
import 'package:absensi_dashboard/shared/widgets/state_views.dart';
import 'package:absensi_dashboard/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:intl/intl.dart';

/// Detail view-model state for one record.
final class AttendanceDetailData {
  const AttendanceDetailData({
    required this.record,
    required this.employeeName,
    required this.department,
    required this.dateLabel,
    required this.checkInLabel,
    required this.breakLabel,
    required this.checkOutLabel,
    required this.durationLabel,
    required this.modeLabel,
  });

  final AttendanceRecord record;
  final String employeeName;
  final String department;
  final String dateLabel;
  final String checkInLabel;
  final String breakLabel;
  final String checkOutLabel;
  final String durationLabel;
  final String modeLabel;
}

final class AttendanceDetailNotifier
    extends AsyncNotifier<AttendanceDetailData> {
  AttendanceDetailNotifier(this.recordId);

  final String recordId;

  @override
  Future<AttendanceDetailData> build() async {
    final String arg = recordId;
    final String locale = ref.watch(settingsProvider).locale.languageCode;
    final AttendanceRepository attendance = ref.watch(
      attendanceRepositoryProvider,
    );
    final EmployeeRepository employees = ref.watch(employeeRepositoryProvider);

    final Result<AttendanceRecord> recordRes = await attendance.recordById(arg);
    final AttendanceRecord record = switch (recordRes) {
      Ok(:final AttendanceRecord value) => value,
      Err(:final Failure failure) => throw StateError(
        'attendance-detail:${failure.code.name}',
      ),
    };
    final Result<Employee> empRes = await employees.byId(record.employeeId);
    final String name = switch (empRes) {
      Ok(:final Employee value) => value.name,
      Err() => record.employeeId,
    };
    final String dept = switch (empRes) {
      Ok(:final Employee value) => value.department,
      Err() => '—',
    };
    final DateFormat time = DateFormat.Hm(locale);
    final DateTime? checkIn = record.checkIn;
    final DateTime? checkOut = record.checkOut;
    return AttendanceDetailData(
      record: record,
      employeeName: name,
      department: dept,
      dateLabel: DateFormat.yMMMMEEEEd(locale).format(record.date),
      checkInLabel: checkIn == null ? '—' : time.format(checkIn),
      breakLabel: checkIn == null
          ? '—'
          : time.format(checkIn.add(const Duration(hours: 4))),
      checkOutLabel: checkOut == null ? '—' : time.format(checkOut),
      durationLabel: AttendanceMath.formatDuration(
        record.workDuration,
        indonesian: locale == 'id',
      ),
      modeLabel: record.mode == WorkMode.office
          ? (locale == 'id' ? 'Kantor' : 'Office')
          : 'WFH',
    );
  }
}

final AsyncNotifierProviderFamily<
  AttendanceDetailNotifier,
  AttendanceDetailData,
  String
>
attendanceDetailProvider =
    AsyncNotifierProvider.family<
      AttendanceDetailNotifier,
      AttendanceDetailData,
      String
    >(
      AttendanceDetailNotifier.new,
    );

/// Detail screen for one attendance record (id via path param).
final class AttendanceDetailScreen extends ConsumerWidget {
  const AttendanceDetailScreen({super.key, required this.recordId});

  final String recordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final AsyncValue<AttendanceDetailData> state = ref.watch(
      attendanceDetailProvider(recordId),
    );

    return Scaffold(
      appBar: AppBar(title: Text(strings.attendanceDetail)),
      body: SafeArea(
        child: switch (state) {
          AsyncLoading<AttendanceDetailData>() => const SingleChildScrollView(
            padding: EdgeInsetsDirectional.all(AppSpacing.md),
            child: LoadingList(rows: 3),
          ),
          AsyncError<AttendanceDetailData>() => ErrorView(
            title: strings.errorTitle,
            message: strings.errorNotFound,
            retryLabel: strings.retry,
            onRetry: () => ref.invalidate(
              attendanceDetailProvider(recordId),
            ),
          ),
          AsyncData<AttendanceDetailData>(:final AttendanceDetailData value) =>
            _DetailContent(data: value),
        },
      ),
    );
  }
}

final class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.data});

  final AttendanceDetailData data;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      children: <Widget>[
        _ProfileHeader(data: data),
        const SizedBox(height: AppSpacing.md),
        _ProofCard(data: data),
        const SizedBox(height: AppSpacing.md),
        _TimelineCard(data: data),
        const SizedBox(height: AppSpacing.md),
        if (data.record.note.isNotEmpty)
          _NoteCard(text: data.record.note, title: strings.notes),
        if (data.record.note.isNotEmpty) const SizedBox(height: AppSpacing.md),
        Semantics(
          button: true,
          label: strings.manualCorrection,
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(strings.manualCorrection)),
                );
              },
              child: Text(strings.manualCorrection),
            ),
          ),
        ),
      ],
    );
  }
}

final class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.data});

  final AttendanceDetailData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Row(
          children: <Widget>[
            InitialAvatar(name: data.employeeName, size: 56),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    data.employeeName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${data.department} • ${data.dateLabel}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            StatusChip(status: data.record.status),
          ],
        ),
      ),
    );
  }
}

final class _ProofCard extends StatelessWidget {
  const _ProofCard({required this.data});

  final AttendanceDetailData data;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              strings.proofPhoto,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.25),
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadius.md),
                ),
              ),
              alignment: AlignmentDirectional.center,
              child: ExcludeSemantics(
                child: Icon(
                  Icons.photo_camera_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              strings.locationMap,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadius.md),
                ),
              ),
              alignment: AlignmentDirectional.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ExcludeSemantics(
                    child: Icon(
                      Icons.location_on_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text('${data.modeLabel} • -6.2, 106.8'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.data});

  final AttendanceDetailData data;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final List<({String label, String time, IconData icon})> steps =
        <({String label, String time, IconData icon})>[
          (
            label: strings.checkIn,
            time: data.checkInLabel,
            icon: Icons.login_rounded,
          ),
          (
            label: strings.timelineBreak,
            time: data.breakLabel,
            icon: Icons.coffee_rounded,
          ),
          (
            label: strings.checkOut,
            time: data.checkOutLabel,
            icon: Icons.logout_rounded,
          ),
        ];
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              '${strings.timeline} • ${strings.workDuration}: '
              '${data.durationLabel}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final step in steps)
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: <Widget>[
                    ExcludeSemantics(
                      child: Icon(
                        step.icon,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(step.label)),
                    Text(
                      step.time,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

final class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.text, required this.title});

  final String text;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(text),
          ],
        ),
      ),
    );
  }
}
