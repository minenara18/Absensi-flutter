import 'package:absensi_dashboard/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Hand-written light & dark schemes (no `ColorScheme.fromSeed`).
abstract final class AppTheme {
  static const String fontFamily = 'Plus Jakarta Sans';

  static ThemeData light() {
    const ColorScheme scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppPalette.primary,
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: AppPalette.primarySoftLight,
      onPrimaryContainer: AppPalette.primaryDark,
      secondary: Color(0xFF0E9F6E),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFDEF7EC),
      onSecondaryContainer: Color(0xFF03543F),
      tertiary: AppPalette.late,
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFFEF3C7),
      onTertiaryContainer: Color(0xFF92400E),
      error: AppPalette.absent,
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFDE8E8),
      onErrorContainer: Color(0xFF9B1C1C),
      surface: AppPalette.backgroundLight,
      onSurface: AppPalette.inkLight,
      surfaceContainerHighest: AppPalette.cardLight,
      onSurfaceVariant: AppPalette.inkSoftLight,
      outline: AppPalette.lineLight,
      outlineVariant: AppPalette.lineLight,
      shadow: Color(0x1A17182B),
      scrim: Color(0x9917182B),
      inverseSurface: AppPalette.inkLight,
      onInverseSurface: Color(0xFFFFFFFF),
      inversePrimary: Color(0xFFA5B4FC),
      surfaceTint: AppPalette.primary,
    );
    return _base(scheme, isDark: false);
  }

  static ThemeData dark() {
    const ColorScheme scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFA5B4FC),
      onPrimary: Color(0xFF1E1B4B),
      primaryContainer: AppPalette.primarySoftDark,
      onPrimaryContainer: Color(0xFFE0E7FF),
      secondary: Color(0xFF31C48D),
      onSecondary: Color(0xFF014737),
      secondaryContainer: Color(0xFF014737),
      onSecondaryContainer: Color(0xFFBCF0DA),
      tertiary: Color(0xFFFDBA74),
      onTertiary: Color(0xFF431407),
      tertiaryContainer: Color(0xFF7C2D12),
      onTertiaryContainer: Color(0xFFFFEDD5),
      error: Color(0xFFF98080),
      onError: Color(0xFF450A0A),
      errorContainer: Color(0xFF7F1D1D),
      onErrorContainer: Color(0xFFFECACA),
      surface: AppPalette.backgroundDark,
      onSurface: AppPalette.inkDark,
      surfaceContainerHighest: AppPalette.cardDark,
      onSurfaceVariant: AppPalette.inkSoftDark,
      outline: AppPalette.lineDark,
      outlineVariant: AppPalette.lineDark,
      shadow: Color(0x66000000),
      scrim: Color(0x99000000),
      inverseSurface: Color(0xFFF2F3F8),
      onInverseSurface: AppPalette.inkLight,
      inversePrimary: AppPalette.primary,
      surfaceTint: Color(0xFFA5B4FC),
    );
    return _base(scheme, isDark: true);
  }

  static ThemeData _base(ColorScheme scheme, {required bool isDark}) {
    TextTheme text(TextTheme base) => base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontFamily: fontFamily,
        fontSize: AppFontSize.display,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontFamily: fontFamily,
        fontSize: AppFontSize.headline,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontFamily: fontFamily,
        fontSize: AppFontSize.title,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontFamily: fontFamily,
        fontSize: AppFontSize.titleSmall,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontFamily: fontFamily,
        fontSize: AppFontSize.body,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontFamily: fontFamily,
        fontSize: AppFontSize.titleSmall,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontFamily: fontFamily,
        fontSize: AppFontSize.body,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontFamily: fontFamily,
        fontSize: AppFontSize.caption,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontFamily: fontFamily,
        fontSize: AppFontSize.body,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontFamily: fontFamily,
        fontSize: AppFontSize.caption,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontFamily: fontFamily,
        fontSize: AppFontSize.caption,
        fontWeight: FontWeight.w500,
      ),
    );

    final ThemeData base = isDark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      extensions: <ThemeExtension<dynamic>>[
        AppTokens(
          success: AppPalette.present,
          warning: AppPalette.late,
          leave: AppPalette.leave,
          danger: AppPalette.absent,
          info: AppPalette.info,
          card: isDark ? AppPalette.cardDark : AppPalette.cardLight,
          softTint: isDark
              ? AppPalette.primarySoftDark
              : AppPalette.primarySoftLight,
          avatarBackgrounds: const <Color>[
            Color(0xFFDDD6FE),
            Color(0xFFBFDBFE),
            Color(0xFFA7F3D0),
            Color(0xFFFDE68A),
            Color(0xFFFBCFE8),
            Color(0xFFBAE6FD),
          ],
          zebraSurface: isDark
              ? AppPalette.surfaceContainerDark
              : AppPalette.surfaceContainerLight,
        ),
      ],
      textTheme: text(base.textTheme),
      cardTheme: CardThemeData(
        color: isDark ? AppPalette.cardDark : AppPalette.cardLight,
        elevation: AppElevation.card,
        shadowColor: scheme.shadow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppPalette.cardDark : AppPalette.cardLight,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: const WidgetStatePropertyAll<TextStyle>(
          TextStyle(
            fontFamily: fontFamily,
            fontSize: AppFontSize.caption,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: isDark ? AppPalette.cardDark : AppPalette.cardLight,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.primary),
        selectedLabelTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: scheme.primary,
          fontSize: AppFontSize.caption,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: AppFontSize.caption,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? AppPalette.surfaceContainerDark
            : AppPalette.surfaceContainerLight,
        selectedColor: scheme.primaryContainer,
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: AppFontSize.caption,
          fontWeight: FontWeight.w600,
          color: scheme.onSurfaceVariant,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: AppFontSize.caption,
          fontWeight: FontWeight.w600,
          color: scheme.onPrimaryContainer,
        ),
        shape: const StadiumBorder(),
        side: BorderSide(color: scheme.outline),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.selected)) {
              return scheme.primaryContainer;
            }
            return isDark
                ? AppPalette.surfaceContainerDark
                : AppPalette.surfaceContainerLight;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.selected)) {
              return scheme.onPrimaryContainer;
            }
            return scheme.onSurfaceVariant;
          }),
          side: WidgetStateProperty.resolveWith<BorderSide?>(
            (Set<WidgetState> states) => BorderSide(color: scheme.outline),
          ),
          textStyle: const WidgetStatePropertyAll<TextStyle>(
            TextStyle(
              fontFamily: fontFamily,
              fontSize: AppFontSize.caption,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        selectedIcon: const Icon(Icons.check_rounded),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(AppTouch.minTarget, AppTouch.minTarget),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: AppFontSize.body,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(AppTouch.minTarget, AppTouch.minTarget),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: AppFontSize.body,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(AppTouch.minTarget, AppTouch.minTarget),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: AppFontSize.body,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppPalette.cardDark : AppPalette.cardLight,
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
          borderSide: BorderSide.none,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppPalette.cardDark : AppPalette.cardLight,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
    );
  }
}
