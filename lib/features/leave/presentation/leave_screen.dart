import 'package:absensi_dashboard/data/models.dart';
import 'package:absensi_dashboard/features/leave/presentation/leave_notifier.dart';
import 'package:absensi_dashboard/l10n/gen/app_localizations.dart';
import 'package:absensi_dashboard/shared/widgets/chips.dart';
import 'package:absensi_dashboard/shared/widgets/state_views.dart';
import 'package:absensi_dashboard/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Leave approvals with Pending/Approved/Rejected tabs, confirm
/// dialogs and Undo via snackbar.
final class LeaveScreen extends ConsumerWidget {
  const LeaveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final AsyncValue<LeaveState> state = ref.watch(leaveProvider);

    ref.listen<AsyncValue<LeaveState>>(leaveProvider, (
      AsyncValue<LeaveState>? previous,
      AsyncValue<LeaveState> next,
    ) {
      final action = next.value?.lastAction;
      final prevAction = previous?.value?.lastAction;
      if (action != null && prevAction == null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.saved),
            action: SnackBarAction(
              label: strings.undone,
              onPressed: () => ref.read(leaveProvider.notifier).undoLast(),
            ),
          ),
        );
        ref.read(leaveProvider.notifier).consumeAction();
      }
    });

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(strings.leaveTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          bottom: TabBar(
            tabs: <Tab>[
              Tab(text: strings.tabPending),
              Tab(text: strings.tabApproved),
              Tab(text: strings.tabRejected),
            ],
          ),
        ),
        body: SafeArea(
          child: switch (state) {
            AsyncLoading<LeaveState>(:final bool hasValue) =>
              hasValue
                  ? const _LeaveTabs()
                  : const SingleChildScrollView(
                      padding: EdgeInsetsDirectional.all(AppSpacing.md),
                      child: LoadingList(),
                    ),
            AsyncError<LeaveState>() => ErrorView(
              title: strings.errorTitle,
              message: strings.errorUnknown,
              retryLabel: strings.retry,
              onRetry: () => ref.invalidate(leaveProvider),
            ),
            AsyncData<LeaveState>(:final LeaveState value) => RefreshIndicator(
              onRefresh: () => ref.read(leaveProvider.notifier).refresh(),
              child: _LeaveTabs(data: value),
            ),
          },
        ),
      ),
    );
  }
}

final class _LeaveTabs extends StatelessWidget {
  const _LeaveTabs({this.data});

  final LeaveState? data;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    return TabBarView(
      children: <Widget>[
        _LeaveList(
          cards: data?.forStatus(LeaveStatus.pending) ?? const [],
          emptyIcon: Icons.inbox_rounded,
          approveEnabled: true,
        ),
        _LeaveList(
          cards: data?.forStatus(LeaveStatus.approved) ?? const [],
          emptyIcon: Icons.task_alt_rounded,
          emptyBody: strings.emptyBody,
        ),
        _LeaveList(
          cards: data?.forStatus(LeaveStatus.rejected) ?? const [],
          emptyIcon: Icons.block_rounded,
          emptyBody: strings.emptyBody,
        ),
      ],
    );
  }
}

final class _LeaveList extends StatelessWidget {
  const _LeaveList({
    required this.cards,
    required this.emptyIcon,
    this.emptyBody,
    this.approveEnabled = false,
  });

  final List<LeaveCardData> cards;
  final IconData emptyIcon;
  final String? emptyBody;
  final bool approveEnabled;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    if (cards.isEmpty) {
      return EmptyView(
        icon: emptyIcon,
        title: strings.emptyTitle,
        body: emptyBody ?? strings.emptyBody,
      );
    }
    return ListView.builder(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      itemCount: cards.length,
      itemBuilder: (BuildContext context, int index) {
        return _LeaveCard(card: cards[index], actionable: approveEnabled);
      },
    );
  }
}

final class _LeaveCard extends ConsumerWidget {
  const _LeaveCard({required this.card, required this.actionable});

  final LeaveCardData card;
  final bool actionable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final String statusLabel = switch (card.request.status) {
      LeaveStatus.pending => strings.tabPending,
      LeaveStatus.approved => strings.tabApproved,
      LeaveStatus.rejected => strings.tabRejected,
    };
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                InitialAvatar(name: card.employeeName, size: 44),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        card.employeeName,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        '${card.request.type} • ${card.rangeLabel}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                LeaveChip(
                  status: card.request.status,
                  label: statusLabel,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(card.request.reason),
            if (actionable) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _confirm(
                        context,
                        ref,
                        approve: false,
                      ),
                      child: Text(strings.reject),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _confirm(
                        context,
                        ref,
                        approve: true,
                      ),
                      child: Text(strings.approve),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirm(
    BuildContext context,
    WidgetRef ref, {
    required bool approve,
  }) async {
    final AppLocalizations strings = AppLocalizations.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(approve ? strings.approveConfirm : strings.rejectConfirm),
          content: Text(
            '${card.employeeName} • ${card.request.type}\n${card.rangeLabel}',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(approve ? strings.approve : strings.reject),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await ref.read(leaveProvider.notifier).decide(card, approve: approve);
    }
  }
}
