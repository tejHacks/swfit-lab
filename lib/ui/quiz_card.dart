import 'package:flutter/material.dart';

import '../content/models.dart';
import '../state/progress.dart';
import 'blocks_view.dart';

/// One multiple-choice question with instant feedback.
class QuizCard extends StatefulWidget {
  const QuizCard({super.key, required this.question, this.number, this.onAnswered});
  final QuizQuestion question;
  final int? number;
  final ValueChanged<bool>? onAnswered;

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> {
  int? _picked;

  void _pick(int i) {
    if (_picked != null) return;
    setState(() => _picked = i);
    final ok = i == widget.question.answer;
    ProgressScope.read(context).recordAnswer(ok);
    widget.onAnswered?.call(ok);
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final scheme = Theme.of(context).colorScheme;
    const green = Color(0xFF16A34A);
    final red = scheme.error;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (widget.number != null)
            Text('QUESTION ${widget.number}',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 1, color: scheme.primary)),
          const SizedBox(height: 4),
          InlineText(q.question, style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          for (var i = 0; i < q.options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _Option(
                letter: String.fromCharCode(65 + i),
                text: q.options[i],
                color: _picked == null
                    ? null
                    : i == q.answer
                        ? green
                        : i == _picked
                            ? red
                            : null,
                dim: _picked != null && i != q.answer && i != _picked,
                onTap: () => _pick(i),
              ),
            ),
          if (_picked != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (_picked == q.answer ? green : red).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: InlineText('${_picked == q.answer ? '**Correct!** ' : '**Not quite.** '}${q.why}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.45)),
            ),
            if (_picked != q.answer)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => setState(() => _picked = null),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Try again'),
                ),
              ),
          ],
        ]),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({required this.letter, required this.text, required this.color, required this.dim, required this.onTap});
  final String letter, text;
  final Color? color;
  final bool dim;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: color?.withValues(alpha: 0.1) ?? Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color ?? scheme.outlineVariant, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: color == null && !dim ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(children: [
            CircleAvatar(
              radius: 13,
              backgroundColor: scheme.surfaceContainerHighest,
              child: Text(letter, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Opacity(
                opacity: dim ? 0.5 : 1,
                child: InlineText(text, style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
