/// Pure helpers shared across features. No BuildContext here.
extension StringX on String {
  /// Initials of up to two words, e.g. 'Rina Wijaya' -> 'RW'.
  String get initials {
    final List<String> parts = trim()
        .split(RegExp(r'\s+'))
        .where((String s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return '?';
    }
    final String first = parts.first.substring(0, 1).toUpperCase();
    if (parts.length == 1) {
      return first;
    }
    return '$first${parts[1].substring(0, 1).toUpperCase()}';
  }
}

/// Pure attendance math, unit-tested.
abstract final class AttendanceMath {
  /// Percentage of [part] over [total], 0 when [total] is 0.
  static double percent(int part, int total) {
    if (total <= 0 || part <= 0) {
      return 0;
    }
    return (part / total * 100).clamp(0, 100).toDouble();
  }

  /// Formats a [Duration] as `7j 32m` style (Indonesian abbreviations).
  static String formatDuration(Duration duration, {required bool indonesian}) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    if (indonesian) {
      if (hours <= 0) {
        return '$minutes mnt';
      }
      return '$hours jam $minutes mnt';
    }
    if (hours <= 0) {
      return '${minutes}min';
    }
    return '${hours}h ${minutes}min';
  }
}
