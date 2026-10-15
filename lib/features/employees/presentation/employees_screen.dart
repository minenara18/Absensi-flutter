import 'package:absensi_dashboard/core/failures.dart';
import 'package:absensi_dashboard/data/models.dart';
import 'package:absensi_dashboard/features/employees/presentation/employees_notifier.dart';
import 'package:absensi_dashboard/l10n/gen/app_localizations.dart';
import 'package:absensi_dashboard/shared/widgets/chips.dart';
import 'package:absensi_dashboard/shared/widgets/state_views.dart';
import 'package:absensi_dashboard/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Employee directory with search. Watches one notifier.
final class EmployeesScreen extends ConsumerWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final AsyncValue<EmployeesState> state = ref.watch(employeesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.navEmployees)),
      floatingActionButton: Semantics(
        button: true,
        label: strings.addEmployee,
        child: FloatingActionButton(
          onPressed: () => context.push('/employees/new'),
          child: const ExcludeSemantics(
            child: Icon(Icons.person_add_alt_rounded),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(employeesProvider.notifier).refresh(),
          child: _EmployeesBody(state: state),
        ),
      ),
    );
  }
}

final class _EmployeesBody extends ConsumerWidget {
  const _EmployeesBody({required this.state});

  final AsyncValue<EmployeesState> state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context);
    switch (state) {
      case AsyncLoading<EmployeesState>(:final bool hasValue):
        final EmployeesState? previous = state.value;
        if (hasValue && previous != null) {
          return _ListContent(data: previous);
        }
        return const SingleChildScrollView(
          padding: EdgeInsetsDirectional.all(AppSpacing.md),
          child: LoadingList(rows: 6),
        );
      case AsyncError<EmployeesState>():
        return ErrorView(
          title: strings.errorTitle,
          message: strings.errorUnknown,
          retryLabel: strings.retry,
          onRetry: () => ref.invalidate(employeesProvider),
        );
      case AsyncData<EmployeesState>(:final EmployeesState value):
        if (value.failure != null && value.staff.isEmpty) {
          return ErrorView(
            title: strings.errorTitle,
            message: messageForFailure(value.failure!, strings),
            retryLabel: strings.retry,
            onRetry: () => ref.invalidate(employeesProvider),
          );
        }
        if (value.staff.isEmpty) {
          return EmptyView(
            icon: Icons.group_outlined,
            title: strings.emptyTitle,
            body: strings.emptyBody,
            actionLabel: strings.addEmployee,
            onAction: () => context.push('/employees/new'),
          );
        }
        if (value.visible.isEmpty) {
          return Column(
            children: <Widget>[
              _SearchBar(query: value.query),
              Expanded(
                child: EmptyView(
                  icon: Icons.search_off_rounded,
                  title: strings.noResultTitle,
                  body: strings.noResultBody,
                  actionLabel: strings.resetFilter,
                  onAction: () =>
                      ref.read(employeesProvider.notifier).setQuery(''),
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

  final EmployeesState data;

  @override
  Widget build(BuildContext context) {
    final List<Employee> rows = data.visible;
    return ListView.builder(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      itemCount: rows.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return _SearchBar(query: data.query);
        }
        return _EmployeeTile(employee: rows[index - 1]);
      },
    );
  }
}

final class _SearchBar extends ConsumerWidget {
  const _SearchBar({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
      child: TextField(
        key: const ValueKey<String>('employees-search'),
        decoration: InputDecoration(
          hintText: strings.searchHint,
          prefixIcon: const Icon(Icons.search_rounded),
        ),
        textInputAction: TextInputAction.search,
        onChanged: (String value) =>
            ref.read(employeesProvider.notifier).setQuery(value),
      ),
    );
  }
}

final class _EmployeeTile extends StatelessWidget {
  const _EmployeeTile({required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/employees/${employee.id}'),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
          child: Row(
            children: <Widget>[
              InitialAvatar(name: employee.name),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      employee.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${employee.position} • ${employee.department}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _ActiveDot(active: employee.active),
            ],
          ),
        ),
      ),
    );
  }
}

/// Active indicator: color + icon + text.
final class _ActiveDot extends StatelessWidget {
  const _ActiveDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final Color color = active
        ? AppTokens.of(context).success
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Semantics(
      label: active ? strings.active : strings.inactive,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ExcludeSemantics(
            child: Icon(
              active ? Icons.check_circle_rounded : Icons.remove_circle_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            active ? strings.active : strings.inactive,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
