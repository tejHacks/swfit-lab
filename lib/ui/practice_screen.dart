import 'dart:math';

import 'package:flutter/material.dart';

import '../content/models.dart';
import '../state/progress.dart';
import 'quiz_card.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  Future<void> _start(BuildContext context, String title, Iterable<LessonInfo>? from, {int count = 10}) async {
    final content = ProgressScope.read(context).content;
    final all = await content.allQuestions(from);
    if (!context.mounted) return;
    if (all.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No questions here yet.')));
      return;
    }
    all.shuffle(Random());
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => QuizSession(title: title, questions: [for (final (_, q) in all.take(count)) q]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = ProgressScope.of(context);
    final content = p.content;
    final scheme = Theme.of(context).colorScheme;
    final accuracy = p.answered == 0 ? 0 : (p.correct / p.answered * 100).round();
    final completed = content.allLessons.where((l) => p.isDone(l.id)).toList();

    return SafeArea(
      bottom: false,
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
        Text('Practice', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w900)),
        Text('Short quizzes make knowledge stick.', style: TextStyle(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 14),
        Row(children: [
          _Stat('${p.answered}', 'Answered', Icons.quiz, const Color(0xFF2563EB)),
          const SizedBox(width: 10),
          _Stat('$accuracy%', 'Accuracy', Icons.track_changes, const Color(0xFF16A34A)),
          const SizedBox(width: 10),
          _Stat('${p.doneCount}', 'Lessons', Icons.menu_book, const Color(0xFF7C3AED)),
        ]),
        const SizedBox(height: 14),
        _Big(
          title: 'Quick quiz',
          subtitle: '10 random questions from everything',
          icon: Icons.bolt,
          colors: const [Color(0xFFFF8A00), Color(0xFFE52E71)],
          onTap: () => _start(context, 'Quick quiz', null),
        ),
        const SizedBox(height: 10),
        _Big(
          title: 'Review what you learned',
          subtitle: completed.isEmpty ? 'Complete a lesson first' : 'Questions from ${completed.length} completed lessons',
          icon: Icons.replay,
          colors: const [Color(0xFF2563EB), Color(0xFF06B6D4)],
          onTap: completed.isEmpty ? null : () => _start(context, 'Review', completed, count: 15),
        ),
        const SizedBox(height: 20),
        Text('Quiz by module', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        for (final course in content.courses)
          for (final m in course.modules)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  leading: Icon(m.icon, color: m.color),
                  title: Text(m.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${content.courses.length > 1 ? '${course.title} · ' : ''}'
                      '${m.lessons.fold<int>(0, (s, l) => s + l.questions)} questions'),
                  trailing: const Icon(Icons.play_circle_outline),
                  onTap: () => _start(context, m.title, m.lessons, count: 12),
                ),
              ),
            ),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label, this.icon, this.color);
  final String value, label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 6),
              FittedBox(child: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
              Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ]),
          ),
        ),
      );
}

class _Big extends StatelessWidget {
  const _Big({required this.title, required this.subtitle, required this.icon, required this.colors, this.onTap});
  final String title, subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Material(
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(gradient: LinearGradient(colors: colors)),
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(children: [
                  Icon(icon, color: Colors.white, size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                      Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.9))),
                    ]),
                  ),
                  const Icon(Icons.arrow_forward, color: Colors.white),
                ]),
              ),
            ),
          ),
        ),
      );
}

class QuizSession extends StatefulWidget {
  const QuizSession({super.key, required this.title, required this.questions});
  final String title;
  final List<QuizQuestion> questions;
  @override
  State<QuizSession> createState() => _QuizSessionState();
}

class _QuizSessionState extends State<QuizSession> {
  int _i = 0, _score = 0;
  bool _answered = false;

  @override
  Widget build(BuildContext context) {
    final total = widget.questions.length;
    final finished = _i >= total;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: finished ? 1 : _i / total, minHeight: 4),
        ),
      ),
      body: SafeArea(
        child: finished
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(_score / total >= 0.8 ? '🏆' : _score / total >= 0.5 ? '💪' : '📚', style: const TextStyle(fontSize: 70)),
                    Text('$_score / $total',
                        style: Theme.of(context).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text(
                      _score / total >= 0.8
                          ? 'Excellent! You really know this.'
                          : _score / total >= 0.5
                              ? 'Good effort. Review the lessons you missed.'
                              : 'Keep going: re-read the lessons, then try again.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
                  ]),
                ),
              )
            : ListView(padding: const EdgeInsets.all(16), children: [
                Text('Question ${_i + 1} of $total · score $_score', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                QuizCard(
                  key: ValueKey(_i),
                  question: widget.questions[_i],
                  onAnswered: (ok) => setState(() {
                    if (ok && !_answered) _score++;
                    _answered = true;
                  }),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  onPressed: _answered
                      ? () => setState(() {
                            _i++;
                            _answered = false;
                          })
                      : null,
                  child: Text(_i == total - 1 ? 'See results' : 'Next question'),
                ),
              ]),
      ),
    );
  }
}
