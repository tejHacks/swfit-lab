import 'package:flutter/material.dart';

import '../content/markdown.dart';
import '../content/models.dart';
import 'code_view.dart';

/// Renders parsed Markdown blocks.
class BlocksView extends StatelessWidget {
  const BlocksView(this.blocks, {super.key, this.codeScale = 1});
  final List<Block> blocks;
  final double codeScale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final b in blocks)
          Padding(padding: const EdgeInsets.only(bottom: 14), child: _block(context, b)),
      ],
    );
  }

  Widget _block(BuildContext context, Block b) {
    final t = Theme.of(context).textTheme;
    return switch (b) {
      HeadingBlock(:final level, :final text) => Padding(
          padding: EdgeInsets.only(top: level <= 2 ? 10 : 4),
          child: InlineText(text,
              style: (level <= 2 ? t.titleLarge : t.titleMedium)!.copyWith(fontWeight: FontWeight.w800)),
        ),
      ParagraphBlock(:final text) => InlineText(text),
      ListBlock(:final items, :final ordered) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < items.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                    width: 26,
                    child: Text(ordered ? '${i + 1}.' : '•',
                        style: t.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary)),
                  ),
                  Expanded(child: InlineText(items[i])),
                ]),
              ),
          ],
        ),
      CodeBlock(:final language, :final code) => CodeView(code: code, language: language, fontScale: codeScale),
      CalloutBlock(:final kind, :final children) => _Callout(kind: kind, child: BlocksView(children, codeScale: codeScale)),
      TableBlock(:final header, :final rows) => _Table(header: header, rows: rows),
    };
  }
}

/// Text with inline Markdown (`code`, **bold**, *italic*, links).
class InlineText extends StatelessWidget {
  const InlineText(this.text, {super.key, this.style});
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = style ?? Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.55);
    return Text.rich(TextSpan(style: base, children: [
      for (final tok in parseInline(text))
        TextSpan(
          text: tok.text,
          style: tok.code
              ? TextStyle(
                  fontFamily: 'monospace',
                  fontFamilyFallback: const ['Menlo', 'Courier'],
                  fontSize: (base.fontSize ?? 16) * 0.88,
                  color: scheme.primary,
                  backgroundColor: scheme.primaryContainer.withValues(alpha: 0.35),
                )
              : tok.bold
                  ? const TextStyle(fontWeight: FontWeight.w800)
                  : tok.italic
                      ? const TextStyle(fontStyle: FontStyle.italic)
                      : tok.link != null
                          ? TextStyle(color: scheme.primary, fontWeight: FontWeight.w600)
                          : null,
        ),
    ]));
  }
}

class _Callout extends StatelessWidget {
  const _Callout({required this.kind, required this.child});
  final String kind;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final (IconData icon, String label, Color color) = switch (kind) {
      'tip' => (Icons.lightbulb_rounded, 'Tip', const Color(0xFF16A34A)),
      'warning' => (Icons.warning_amber_rounded, 'Watch out', const Color(0xFFD97706)),
      'analogy' => (Icons.emoji_objects_outlined, 'Think of it like…', const Color(0xFF7C3AED)),
      _ => (Icons.info_rounded, 'Good to know', const Color(0xFF2563EB)),
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: dark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800))),
        ]),
        const SizedBox(height: 6),
        child,
      ]),
    );
  }
}

class _Table extends StatelessWidget {
  const _Table({required this.header, required this.rows});
  final List<String> header;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final small = Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.4);
    Widget cell(String s, {bool head = false}) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: InlineText(s, style: head ? small.copyWith(fontWeight: FontWeight.w800) : small),
        );
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 300),
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            border: TableBorder.symmetric(inside: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6))),
            children: [
              TableRow(
                decoration: BoxDecoration(color: scheme.surfaceContainerHighest),
                children: [for (final h in header) cell(h, head: true)],
              ),
              for (final r in rows)
                TableRow(children: [
                  for (var i = 0; i < header.length; i++) cell(i < r.length ? r[i] : ''),
                ]),
            ],
          ),
        ),
      ),
    );
  }
}
