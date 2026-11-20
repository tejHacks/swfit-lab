import 'dart:convert';

import 'models.dart';

/// A small Markdown parser for lesson files. Supports:
///   front matter (---), # headings, paragraphs, - / 1. lists, ``` fences,
///   | tables |, :::tip/note/warning/analogy callouts and a ```quiz JSON block.
class ParsedLesson {
  const ParsedLesson(this.meta, this.blocks, this.quiz);
  final Map<String, String> meta;
  final List<Block> blocks;
  final List<QuizQuestion> quiz;
}

ParsedLesson parseLesson(String source) {
  var text = source.replaceAll('\r\n', '\n');
  final meta = <String, String>{};
  final fm = RegExp(r'^---\n(.*?)\n---\n', dotAll: true).firstMatch(text);
  if (fm != null) {
    for (final line in fm.group(1)!.split('\n')) {
      final i = line.indexOf(':');
      if (i > 0) meta[line.substring(0, i).trim()] = line.substring(i + 1).trim();
    }
    text = text.substring(fm.end);
  }

  final quiz = <QuizQuestion>[];
  text = text.replaceAllMapped(RegExp(r'```quiz\n(.*?)\n```', dotAll: true), (m) {
    for (final q in jsonDecode(m.group(1)!) as List) {
      quiz.add(QuizQuestion.fromJson(q as Map<String, dynamic>));
    }
    return '';
  });

  return ParsedLesson(meta, parseBlocks(text), quiz);
}

List<Block> parseBlocks(String text) {
  final lines = text.split('\n');
  final blocks = <Block>[];
  var i = 0;

  bool isListItem(String l) => RegExp(r'^\s*([-*]|\d+\.)\s+').hasMatch(l);
  bool isSpecial(String l) =>
      l.startsWith('#') || l.startsWith('```') || l.startsWith(':::') || l.trimLeft().startsWith('|') || isListItem(l);

  while (i < lines.length) {
    final line = lines[i];

    if (line.trim().isEmpty) {
      i++;
      continue;
    }

    // Code fence
    if (line.startsWith('```')) {
      final lang = line.substring(3).trim();
      final buf = <String>[];
      i++;
      while (i < lines.length && !lines[i].startsWith('```')) {
        buf.add(lines[i]);
        i++;
      }
      i++; // closing fence
      blocks.add(CodeBlock(lang, buf.join('\n')));
      continue;
    }

    // Callout
    final callout = RegExp(r'^:::(tip|note|warning|analogy)\s*$').firstMatch(line);
    if (callout != null) {
      final buf = <String>[];
      i++;
      while (i < lines.length && lines[i].trim() != ':::') {
        buf.add(lines[i]);
        i++;
      }
      i++;
      blocks.add(CalloutBlock(callout.group(1)!, parseBlocks(buf.join('\n'))));
      continue;
    }

    // Heading
    final heading = RegExp(r'^(#{1,4})\s+(.*)$').firstMatch(line);
    if (heading != null) {
      blocks.add(HeadingBlock(heading.group(1)!.length, heading.group(2)!.trim()));
      i++;
      continue;
    }

    // Table
    if (line.trimLeft().startsWith('|')) {
      final rows = <List<String>>[];
      while (i < lines.length && lines[i].trimLeft().startsWith('|')) {
        final cells = lines[i].trim().replaceAll(RegExp(r'^\||\|$'), '').split('|').map((c) => c.trim()).toList();
        if (!cells.every((c) => RegExp(r'^:?-{2,}:?$').hasMatch(c))) rows.add(cells);
        i++;
      }
      if (rows.isNotEmpty) blocks.add(TableBlock(rows.first, rows.skip(1).toList()));
      continue;
    }

    // List (with simple continuation lines)
    if (isListItem(line)) {
      final ordered = RegExp(r'^\s*\d+\.').hasMatch(line);
      final items = <String>[];
      while (i < lines.length && lines[i].trim().isNotEmpty && (isListItem(lines[i]) || !isSpecial(lines[i]))) {
        if (isListItem(lines[i])) {
          items.add(lines[i].replaceFirst(RegExp(r'^\s*([-*]|\d+\.)\s+'), ''));
        } else if (items.isNotEmpty) {
          items[items.length - 1] = '${items.last} ${lines[i].trim()}';
        }
        i++;
      }
      blocks.add(ListBlock(items, ordered: ordered));
      continue;
    }

    // Paragraph: consecutive plain lines
    final buf = <String>[];
    while (i < lines.length && lines[i].trim().isNotEmpty && !isSpecial(lines[i])) {
      buf.add(lines[i].trim());
      i++;
    }
    if (buf.isEmpty) {
      i++; // safety: never loop forever on an unrecognised line
      continue;
    }
    blocks.add(ParagraphBlock(buf.join(' ')));
  }
  return blocks;
}

/// Inline token for rendering: text with simple styles.
class InlineToken {
  const InlineToken(this.text, {this.code = false, this.bold = false, this.italic = false, this.link});
  final String text;
  final bool code, bold, italic;
  final String? link;
}

final _inline = RegExp(r'`([^`]+)`|\*\*([^*]+)\*\*|\[([^\]]+)\]\(([^)]+)\)|(?<![\w*])\*([^*\s][^*]*?)\*(?![\w*])');

/// Splits inline Markdown: `code`, **bold**, *italic*, [text](url).
List<InlineToken> parseInline(String text) {
  final out = <InlineToken>[];
  var last = 0;
  for (final m in _inline.allMatches(text)) {
    if (m.start > last) out.add(InlineToken(text.substring(last, m.start)));
    if (m.group(1) != null) {
      out.add(InlineToken(m.group(1)!, code: true));
    } else if (m.group(2) != null) {
      out.add(InlineToken(m.group(2)!, bold: true));
    } else if (m.group(3) != null) {
      out.add(InlineToken(m.group(3)!, link: m.group(4)));
    } else if (m.group(5) != null) {
      out.add(InlineToken(m.group(5)!, italic: true));
    }
    last = m.end;
  }
  if (last < text.length) out.add(InlineToken(text.substring(last)));
  return out;
}
