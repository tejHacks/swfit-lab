import 'package:flutter/material.dart';

import '../config.dart';
import '../content/models.dart';
import '../state/progress.dart';
import 'lesson_screen.dart';
import 'search_screen.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = ProgressScope.of(context);
    final content = p.content;
    final total = content.allLessons.length;
    final resume = (p.lastLesson != null && !p.isDone(p.lastLesson!) ? content.info(p.lastLesson!) : null) ??
        content.allLessons.where((l) => !p.isDone(l.id)).firstOrNull;
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(slivers: [
        SliverAppBar(
          floating: true,
          title: Row(children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppConfig.seed, borderRadius: BorderRadius.circular(8)),
              child: const Text(AppConfig.logoLetter, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: 10),
            const Flexible(child: Text(AppConfig.appName, overflow: TextOverflow.ellipsis)),
          ]),
          actions: [
            IconButton(
              tooltip: 'Search',
              icon: const Icon(Icons.search),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchScreen())),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  colors: [AppConfig.seed, Color.lerp(AppConfig.seed, Colors.black, 0.45)!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.doneCount == 0 ? 'Welcome! 👋' : 'Keep going! 💪',
                          style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(AppConfig.tagline, style: TextStyle(color: Colors.white.withValues(alpha: 0.85))),
                      const SizedBox(height: 8),
                      Text('${p.doneCount} of $total lessons · 🔥 ${p.streak}-day streak',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 66,
                    height: 66,
                    child: Stack(fit: StackFit.expand, children: [
                      CircularProgressIndicator(
                        value: p.overall,
                        strokeWidth: 7,
                        strokeCap: StrokeCap.round,
                        color: Colors.white,
                        backgroundColor: Colors.white24,
                      ),
                      Center(
                        child: Text('${(p.overall * 100).round()}%',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                      ),
                    ]),
                  ),
                ]),
                if (resume != null) ...[
                  const SizedBox(height: 14),
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => openLesson(context, resume),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(children: [
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(p.doneCount == 0 ? 'START HERE' : 'CONTINUE',
                                  style: TextStyle(
                                      fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .8, color: AppConfig.seed)),
                              Text(resume.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87, fontSize: 15.5)),
                              Text('${content.courseOf(resume).title} · ${resume.minutes} min',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.black54, fontSize: 12.5)),
                            ]),
                          ),
                          CircleAvatar(
                            backgroundColor: AppConfig.seed,
                            child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ),
        for (final course in content.courses) ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            sliver: SliverToBoxAdapter(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(course.title, style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w900)),
                if (content.courses.length > 1)
                  Text(course.tagline, style: TextStyle(color: scheme.onSurfaceVariant)),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverList.separated(
              itemCount: course.modules.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => ModuleCard(module: course.modules[i], number: i + 1),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
      ]),
    );
  }
}

class ModuleCard extends StatelessWidget {
  const ModuleCard({super.key, required this.module, required this.number});
  final Module module;
  final int number;

  @override
  Widget build(BuildContext context) {
    final p = ProgressScope.of(context);
    final done = module.lessons.where((l) => p.isDone(l.id)).length;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ModuleScreen(module: module))),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: module.color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(12)),
                child: done == module.lessons.length
                    ? Icon(Icons.check_rounded, color: module.color)
                    : Icon(module.icon, color: module.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('$number. ${module.title}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 2),
                  LevelPill(module.level),
                ]),
              ),
              const Icon(Icons.chevron_right),
            ]),
            const SizedBox(height: 8),
            Text(module.description, style: TextStyle(color: scheme.onSurfaceVariant, height: 1.35)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: done / module.lessons.length,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                  color: module.color,
                  backgroundColor: module.color.withValues(alpha: 0.12),
                ),
              ),
              const SizedBox(width: 10),
              Text('$done/${module.lessons.length} · ${module.minutes} min',
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
            ]),
          ]),
        ),
      ),
    );
  }
}

class LevelPill extends StatelessWidget {
  const LevelPill(this.level, {super.key});
  final Level level;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: level.color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(20)),
        child: Text(level.label, style: TextStyle(color: level.color, fontSize: 11.5, fontWeight: FontWeight.w700)),
      );
}

class ModuleScreen extends StatelessWidget {
  const ModuleScreen({super.key, required this.module});
  final Module module;

  @override
  Widget build(BuildContext context) {
    final p = ProgressScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(module.title)),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), children: [
        Text(module.description, style: TextStyle(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 14),
        for (var i = 0; i < module.lessons.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                onTap: () => openLesson(context, module.lessons[i]),
                leading: CircleAvatar(
                  backgroundColor: p.isDone(module.lessons[i].id) ? module.color : module.color.withValues(alpha: 0.12),
                  foregroundColor: p.isDone(module.lessons[i].id) ? Colors.white : module.color,
                  child: p.isDone(module.lessons[i].id)
                      ? const Icon(Icons.check_rounded)
                      : Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
                title: Text(module.lessons[i].title, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${module.lessons[i].summary}\n${module.lessons[i].minutes} min'
                    '${module.lessons[i].questions > 0 ? ' · ${module.lessons[i].questions} quiz questions' : ''}'),
                isThreeLine: true,
                trailing: p.isBookmarked(module.lessons[i].id)
                    ? Icon(Icons.bookmark, color: module.color)
                    : const Icon(Icons.chevron_right),
              ),
            ),
          ),
      ]),
    );
  }
}
