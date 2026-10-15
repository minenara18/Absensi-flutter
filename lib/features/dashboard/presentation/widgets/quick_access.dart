import 'dart:async';
import 'package:absensi_dashboard/features/dashboard/presentation/quick_access_notifier.dart';
import 'package:absensi_dashboard/l10n/gen/app_localizations.dart';
import 'package:absensi_dashboard/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Localized label for a catalogue id.
String qaLabel(String id, AppLocalizations strings) {
  switch (id) {
    case 'today':
      return strings.qaToday;
    case 'add':
      return strings.qaAddEmployee;
    case 'approvals':
      return strings.qaApprovals;
    case 'overtime':
      return strings.qaOvertime;
    case 'schedule':
      return strings.qaSchedule;
    case 'monthly':
      return strings.qaMonthly;
    case 'export':
      return strings.qaExport;
    case 'location':
      return strings.qaLocation;
    default:
      return id;
  }
}

String qaCategoryLabel(QaCategory category, AppLocalizations strings) {
  switch (category) {
    case QaCategory.attendance:
      return strings.qaCategoryAttendance;
    case QaCategory.employee:
      return strings.qaCategoryEmployee;
    case QaCategory.report:
      return strings.qaCategoryReport;
    case QaCategory.system:
      return strings.qaCategorySystem;
  }
}

/// Quick Access section: header + adaptive grid + "more" tile.
final class QuickAccessSection extends ConsumerWidget {
  const QuickAccessSection({super.key, required this.pendingCount});

  final int pendingCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final QuickAccessState state = ref.watch(quickAccessProvider);

    ref.listen<bool>(
      quickAccessProvider.select((QuickAccessState s) => s.editing),
      (bool? previous, bool editing) {
        if (editing) {
          unawaited(
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              builder: (BuildContext context) => const EditShortcutsSheet(),
            ).whenComplete(
              () => ref
                  .read(quickAccessProvider.notifier)
                  .setEditing(value: false),
            ),
          );
        }
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                strings.quickAccess,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton(
              onPressed: () => ref
                  .read(quickAccessProvider.notifier)
                  .setEditing(value: true),
              child: Text(strings.quickAccessEdit),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final int columns = (constraints.maxWidth / 150).floor().clamp(
              4,
              8,
            );
            const double spacing = AppSpacing.sm;
            final double tileWidth =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;
            final List<Widget> tiles = <Widget>[
              for (final String id in state.favorites)
                SizedBox(
                  width: tileWidth,
                  child: QuickAccessTile(
                    key: ValueKey<String>('qa-$id'),
                    itemId: id,
                    badgeCount: id == 'approvals' ? pendingCount : 0,
                  ),
                ),
              SizedBox(
                width: tileWidth,
                child: MoreTile(pendingCount: pendingCount),
              ),
            ];
            return Wrap(spacing: spacing, runSpacing: spacing, children: tiles);
          },
        ),
      ],
    );
  }
}

/// One shortcut tile: soft round icon + wrapping label + optional badge.
final class QuickAccessTile extends ConsumerWidget {
  const QuickAccessTile({
    super.key,
    required this.itemId,
    this.badgeCount = 0,
  });

  final String itemId;
  final int badgeCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final QaItem item = QaCatalogue.byId(itemId);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String label = qaLabel(itemId, strings);

