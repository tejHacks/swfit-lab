import 'package:flutter/material.dart';

import '../config.dart';
import '../state/progress.dart';
import 'lesson_screen.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = ProgressScope.of(context);
    final content = p.content;
    final scheme = Theme.of(context).colorScheme;
    final minutes = content.allLessons.where((l) => p.isDone(l.id)).fold<int>(0, (s, l) => s + l.minutes);
    final bookmarks = content.allLessons.where((l) => p.isBookmarked(l.id)).toList();

    return SafeArea(
      bottom: false,
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), children: [
        Text('Me', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              SizedBox(
                width: 76,
                height: 76,
                child: Stack(fit: StackFit.expand, children: [
                  CircularProgressIndicator(value: p.overall, strokeWidth: 8, strokeCap: StrokeCap.round,
                      backgroundColor: scheme.surfaceContainerHighest),
                  Center(child: Text('${(p.overall * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w900))),
                ]),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _line(Icons.menu_book, '${p.doneCount} / ${content.allLessons.length} lessons'),
                  _line(Icons.timer_outlined, '~$minutes min studied'),
                  _line(Icons.local_fire_department, '${p.streak}-day streak'),
                  if (content.interview.isNotEmpty)
                    _line(Icons.work_outline, '${p.known.length} / ${content.interview.length} interview Qs'),
                ]),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        _title(context, 'Progress by course'),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(children: [
              for (final c in content.courses)
                for (final m in c.modules)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    child: Row(children: [
                      Icon(m.icon, size: 18, color: m.color),
                      const SizedBox(width: 10),
                      Expanded(flex: 3, child: Text(m.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: LinearProgressIndicator(
                          value: m.lessons.where((l) => p.isDone(l.id)).length / m.lessons.length,
                          minHeight: 6,
                          color: m.color,
                          backgroundColor: m.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ]),
                  ),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        _title(context, 'Bookmarks'),
        Card(
          child: bookmarks.isEmpty
              ? const ListTile(
                  leading: Icon(Icons.bookmark_border),
                  title: Text('No bookmarks yet'),
                  subtitle: Text('Tap the bookmark icon in a lesson to save it here.'),
                )
              : Column(children: [
                  for (final l in bookmarks)
                    ListTile(
                      leading: Icon(Icons.bookmark, color: content.moduleOf(l).color),
                      title: Text(l.title),
                      subtitle: Text(content.courseOf(l).title),
                      onTap: () => openLesson(context, l),
                    ),
                ]),
        ),
        const SizedBox(height: 16),
        _title(context, 'Settings'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('Theme', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.system, label: Text('System')),
                  ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                ],
                selected: {p.themeMode},
                onSelectionChanged: (s) => p.setThemeMode(s.first),
              ),
              const SizedBox(height: 14),
              Text('Text size: ${(p.textScale * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w700)),
              Slider(value: p.textScale, min: 0.85, max: 1.3, divisions: 9, onChanged: p.setTextScale),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: Icon(Icons.restart_alt, color: scheme.error),
            title: Text('Reset progress', style: TextStyle(color: scheme.error)),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset all progress?'),
                  content: const Text('This can\'t be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset')),
                  ],
                ),
              );
              if (ok == true) await p.reset();
            },
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text('${AppConfig.appName} v1.0 · works fully offline',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
        ),
      ]),
    );
  }

  static Widget _line(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Row(children: [Icon(icon, size: 16), const SizedBox(width: 6), Expanded(child: Text(text))]),
      );

  static Widget _title(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w800)),
      );
}
