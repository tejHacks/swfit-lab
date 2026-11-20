import 'package:flutter/material.dart';

enum Level {
  beginner('Beginner', Color(0xFF16A34A)),
  intermediate('Intermediate', Color(0xFFD97706)),
  advanced('Advanced', Color(0xFFDC2626));

  const Level(this.label, this.color);
  final String label;
  final Color color;

  static Level parse(String? s) =>
      Level.values.firstWhere((l) => l.name == s, orElse: () => Level.beginner);
}

class QuizQuestion {
  const QuizQuestion({required this.question, required this.options, required this.answer, required this.why});
  final String question;
  final List<String> options;
  final int answer;
  final String why;

  factory QuizQuestion.fromJson(Map<String, dynamic> j) => QuizQuestion(
        question: j['q'] as String,
        options: [for (final o in j['options'] as List) '$o'],
        answer: j['answer'] as int,
        why: j['why'] as String? ?? '',
      );
}

/// Lesson summary from curriculum.json (the body is loaded lazily).
class LessonInfo {
  const LessonInfo({
    required this.slug,
    required this.title,
    required this.summary,
    required this.minutes,
    required this.questions,
    required this.courseId,
    required this.moduleId,
  });

  final String slug;
  final String title;
  final String summary;
  final int minutes;
  final int questions;
  final String courseId;
  final String moduleId;

  /// Unique across courses.
  String get id => '$courseId/$slug';
}

class Module {
  const Module({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.icon,
    required this.color,
    required this.lessons,
  });

  final String id;
  final String title;
  final String description;
  final Level level;
  final IconData icon;
  final Color color;
  final List<LessonInfo> lessons;

  int get minutes => lessons.fold(0, (s, l) => s + l.minutes);
}

class Course {
  const Course({required this.id, required this.title, required this.tagline, required this.modules});
  final String id;
  final String title;
  final String tagline;
  final List<Module> modules;

  List<LessonInfo> get lessons => [for (final m in modules) ...m.lessons];
}

/// A fully loaded lesson.
class Lesson {
  const Lesson({required this.info, required this.blocks, required this.quiz});
  final LessonInfo info;
  final List<Block> blocks;
  final List<QuizQuestion> quiz;
}

/// An interview question with a Markdown answer.
class InterviewQuestion {
  const InterviewQuestion({
    required this.id,
    required this.category,
    required this.level,
    required this.question,
    required this.answer,
  });

  final String id;
  final String category;
  final Level level;
  final String question;
  final List<Block> answer;
}

// ---------------------------------------------------------------- Markdown blocks

sealed class Block {
  const Block();
}

class HeadingBlock extends Block {
  const HeadingBlock(this.level, this.text);
  final int level;
  final String text;
}

class ParagraphBlock extends Block {
  const ParagraphBlock(this.text);
  final String text;
}

class ListBlock extends Block {
  const ListBlock(this.items, {required this.ordered});
  final List<String> items;
  final bool ordered;
}

class CodeBlock extends Block {
  const CodeBlock(this.language, this.code);
  final String language;
  final String code;
}

class CalloutBlock extends Block {
  const CalloutBlock(this.kind, this.children);
  final String kind; // tip | note | warning | analogy
  final List<Block> children;
}

class TableBlock extends Block {
  const TableBlock(this.header, this.rows);
  final List<String> header;
  final List<List<String>> rows;
}

/// Maps the Material icon names used in curriculum.json to IconData.
IconData iconNamed(String name) => switch (name) {
      'rocket_launch' => Icons.rocket_launch_rounded,
      'alt_route' => Icons.alt_route_rounded,
      'web' => Icons.web_rounded,
      'storage' => Icons.storage_rounded,
      'fact_check' => Icons.fact_check_rounded,
      'lock' => Icons.lock_rounded,
      'construction' => Icons.construction_rounded,
      'hub' => Icons.hub_rounded,
      'api' => Icons.api_rounded,
      'key' => Icons.key_rounded,
      'workspace_premium' => Icons.workspace_premium_rounded,
      'settings_suggest' => Icons.settings_suggest_rounded,
      'auto_awesome' => Icons.auto_awesome_rounded,
      'code' => Icons.code_rounded,
      'data_object' => Icons.data_object_rounded,
      'category' => Icons.category_rounded,
      'account_tree' => Icons.account_tree_rounded,
      'bolt' => Icons.bolt_rounded,
      'phone_iphone' => Icons.phone_iphone_rounded,
      'layers' => Icons.layers_rounded,
      'sync' => Icons.sync_rounded,
      'memory' => Icons.memory_rounded,
      'science' => Icons.science_rounded,
      'school' => Icons.school_rounded,
      'swap_horiz' => Icons.swap_horiz_rounded,
      'extension' => Icons.extension_rounded,
      _ => Icons.menu_book_rounded,
    };

Color colorFromHex(String hex) {
  final h = hex.replaceFirst('#', '');
  return Color(int.parse(h.length == 6 ? 'FF$h' : h, radix: 16));
}
