import 'dart:convert';

import 'package:flutter/services.dart';

import '../config.dart';
import 'markdown.dart';
import 'models.dart';

/// Loads courses, lessons and interview questions from bundled assets.
class ContentRepository {
  ContentRepository._(this.courses, this.interview, this._bundle);

  final List<Course> courses;
  final List<InterviewQuestion> interview;
  final AssetBundle _bundle;
  final Map<String, Lesson> _cache = {};

  static Future<ContentRepository> load([AssetBundle? bundle]) async {
    final b = bundle ?? rootBundle;
    final courses = <Course>[];
    for (final id in AppConfig.courses) {
      final json = jsonDecode(await b.loadString('assets/lessons/$id/curriculum.json')) as Map<String, dynamic>;
      courses.add(Course(
        id: id,
        title: json['title'] as String,
        tagline: json['tagline'] as String? ?? '',
        modules: [
          for (final m in json['modules'] as List)
            Module(
              id: m['id'] as String,
              title: m['title'] as String,
              description: m['description'] as String? ?? '',
              level: Level.parse(m['level'] as String?),
              icon: iconNamed(m['icon'] as String? ?? ''),
              color: colorFromHex(m['color'] as String? ?? '#888888'),
              lessons: [
                for (final l in m['lessons'] as List)
                  LessonInfo(
                    slug: l['slug'] as String,
                    title: l['title'] as String,
                    summary: l['summary'] as String? ?? '',
                    minutes: l['minutes'] as int? ?? 5,
                    questions: l['questions'] as int? ?? 0,
                    courseId: id,
                    moduleId: m['id'] as String,
                  ),
              ],
            ),
        ],
      ));
    }

    var interview = <InterviewQuestion>[];
    try {
      final raw = jsonDecode(await b.loadString(AppConfig.interviewAsset)) as List;
      interview = [
        for (final q in raw)
          InterviewQuestion(
            id: q['id'] as String,
            category: q['category'] as String,
            level: Level.parse(q['level'] as String?),
            question: q['q'] as String,
            answer: parseBlocks(q['a'] as String),
          ),
      ];
    } catch (_) {
      // No interview asset bundled: the Interview tab is hidden.
    }

    return ContentRepository._(courses, interview, b);
  }

  List<LessonInfo> get allLessons => [for (final c in courses) ...c.lessons];

  LessonInfo? info(String id) => allLessons.where((l) => l.id == id).firstOrNull;

  Course courseOf(LessonInfo l) => courses.firstWhere((c) => c.id == l.courseId);

  Module moduleOf(LessonInfo l) => courseOf(l).modules.firstWhere((m) => m.id == l.moduleId);

  LessonInfo? next(LessonInfo l) {
    final all = allLessons;
    final i = all.indexWhere((x) => x.id == l.id);
    return i >= 0 && i + 1 < all.length ? all[i + 1] : null;
  }

  LessonInfo? previous(LessonInfo l) {
    final all = allLessons;
    final i = all.indexWhere((x) => x.id == l.id);
    return i > 0 ? all[i - 1] : null;
  }

  Future<Lesson> lesson(LessonInfo info) async {
    final cached = _cache[info.id];
    if (cached != null) return cached;
    final raw = await _bundle.loadString('assets/lessons/${info.courseId}/${info.slug}.md');
    final parsed = parseLesson(raw);
    return _cache[info.id] = Lesson(info: info, blocks: parsed.blocks, quiz: parsed.quiz);
  }

  /// All quiz questions (loads every lesson once).
  Future<List<(LessonInfo, QuizQuestion)>> allQuestions([Iterable<LessonInfo>? from]) async {
    final out = <(LessonInfo, QuizQuestion)>[];
    for (final info in from ?? allLessons) {
      for (final q in (await lesson(info)).quiz) {
        out.add((info, q));
      }
    }
    return out;
  }

  /// Search titles, summaries and bodies.
  Future<List<LessonInfo>> search(String term) async {
    final t = term.trim().toLowerCase();
    if (t.isEmpty) return [];
    final out = <LessonInfo>[];
    for (final info in allLessons) {
      final body = await _bundle.loadString('assets/lessons/${info.courseId}/${info.slug}.md');
      if ('${info.title} ${info.summary} $body'.toLowerCase().contains(t)) out.add(info);
    }
    return out;
  }
}
