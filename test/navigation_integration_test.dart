import 'package:bhagavadgita_book/data/local/app_database.dart';
import 'package:bhagavadgita_book/features/contents/contents_screen.dart';
import 'package:bhagavadgita_book/features/search/search_screen.dart';
import 'package:bhagavadgita_book/l10n/gen/app_localizations.dart';
import 'package:bhagavadgita_book/ui/theme/app_theme.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget-test-only screens (Contents, Bookmarks, Search) — deliberately
/// excludes the Reader/Note flow, which wraps `AudioControllerScope` and
/// triggers real `just_audio` platform-channel calls on first build; that
/// flow is covered by the manual verification pass (Task 4.3) instead,
/// where real device/audio behavior is the right thing to check anyway.
Future<AppDatabase> _seededDb() async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  await db
      .into(db.languages)
      .insert(const LanguagesCompanion(id: Value(1), code: Value('en')));
  await db
      .into(db.books)
      .insert(
        const BooksCompanion(
          id: Value(1),
          languageId: Value(1),
          name: Value('Default Edition'),
        ),
      );
  await db
      .into(db.chapters)
      .insert(
        const ChaptersCompanion(
          id: Value(1),
          bookId: Value(1),
          name: Value('Arjuna Vishada Yoga'),
          position: Value(1),
        ),
      );
  await db
      .into(db.slokas)
      .insert(
        const SlokasCompanion(
          id: Value(1),
          chapterId: Value(1),
          name: Value('1.1'),
          slokaText: Value('dharma ksetre'),
          translation: Value('On the field of dharma, what happened?'),
          position: Value(1),
        ),
      );
  return db;
}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: buildAppTheme(),
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: child,
  );
}

void main() {
  testWidgets('Contents -> Bookmarks icon reaches Bookmarks and back', (
    tester,
  ) async {
    // Default test viewport (800x600) is >= the 720px tablet breakpoint,
    // which would render TabletContentsChapterScaffold instead of the
    // phone screen under test — force a phone-sized viewport.
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final db = await _seededDb();
    await tester.pumpWidget(_wrap(ContentsScreen(db: db)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.contentsTitle), findsOneWidget);

    await tester.tap(find.byTooltip(l10n.bookmarksTitle));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.bookmarksTitle), findsOneWidget);

    await tester.pageBack();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(l10n.contentsTitle), findsOneWidget);

    await db.close();
  });

  testWidgets('Search live-filters as the user types and shows empty state', (
    tester,
  ) async {
    final db = await _seededDb();
    await tester.pumpWidget(_wrap(SearchScreen(db: db)));
    await tester.pumpAndSettle();

    // No query yet -> the seeded verse is listed (unfiltered browse state).
    expect(find.textContaining('1.1'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'dharma');
    await tester.pumpAndSettle();
    expect(find.textContaining('1.1'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'nonexistent-xyz');
    await tester.pumpAndSettle();
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.searchNotFound), findsOneWidget);

    await db.close();
  });
}
