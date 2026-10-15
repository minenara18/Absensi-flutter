import 'package:absensi_dashboard/features/dashboard/presentation/widgets/quick_access.dart';
import 'package:absensi_dashboard/l10n/gen/app_localizations.dart';
import 'package:absensi_dashboard/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrapForTest(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('id'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: ListView(children: [child])),
  ),
);

void main() {
  group('QuickAccess', () {
    testWidgets('shows favorite tiles plus more tile', (tester) async {
      await tester.pumpWidget(
        wrapForTest(const QuickAccessSection(pendingCount: 3)),
      );
      await tester.pumpAndSettle();

      // 7 default favorites rendered as tiles.
      expect(find.byType(QuickAccessTile), findsNWidgets(7));
      expect(find.byType(MoreTile), findsOneWidget);
      // Badge with pending count on the approvals tile.
      expect(find.text('3'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('more tile opens the full catalogue sheet', (tester) async {
      await tester.pumpWidget(
        wrapForTest(const QuickAccessSection(pendingCount: 3)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(MoreTile));
      await tester.pumpAndSettle();

      expect(find.byType(AllShortcutsSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('edit mode opens sheet and toggles favorites', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapForTest(const QuickAccessSection(pendingCount: 0)),
      );
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(QuickAccessSection)),
      );
      await tester.tap(find.text(l10n.quickAccessEdit));
      await tester.pumpAndSettle();

      expect(find.byType(EditShortcutsSheet), findsOneWidget);

      // Remove the first favorite via its checkbox.
      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsWidgets);
      await tester.tap(checkboxes.first);
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.quickAccessDone));
      await tester.pumpAndSettle();

      // One tile fewer on the grid.
      expect(find.byType(QuickAccessTile), findsNWidgets(6));
      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow at large text scale', (tester) async {
      tester.binding.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(
        () => tester.binding.platformDispatcher.clearTextScaleFactorTestValue(),
      );

      await tester.pumpWidget(
        wrapForTest(const QuickAccessSection(pendingCount: 12)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
