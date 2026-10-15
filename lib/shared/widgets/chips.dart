import 'package:absensi_dashboard/data/models.dart';
import 'package:absensi_dashboard/l10n/gen/app_localizations.dart';
import 'package:absensi_dashboard/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Status chip: always color + icon + text (never color alone).
final class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final AttendanceStatus status;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final AppTokens tokens = AppTokens.of(context);
    final ({Color color, IconData icon, String label}) data = switch (status) {
      AttendanceStatus.present => (
        color: tokens.success,
        icon: Icons.check_circle_rounded,
        label: strings.statusPresent,
      ),
      AttendanceStatus.late => (
        color: tokens.warning,
        icon: Icons.watch_later_rounded,
        label: strings.statusLate,
      ),
      AttendanceStatus.leave => (
        color: tokens.leave,
        icon: Icons.event_busy_rounded,
        label: strings.statusLeave,
      ),
      AttendanceStatus.alpha => (
        color: tokens.danger,
        icon: Icons.cancel_rounded,
        label: strings.statusAlpha,
      ),
    };
    return Semantics(
      label: data.label,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: data.color.withValues(alpha: 0.14),
          borderRadius: const BorderRadius.all(Radius.circular(AppRadius.pill)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ExcludeSemantics(
              child: Icon(data.icon, size: 14, color: data.color),
            ),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              data.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: data.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Leave status chip (color + icon + text).
final class LeaveChip extends StatelessWidget {
  const LeaveChip({super.key, required this.status, required this.label});

  final LeaveStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final AppTokens tokens = AppTokens.of(context);
    final ({Color color, IconData icon}) data = switch (status) {
      LeaveStatus.pending => (
        color: tokens.warning,
        icon: Icons.hourglass_top_rounded,
      ),
      LeaveStatus.approved => (
        color: tokens.success,
        icon: Icons.task_alt_rounded,
      ),
      LeaveStatus.rejected => (color: tokens.danger, icon: Icons.block_rounded),
    };
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: data.color.withValues(alpha: 0.14),
          borderRadius: const BorderRadius.all(Radius.circular(AppRadius.pill)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ExcludeSemantics(
              child: Icon(data.icon, size: 14, color: data.color),
            ),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: data.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section header with title + optional trailing action.
final class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel ?? '')),
      ],
    );
  }
}

/// Avatar with initials on a soft deterministic background.
final class InitialAvatar extends StatelessWidget {
  const InitialAvatar({super.key, required this.name, this.size = 48});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final List<Color> palette = AppTokens.of(context).avatarBackgrounds;
    // Deterministic pick (String.hashCode is salted per run).
    int hash = 0;
    for (final int rune in name.runes) {
      hash = (hash * 31 + rune) % 997;
    }
    final Color bg = palette[hash % palette.length];
    String initials = '?';
    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isNotEmpty && parts.first.isNotEmpty) {
      initials = parts.first.substring(0, 1).toUpperCase();
      if (parts.length > 1 && parts[1].isNotEmpty) {
        initials += parts[1].substring(0, 1).toUpperCase();
      }
    }
    return Semantics(
      label: name,
      image: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        alignment: AlignmentDirectional.center,
        child: Text(
          initials,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppPalette.inkLight,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
