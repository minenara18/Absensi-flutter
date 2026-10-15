import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shortcut catalogue + favorites state (persisted in-memory for now).
enum QaCategory { attendance, employee, report, system }

/// Catalogue entry. Navigation target is a route string; empty means
/// the "more" tile that opens the full sheet.
@immutable
final class QaItem {
  const QaItem({
    required this.id,
    required this.icon,
    required this.route,
    required this.category,
  });

  final String id;
  final IconData icon;
  final String route;
  final QaCategory category;
}

@immutable
final class QaCatalogue {
  static const List<QaItem> items = <QaItem>[
    QaItem(
      id: 'today',
      icon: Icons.fact_check_rounded,
      route: '/attendance',
      category: QaCategory.attendance,
    ),
    QaItem(
      id: 'add',
      icon: Icons.person_add_alt_rounded,
      route: '/employees/new',
      category: QaCategory.employee,
    ),
    QaItem(
      id: 'approvals',
      icon: Icons.approval_rounded,
      route: '/leave',
      category: QaCategory.attendance,
    ),
    QaItem(
      id: 'overtime',
      icon: Icons.more_time_rounded,
      route: '/soon/overtime',
      category: QaCategory.attendance,
    ),
    QaItem(
      id: 'schedule',
      icon: Icons.calendar_month_rounded,
      route: '/soon/schedule',
      category: QaCategory.employee,
    ),
    QaItem(
      id: 'monthly',
      icon: Icons.bar_chart_rounded,
      route: '/reports',
      category: QaCategory.report,
    ),
    QaItem(
      id: 'export',
      icon: Icons.ios_share_rounded,
      route: '/reports',
      category: QaCategory.report,
    ),
    QaItem(
      id: 'location',
      icon: Icons.location_on_rounded,
      route: '/soon/location',
      category: QaCategory.system,
    ),
  ];

  static QaItem byId(String id) {
    return items.firstWhere(
      (QaItem e) => e.id == id,
      orElse: () => items.first,
    );
  }
}

/// Favorites state: ordered ids + whether edit sheet is open.
@immutable
final class QuickAccessState {
  const QuickAccessState({
    this.favorites = const <String>[
      'today',
      'approvals',
      'add',
      'monthly',
      'export',
      'schedule',
      'overtime',
    ],
    this.editing = false,
  });

  final List<String> favorites;
  final bool editing;

  QuickAccessState copyWith({List<String>? favorites, bool? editing}) {
    return QuickAccessState(
      favorites: favorites ?? this.favorites,
      editing: editing ?? this.editing,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuickAccessState &&
          other.editing == editing &&
          _listEquals(other.favorites, favorites));

  @override
  int get hashCode => Object.hash(Object.hashAll(favorites), editing);

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}

final class QuickAccessNotifier extends Notifier<QuickAccessState> {
  @override
  QuickAccessState build() => const QuickAccessState();

  void setEditing({required bool value}) {
    state = state.copyWith(editing: value);
  }

  void toggle(String id) {
    final List<String> next = List<String>.of(state.favorites);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = state.copyWith(favorites: next);
  }

  void move(String id, int delta) {
    final List<String> next = List<String>.of(state.favorites);
    final int index = next.indexOf(id);
    final int target = index + delta;
    if (index < 0 || target < 0 || target >= next.length) {
      return;
    }
    next
      ..removeAt(index)
      ..insert(target, id);
    state = state.copyWith(favorites: next);
  }
}

final NotifierProvider<QuickAccessNotifier, QuickAccessState>
quickAccessProvider = NotifierProvider<QuickAccessNotifier, QuickAccessState>(
  QuickAccessNotifier.new,
);
