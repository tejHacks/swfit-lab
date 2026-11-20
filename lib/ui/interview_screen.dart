import 'dart:math';

import 'package:flutter/material.dart';

import '../content/models.dart';
import '../state/progress.dart';
import 'blocks_view.dart';
import 'learn_screen.dart';

/// Interview questions: browse with filters, reveal model answers,
/// mark what you know, and drill with flashcards.
class InterviewScreen extends StatefulWidget {
  const InterviewScreen({super.key});
  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  Level? _level;
  String? _category;
  String _query = '';
  bool _hideKnown = false;

  @override
  Widget build(BuildContext context) {
    final p = ProgressScope.of(context);
    final all = p.content.interview;
    final categories = {for (final q in all) q.category}.toList();
    final q = _query.toLowerCase();
    final list = all
        .where((x) => _level == null || x.level == _level)
        .where((x) => _category == null || x.category == _category)
        .where((x) => !_hideKnown || !p.isKnown(x.id))
        .where((x) => q.isEmpty || x.question.toLowerCase().contains(q))
        .toList();
    final known = all.where((x) => p.isKnown(x.id)).length;
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
        Text('Interview prep', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w900)),
        Text('$known of ${all.length} questions mastered', style: TextStyle(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: all.isEmpty ? 0 : known / all.length,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
          onPressed: list.isEmpty
              ? null
              : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => FlashcardSession(questions: list))),
          icon: const Icon(Icons.style_rounded),
          label: Text('Flashcard drill (${list.length})'),
        ),
        const SizedBox(height: 14),
        TextField(
          decoration: const InputDecoration(hintText: 'Search questions…', prefixIcon: Icon(Icons.search), isDense: true),
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 10),
        Wrap(spacing: 6, runSpacing: 6, children: [
          ChoiceChip(label: const Text('All levels'), selected: _level == null, onSelected: (_) => setState(() => _level = null)),
          for (final l in Level.values)
            ChoiceChip(label: Text(l.label), selected: _level == l, onSelected: (_) => setState(() => _level = _level == l ? null : l)),
        ]),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 6, children: [
          ChoiceChip(
              label: const Text('All topics'), selected: _category == null, onSelected: (_) => setState(() => _category = null)),
          for (final c in categories)
            ChoiceChip(
                label: Text(c), selected: _category == c, onSelected: (_) => setState(() => _category = _category == c ? null : c)),
        ]),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Hide questions I know'),
          value: _hideKnown,
          onChanged: (v) => setState(() => _hideKnown = v),
        ),
        if (list.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No questions match.'))),
        for (final item in list)
          Padding(padding: const EdgeInsets.only(bottom: 8), child: _QuestionTile(item: item)),
      ]),
    );
  }
}

class _QuestionTile extends StatelessWidget {
  const _QuestionTile({required this.item});
  final InterviewQuestion item;

  @override
  Widget build(BuildContext context) {
    final p = ProgressScope.of(context);
    final known = p.isKnown(item.id);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(known ? Icons.check_circle : Icons.help_outline,
            color: known ? const Color(0xFF16A34A) : Theme.of(context).colorScheme.primary),
        title: InlineText(item.question, style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(children: [
            LevelPill(item.level),
            const SizedBox(width: 6),
            Flexible(child: Text(item.category, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5))),
          ]),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocksView(item.answer),
          Align(
            alignment: Alignment.centerRight,
            child: known
                ? TextButton.icon(
                    onPressed: () => p.setKnown(item.id, false),
                    icon: const Icon(Icons.undo, size: 18),
                    label: const Text('Mark as still learning'),
                  )
                : FilledButton.tonalIcon(
                    onPressed: () => p.setKnown(item.id, true),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('I know this'),
                  ),
          ),
        ],
      ),
    );
  }
}

class FlashcardSession extends StatefulWidget {
  const FlashcardSession({super.key, required this.questions});
  final List<InterviewQuestion> questions;
  @override
  State<FlashcardSession> createState() => _FlashcardSessionState();
}

class _FlashcardSessionState extends State<FlashcardSession> {
  late final List<InterviewQuestion> _deck = [...widget.questions]..shuffle(Random());
  int _i = 0;
  bool _revealed = false;
  int _knew = 0;

  void _next(bool knew) {
    final p = ProgressScope.read(context);
    if (knew) {
      _knew++;
      p.setKnown(_deck[_i].id, true);
    }
    setState(() {
      _i++;
      _revealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final done = _i >= _deck.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(done ? 'Drill complete' : 'Card ${_i + 1} of ${_deck.length}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: done ? 1 : _i / _deck.length, minHeight: 4),
        ),
      ),
      body: SafeArea(
        child: done
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('🎯', style: TextStyle(fontSize: 64)),
                    Text('You knew $_knew of ${_deck.length}',
                        style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 16),
                    FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
                  ]),
                ),
              )
            : ListView(padding: const EdgeInsets.all(16), children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        LevelPill(_deck[_i].level),
                        const SizedBox(width: 8),
                        Flexible(child: Text(_deck[_i].category, overflow: TextOverflow.ellipsis)),
                      ]),
                      const SizedBox(height: 12),
                      InlineText(_deck[_i].question,
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text('Answer out loud first, then reveal the model answer.',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),
                if (!_revealed)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                    onPressed: () => setState(() => _revealed = true),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Reveal answer'),
                  )
                else ...[
                  Card(child: Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 2), child: BlocksView(_deck[_i].answer))),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                        onPressed: () => _next(false),
                        icon: const Icon(Icons.replay),
                        label: const Text('Still learning'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                        onPressed: () => _next(true),
                        icon: const Icon(Icons.check),
                        label: const Text('I knew it'),
                      ),
                    ),
                  ]),
                ],
              ]),
      ),
    );
  }
}
