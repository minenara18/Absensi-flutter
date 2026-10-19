import 'package:flutter/material.dart';

/// Single source of truth for every color used in the app.
///
/// Both schemes are hand-written (no `ColorScheme.fromSeed`).
/// Nothing outside `lib/theme/` may use hex literals or `Colors.*`.
abstract final class AppPalette {
  // Brand
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryDark = Color(0xFF4338CA);
  static const Color primarySoftLight = Color(0xFFEEF0FE);
  static const Color primarySoftDark = Color(0xFF26235E);

  // Status
  static const Color present = Color(0xFF0E9F6E);
  static const Color late = Color(0xFFD97706);
  static const Color leave = Color(0xFFEA580C);
  static const Color absent = Color(0xFFE02424);
  static const Color info = Color(0xFF1C64F2);

  // Surfaces
  static const Color backgroundLight = Color(0xFFF6F7FB);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF11131A);
  static const Color cardDark = Color(0xFF1B1E28);
  static const Color surfaceContainerLight = Color(0xFFF2F4FA);
  static const Color surfaceContainerDark = Color(0xFF232633);

  // Text
  static const Color inkLight = Color(0xFF17182B);
  static const Color inkSoftLight = Color(0xFF5B5D72);
  static const Color lineLight = Color(0xFFE6E8F0);
  static const Color inkDark = Color(0xFFF2F3F8);
  static const Color inkSoftDark = Color(0xFFA7AABF);
  static const Color lineDark = Color(0xFF2A2E3D);
}

/// Spacing rhythm 4/8/12/16/24 (+32/40 for large gaps).
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
}

/// Corner radii (large, friendly).
abstract final class AppRadius {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double pill = 999;
}

/// Animation durations. All animations collapse to zero when
/// reduce-motion is enabled (see [AppDurations.of]).
abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 300);

  static Duration of(BuildContext context, Duration value) {
    return MediaQuery.of(context).disableAnimations ? Duration.zero : value;
  }
}

/// Type sizes. Only referenced from `lib/theme/`.
abstract final class AppFontSize {
  static const double caption = 12;
  static const double body = 14;
  static const double titleSmall = 16;
  static const double title = 20;
  static const double headline = 24;
  static const double display = 32;
}

/// Elevation + shadow tokens (very subtle).
abstract final class AppElevation {
  static const double card = 2;
}

/// Breakpoints chosen from constraints, never from platform.
abstract final class AppBreakpoints {
  static const double compactMax = 600;
  static const double mediumMax = 840;
}

/// Touch target minimum.
abstract final class AppTouch {
  static const double minTarget = 44;
}

/// ThemeExtension exposing tokens to widgets via `AppTokens.of(context)`.
@immutable
final class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.success,
    required this.warning,
    required this.leave,
    required this.danger,
    required this.info,
    required this.card,
    required this.softTint,
    required this.avatarBackgrounds,
    required this.zebraSurface,
  });

  const AppTokens.fallback()
    : success = AppPalette.present,
      warning = AppPalette.late,
      leave = AppPalette.leave,
      danger = AppPalette.absent,
      info = AppPalette.info,
      card = AppPalette.cardLight,
      softTint = AppPalette.primarySoftLight,
      avatarBackgrounds = const <Color>[
        Color(0xFFDDD6FE),
        Color(0xFFBFDBFE),
        Color(0xFFA7F3D0),
        Color(0xFFFDE68A),
        Color(0xFFFBCFE8),
        Color(0xFFBAE6FD),
      ],
      zebraSurface = AppPalette.surfaceContainerLight;

  final Color success;
  final Color warning;
  final Color leave;
  final Color danger;
  final Color info;
  final Color card;
  final Color softTint;
  final List<Color> avatarBackgrounds;
  final Color zebraSurface;

  static AppTokens of(BuildContext context) {
    final AppTokens? tokens = Theme.of(context).extension<AppTokens>();
    assert(tokens != null, 'AppTokens missing. Did you use AppTheme?');
    return tokens ?? const AppTokens.fallback();
  }

  @override
  AppTokens copyWith({
    Color? success,
    Color? warning,
    Color? leave,
    Color? danger,
    Color? info,
    Color? card,
    Color? softTint,
    List<Color>? avatarBackgrounds,
    Color? zebraSurface,
  }) {
    return AppTokens(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      leave: leave ?? this.leave,
      danger: danger ?? this.danger,
      info: info ?? this.info,
      card: card ?? this.card,
      softTint: softTint ?? this.softTint,
      avatarBackgrounds: avatarBackgrounds ?? this.avatarBackgrounds,
      zebraSurface: zebraSurface ?? this.zebraSurface,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) {
      return this;
    }
    Color lerpColor(Color a, Color b) => Color.lerp(a, b, t) ?? a;
    return AppTokens(
      success: lerpColor(success, other.success),
      warning: lerpColor(warning, other.warning),
      leave: lerpColor(leave, other.leave),
      danger: lerpColor(danger, other.danger),
      info: lerpColor(info, other.info),
      card: lerpColor(card, other.card),
      softTint: lerpColor(softTint, other.softTint),
      avatarBackgrounds: avatarBackgrounds,
      zebraSurface: lerpColor(zebraSurface, other.zebraSurface),
    );
  }
}
