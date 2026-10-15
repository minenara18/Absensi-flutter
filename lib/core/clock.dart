import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Single source of time for the app.
///
/// Widgets must never call `DateTime.now()` directly; they read
/// [clockProvider] (or receive pre-formatted strings from a Notifier).
final Provider<Clock> clockProvider = Provider<Clock>((Ref ref) {
  return const Clock();
});
