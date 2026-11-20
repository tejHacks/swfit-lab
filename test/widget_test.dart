import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swift_lab/content/markdown.dart';
import 'package:swift_lab/content/models.dart';
import 'package:swift_lab/content/repository.dart';
import 'package:swift_lab/main.dart';
import 'package:swift_lab/state/progress.dart';
import 'package:swift_lab/ui/blocks_view.dart';
import 'package:swift_lab/ui/interview_screen.dart';
import 'package:swift_lab/ui/lesson_screen.dart';
import 'package:swift_lab/ui/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<(ContentRepository, Progress)> setup() async {
  SharedPreferences.setMockInitialValues({});
  final content = await ContentRepository.load();
  return (content, await Progress.load(content));
}

Future<void> loadRealFonts() async {
  final dir = '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts';
  final roboto = FontLoader('Roboto');
  for (final f in ['Regular', 'Medium', 'Bold', 'Black', 'Italic']) {
    final file = File('$dir/Roboto-$f.ttf');
    if (file.existsSync()) roboto.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
  }
  await roboto.load();
  final icons = FontLoader('MaterialIcons');
  final iconFile = File('$dir/MaterialIcons-Regular.otf');
  if (iconFile.existsSync()) icons.addFont(Future.value(ByteData.sublistView(iconFile.readAsBytesSync())));
  await icons.load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Content', () {
    test('every lesson parses fully, with valid quizzes', () async {
      final (content, _) = await setup();
      expect(content.allLessons, isNotEmpty);
      for (final info in content.allLessons) {
        final lesson = await content.lesson(info);
        expect(lesson.blocks, isNotEmpty, reason: info.id);
        expect(lesson.quiz.length, info.questions, reason: '${info.id} quiz count');
        for (final q in lesson.quiz) {
          expect(q.answer, inInclusiveRange(0, q.options.length - 1), reason: info.id);
        }
        void check(List<Block> blocks) {
          for (final b in blocks) {
            switch (b) {
              case ParagraphBlock(:final text):
                expect(text.contains(':::') || text.contains('```'), isFalse, reason: '${info.id}: $text');
              case CalloutBlock(:final children):
                check(children);
              default:
            }
          }
        }

        check(lesson.blocks);
      }
    });

    test('markdown parser handles every block type', () {
      final parsed = parseLesson('''---
title: T
summary: S
minutes: 3
---
# Heading

Some **bold** and `code` text
continuing here.

- one
- two

1. first
2. second

| A | B |
|---|---|
| 1 | 2 |

:::tip
Inside a **tip**.

```php
echo 1;
```
:::

```php
\$x = 1;
```

```quiz
[{"q": "Q?", "options": ["a", "b"], "answer": 1, "why": "because"}]
```
''');
      expect(parsed.meta['title'], 'T');
      expect(parsed.quiz.single.answer, 1);
      final types = parsed.blocks.map((b) => b.runtimeType).toList();
      expect(types, [HeadingBlock, ParagraphBlock, ListBlock, ListBlock, TableBlock, CalloutBlock, CodeBlock]);
      expect((parsed.blocks[1] as ParagraphBlock).text, 'Some **bold** and `code` text continuing here.');
      expect((parsed.blocks[3] as ListBlock).ordered, isTrue);
      expect((parsed.blocks[5] as CalloutBlock).children.length, 2);
      expect(parseInline('a `b` **c** [d](e)').map((t) => t.text), ['a ', 'b', ' ', 'c', ' ', 'd']);
    });
  });

  testWidgets('app starts and shows the learning path', (tester) async {
    final (_, progress) = (await tester.runAsync(setup))!;
    await tester.pumpWidget(ProgressScope(progress: progress, child: const LabApp()));
    await tester.pumpAndSettle();
    expect(find.text('START HERE'), findsOneWidget);
    for (final tab in ['Practice', 'Me', 'Learn']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: tab);
    }
  });

  for (final scale in [1.0, 1.3]) {
    testWidgets('every lesson lays out cleanly on a small phone (text x$scale)', (tester) async {
      await loadRealFonts();
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final (content, progress) = (await tester.runAsync(setup))!;
      // Pre-load (and cache) every lesson with real I/O so screens render synchronously.
      await tester.runAsync(() async {
        for (final info in content.allLessons) {
          await content.lesson(info);
        }
      });
      final problems = <String>[];
      var rendered = 0;

      for (final info in content.allLessons) {
        await tester.pumpWidget(ProgressScope(
          progress: progress,
          child: MaterialApp(
            theme: buildTheme(Brightness.light).copyWith(
              textTheme: buildTheme(Brightness.light).textTheme.apply(fontFamily: 'Roboto'),
            ),
            home: MediaQuery(
              data: MediaQueryData(size: const Size(360, 740), textScaler: TextScaler.linear(scale)),
              child: LessonScreen(info: info),
            ),
          ),
        ));
        await tester.pump();
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsNothing, reason: '${info.id} still loading');
        expect(find.text('Mark complete & continue').evaluate().isNotEmpty || find.byType(ListView).evaluate().isNotEmpty,
            isTrue, reason: info.id);
        rendered++;
        final scrollable = find.byType(Scrollable).first;
        for (var i = 0; i < 100; i++) {
          final err = tester.takeException();
          if (err != null) problems.add('${info.id}: $err');
          final pos = tester.state<ScrollableState>(scrollable).position;
          if (pos.pixels >= pos.maxScrollExtent) break;
          pos.jumpTo((pos.pixels + 600).clamp(0, pos.maxScrollExtent));
          await tester.pump();
        }
        final err = tester.takeException();
        if (err != null) problems.add('${info.id}: $err');
      }
      await tester.pumpWidget(const SizedBox());
      expect(rendered, content.allLessons.length);
      expect(problems, isEmpty);
    });
  }

  test('interview questions are bundled and parse', () async {
    final (content, _) = await setup();
    expect(content.interview.length, greaterThanOrEqualTo(50));
    for (final q in content.interview) {
      expect(q.answer, isNotEmpty, reason: q.id);
    }
  });

  testWidgets('every interview answer lays out cleanly on a small phone', (tester) async {
    await loadRealFonts();
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final (content, progress) = (await tester.runAsync(setup))!;
    final problems = <String>[];
    for (final q in content.interview) {
      await tester.pumpWidget(ProgressScope(
        progress: progress,
        child: MaterialApp(
          theme: buildTheme(Brightness.dark).copyWith(
            textTheme: buildTheme(Brightness.dark).textTheme.apply(fontFamily: 'Roboto'),
          ),
          home: Scaffold(body: ListView(padding: const EdgeInsets.all(16), children: [BlocksView(q.answer)])),
        ),
      ));
      final err = tester.takeException();
      if (err != null) problems.add('${q.id}: $err');
    }
    await tester.pumpWidget(const SizedBox());
    expect(problems, isEmpty);
  });

  testWidgets('interview tab: filter, reveal, mark known, flashcards', (tester) async {
    final (content, progress) = (await tester.runAsync(setup))!;
    await tester.pumpWidget(ProgressScope(progress: progress, child: const LabApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Interview').last);
    await tester.pumpAndSettle();
    expect(find.text('Interview prep'), findsOneWidget);
    expect(find.byType(InterviewScreen), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Advanced'));
    await tester.pumpAndSettle();
    final first = content.interview.firstWhere((q) => q.level.name == 'advanced');
    await tester.scrollUntilVisible(find.text(first.question), 300, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text(first.question));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('I know this'), 300, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('I know this'));
    await tester.pumpAndSettle();
    expect(progress.isKnown(first.id), isTrue);
    expect(tester.takeException(), isNull);
  });
}
