import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config.dart';
import 'theme.dart';

const _mono = TextStyle(fontFamily: 'monospace', fontFamilyFallback: ['Menlo', 'Courier'], height: 1.5);

/// Dark code box with syntax highlighting, horizontal scroll and a Copy button.
class CodeView extends StatelessWidget {
  const CodeView({super.key, required this.code, required this.language, this.fontScale = 1});
  final String code;
  final String language;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final lang = language.isEmpty ? AppConfig.defaultCodeLanguage : language;
    return Container(
      decoration: BoxDecoration(color: CodeColors.bg, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 4, 4, 0),
          child: Row(children: [
            Text(_label(lang), style: const TextStyle(color: CodeColors.comment, fontSize: 12)),
            const Spacer(),
            IconButton(
              tooltip: 'Copy',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.copy_rounded, size: 16, color: CodeColors.comment),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(const SnackBar(content: Text('Code copied'), duration: Duration(seconds: 1)));
              },
            ),
          ]),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: Text.rich(TextSpan(
            style: _mono.copyWith(fontSize: 13 * fontScale, color: CodeColors.plain),
            children: highlight(code, lang),
          )),
        ),
      ]),
    );
  }

  static String _label(String lang) => switch (lang) {
        'php' => 'PHP',
        'blade' => 'Blade',
        'bash' || 'sh' || 'shell' => 'Terminal',
        'dotenv' => '.env',
        'json' => 'JSON',
        'http' => 'HTTP',
        'swift' => 'Swift',
        'dart' => 'Dart',
        'js' || 'javascript' => 'JavaScript',
        'text' => 'Text',
        _ => lang,
      };
}

const _keywords = <String, Set<String>>{
  'php': {
    'abstract', 'and', 'array', 'as', 'break', 'case', 'catch', 'class', 'clone', 'const', 'continue', 'declare',
    'default', 'do', 'echo', 'else', 'elseif', 'enum', 'extends', 'false', 'final', 'finally', 'fn', 'for',
    'foreach', 'function', 'if', 'implements', 'instanceof', 'interface', 'match', 'namespace', 'new', 'null',
    'or', 'private', 'protected', 'public', 'readonly', 'return', 'self', 'static', 'switch', 'throw', 'trait',
    'true', 'try', 'use', 'void', 'while', 'yield', 'string', 'int', 'bool', 'float', 'mixed', 'parent',
  },
  'swift': {
    'actor', 'any', 'as', 'associatedtype', 'async', 'await', 'break', 'case', 'catch', 'class', 'continue',
    'default', 'defer', 'deinit', 'do', 'else', 'enum', 'extension', 'fallthrough', 'false', 'fileprivate',
    'final', 'for', 'func', 'guard', 'if', 'import', 'in', 'init', 'inout', 'internal', 'is', 'lazy', 'let',
    'mutating', 'nil', 'nonisolated', 'open', 'operator', 'override', 'private', 'protocol', 'public',
    'repeat', 'rethrows', 'return', 'self', 'Self', 'some', 'static', 'struct', 'subscript', 'super', 'switch',
    'throw', 'throws', 'true', 'try', 'typealias', 'var', 'weak', 'unowned', 'where', 'while', 'consuming',
    'borrowing', 'sending', 'isolated',
  },
  'dart': {
    'abstract', 'as', 'async', 'await', 'break', 'case', 'catch', 'class', 'const', 'continue', 'default',
    'else', 'enum', 'extends', 'false', 'final', 'for', 'if', 'import', 'in', 'is', 'late', 'new', 'null',
    'return', 'static', 'super', 'switch', 'this', 'throw', 'true', 'try', 'var', 'void', 'while', 'with',
  },
  'js': {
    'const', 'let', 'var', 'function', 'return', 'if', 'else', 'for', 'while', 'await', 'async', 'new',
    'true', 'false', 'null', 'undefined', 'import', 'export', 'from', 'class', 'try', 'catch',
  },
};

final _token = RegExp(
  r'(//[^\n]*|/\*[\s\S]*?\*/|#(?!\[)[^\n]*|\{\{--[\s\S]*?--\}\})' // 1 comment (#: php/bash; not #[)
  r'|("""[\s\S]*?"""' r"|'(?:\\.|[^'\\\n])*'" r'|"(?:\\.|[^"\\\n])*")' // 2 string
  r'|(\$[A-Za-z_]\w*)' // 3 php variable
  r'|(#\[[^\]\n]*\]|@[A-Za-z_]\w*)' // 4 attribute / annotation / blade directive
  r'|(\b\d+(?:\.\d+)?\b)' // 5 number
  r'|(\b[A-Za-z_]\w*\b)', // 6 identifier
);

/// Lightweight multi-language syntax highlighter.
List<TextSpan> highlight(String src, String language) {
  final lang = switch (language) {
    'blade' => 'php',
    'javascript' => 'js',
    _ => language,
  };
  final keywords = _keywords[lang] ?? const <String>{};
  final hashComments = lang == 'php' || lang == 'bash' || lang == 'sh' || lang == 'shell' || lang == 'dotenv';
  final spans = <TextSpan>[];
  var last = 0;

  for (final m in _token.allMatches(src)) {
    var text = m.group(0)!;
    // '#' is only a comment in hash-comment languages (Swift uses #if, #Preview...)
    if (m.group(1) != null && text.startsWith('#') && !hashComments) {
      if (m.start > last) spans.add(TextSpan(text: src.substring(last, m.start)));
      spans.add(TextSpan(text: text, style: const TextStyle(color: CodeColors.attribute)));
      last = m.end;
      continue;
    }
    if (m.start > last) spans.add(TextSpan(text: src.substring(last, m.start)));
    Color? color;
    var italic = false;
    if (m.group(1) != null) {
      color = CodeColors.comment;
      italic = true;
    } else if (m.group(2) != null) {
      color = CodeColors.string;
    } else if (m.group(3) != null) {
      color = CodeColors.variable;
    } else if (m.group(4) != null) {
      color = CodeColors.attribute;
    } else if (m.group(5) != null) {
      color = CodeColors.number;
    } else if (keywords.contains(text)) {
      color = CodeColors.keyword;
    } else if (lang != 'bash' && text[0].toUpperCase() == text[0] && text[0] != '_' && !RegExp(r'^\d').hasMatch(text)) {
      color = CodeColors.type;
    } else if (m.end < src.length && src[m.end] == '(') {
      color = CodeColors.function;
    }
    spans.add(TextSpan(text: text, style: color == null ? null : TextStyle(color: color, fontStyle: italic ? FontStyle.italic : null)));
    last = m.end;
  }
  if (last < src.length) spans.add(TextSpan(text: src.substring(last)));
  return spans;
}