    return Semantics(
      button: true,
      label: badgeCount > 0 ? '$label, $badgeCount' : label,
      child: InkWell(
        onTap: () {
          if (item.route.startsWith('/employees') ||
              item.route.startsWith('/leave') ||
              item.route.startsWith('/soon')) {
            unawaited(context.push(item.route));
          } else {
            context.go(item.route);
          }
        },
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppTouch.minTarget),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.xs),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(AppRadius.lg),
                        ),
                      ),
                      alignment: AlignmentDirectional.center,
                      child: ExcludeSemantics(
                        child: Icon(item.icon, color: scheme.primary),
                      ),
                    ),
                    if (badgeCount > 0)
                      PositionedDirectional(
                        end: -6,
                        top: -6,
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 22,
                            minHeight: 22,
                          ),
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: AppTokens.of(context).danger,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(AppRadius.pill),
                            ),
                          ),
                          alignment: AlignmentDirectional.center,
                          child: Text(
                            badgeCount > 99 ? '99+' : '$badgeCount',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: const Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Final tile opening the full catalogue sheet.
final class MoreTile extends StatelessWidget {
  const MoreTile({super.key, required this.pendingCount});

  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: strings.quickAccessAll,
      child: InkWell(
        onTap: () {
          unawaited(
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              builder: (BuildContext context) =>
                  AllShortcutsSheet(pendingCount: pendingCount),
            ),
          );
        },
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppTouch.minTarget),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.xs),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.25),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(AppRadius.lg),
                    ),
                  ),
                  alignment: AlignmentDirectional.center,
                  child: ExcludeSemantics(
                    child: Icon(
                      Icons.apps_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  strings.quickAccessAll,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Edit sheet: pick favorites and reorder them with focusable
/// up/down buttons (the accessible alternative to drag & drop).
final class EditShortcutsSheet extends ConsumerWidget {
  const EditShortcutsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final QuickAccessState state = ref.watch(quickAccessProvider);
    final QuickAccessNotifier notifier = ref.read(quickAccessProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    strings.qaEditTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    notifier.setEditing(value: false);
                    Navigator.of(context).pop();
                  },
                  child: Text(strings.quickAccessDone),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  for (int i = 0; i < state.favorites.length; i++)
                    _FavoriteRow(
                      key: ValueKey<String>('fav-${state.favorites[i]}'),
                      itemId: state.favorites[i],
                      isFirst: i == 0,
                      isLast: i == state.favorites.length - 1,
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final QaItem item in QaCatalogue.items)
                    if (!state.favorites.contains(item.id))
                      _CatalogueRow(
                        key: ValueKey<String>('add-${item.id}'),
                        item: item,
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

final class _FavoriteRow extends ConsumerWidget {
  const _FavoriteRow({
    super.key,
    required this.itemId,
    required this.isFirst,
    required this.isLast,
  });

  final String itemId;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final QaItem item = QaCatalogue.byId(itemId);
    final QuickAccessNotifier notifier = ref.read(quickAccessProvider.notifier);
    return Semantics(
      label: qaLabel(itemId, strings),
      child: Card(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          child: Row(
            children: <Widget>[
              ExcludeSemantics(child: Icon(item.icon)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(qaLabel(itemId, strings))),
              Semantics(
                button: true,
                label: strings.moveUp,
                excludeSemantics: true,
                child: IconButton(
                  icon: const Icon(Icons.arrow_upward_rounded),
                  onPressed: isFirst ? null : () => notifier.move(itemId, -1),
                ),
              ),
              Semantics(
                button: true,
                label: strings.moveDown,
                excludeSemantics: true,
                child: IconButton(
                  icon: const Icon(Icons.arrow_downward_rounded),
                  onPressed: isLast ? null : () => notifier.move(itemId, 1),
                ),
              ),
              Semantics(
                button: true,
                label: strings.toggleFavorite,
                excludeSemantics: true,
                child: Checkbox(
                  value: true,
                  onChanged: (_) => notifier.toggle(itemId),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _CatalogueRow extends ConsumerWidget {
  const _CatalogueRow({super.key, required this.item});

  final QaItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final QuickAccessNotifier notifier = ref.read(quickAccessProvider.notifier);
    return Semantics(
      label: qaLabel(item.id, strings),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        child: Row(
          children: <Widget>[
            ExcludeSemantics(child: Icon(item.icon)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(qaLabel(item.id, strings))),
            Semantics(
              button: true,
              label: strings.toggleFavorite,
              excludeSemantics: true,
              child: Checkbox(
                value: false,
                onChanged: (_) => notifier.toggle(item.id),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class AllShortcutsSheet extends ConsumerWidget {
  const AllShortcutsSheet({super.key, required this.pendingCount});

  final int pendingCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              strings.quickAccessSheetTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  for (final QaCategory category in QaCategory.values)
                    _CategoryBlock(
                      category: category,
                      pendingCount: pendingCount,
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(quickAccessProvider.notifier).setEditing(value: true);
              },
              child: Text(strings.quickAccessEdit),
            ),
          ],
        ),
      ),
    );
  }
}

final class _CategoryBlock extends StatelessWidget {
  const _CategoryBlock({required this.category, required this.pendingCount});

  final QaCategory category;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final List<QaItem> items = QaCatalogue.items
        .where((QaItem e) => e.category == category)
        .toList();
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            qaCategoryLabel(category, strings),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              const int columns = 4;
              const double spacing = AppSpacing.sm;
              final double tileWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: <Widget>[
                  for (final QaItem item in items)
                    SizedBox(
                      width: tileWidth,
                      child: QuickAccessTile(
                        key: ValueKey<String>('qa-all-${item.id}'),
                        itemId: item.id,
                        badgeCount: item.id == 'approvals' ? pendingCount : 0,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
