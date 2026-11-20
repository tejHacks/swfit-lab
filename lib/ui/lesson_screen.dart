import 'package:flutter/material.dart';

import '../content/models.dart';
import '../state/progress.dart';
import 'blocks_view.dart';
import 'quiz_card.dart';

void openLesson(BuildContext context, LessonInfo info, {bool replace = false}) {
  ProgressScope.read(context).opened(info.id);
  final route = MaterialPageRoute<void>(builder: (_) => LessonScreen(info: info));
  replace ? Navigator.of(context).pushReplacement(route) : Navigator.of(context).push(route);
}

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.info});
  final LessonInfo info;
  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final Future<Lesson> _lesson = ProgressScope.read(context).content.lesson(widget.info);

  void _complete() {
    final p = ProgressScope.read(context);
    p.setDone(widget.info.id, true);
    final next = p.content.next(widget.info);
    if (next != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('✅ ${widget.info.title} complete'), duration: const Duration(milliseconds: 1200)));
      openLesson(context, next, replace: true);
    } else {
      Navigator.of(context).pop();
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Text('🏆', style: TextStyle(fontSize: 46)),
          title: const Text('Course complete!'),
          content: const Text('Amazing work. Keep your knowledge sharp in the Practice tab.'),
          actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Let\'s go'))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = ProgressScope.of(context);
    final info = widget.info;
    final module = p.content.moduleOf(info);
    final next = p.content.next(info);
    final prev = p.content.previous(info);
    final done = p.isDone(info.id);
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(module.title.toUpperCase(),
              style: TextStyle(fontSize: 11, letterSpacing: 1, color: module.color, fontWeight: FontWeight.w800)),
          Text(p.content.courseOf(info).title, style: const TextStyle(fontSize: 15)),
        ]),
        actions: [
          IconButton(
            tooltip: p.isBookmarked(info.id) ? 'Remove bookmark' : 'Bookmark',
            icon: Icon(p.isBookmarked(info.id) ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () => p.toggleBookmark(info.id),
          ),
        ],
      ),
      body: FutureBuilder<Lesson>(
        future: _lesson,
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('Could not load lesson: ${snap.error}'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final lesson = snap.data!;
          return SafeArea(
            top: false,
            child: ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 32), children: [
              Text(info.title, style: t.headlineSmall!.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(info.summary, style: t.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 6, children: [
                Chip(avatar: const Icon(Icons.schedule, size: 16), label: Text('${info.minutes} min'), visualDensity: VisualDensity.compact),
                if (lesson.quiz.isNotEmpty)
                  Chip(
                      avatar: const Icon(Icons.quiz_outlined, size: 16),
                      label: Text('${lesson.quiz.length} questions'),
                      visualDensity: VisualDensity.compact),
                if (done)
                  const Chip(
                      avatar: Icon(Icons.check_circle, size: 16, color: Color(0xFF16A34A)),
                      label: Text('Completed'),
                      visualDensity: VisualDensity.compact),
              ]),
              const Divider(height: 28),
              BlocksView(lesson.blocks),
              if (lesson.quiz.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(children: [
                  Icon(Icons.psychology_alt_rounded, color: module.color),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Check your understanding', style: t.titleLarge!.copyWith(fontWeight: FontWeight.w800))),
                ]),
                const SizedBox(height: 10),
                for (var i = 0; i < lesson.quiz.length; i++) ...[
                  QuizCard(question: lesson.quiz[i], number: i + 1),
                  const SizedBox(height: 10),
                ],
              ],
              const SizedBox(height: 10),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: module.color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _complete,
                icon: Icon(next == null ? Icons.emoji_events : Icons.check_rounded),
                label: Text(next == null ? 'Finish' : (done ? 'Next lesson' : 'Mark complete & continue'),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 6),
              Row(children: [
                if (prev != null)
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => openLesson(context, prev, replace: true),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: Text(prev.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  )
                else
                  const Spacer(),
                if (done) TextButton(onPressed: () => p.setDone(info.id, false), child: const Text('Mark not done')),
              ]),
            ]),
          );
        },
      ),
    );
  }
}
