import 'dart:async';

import 'package:flutter/material.dart';

import '../content/models.dart';
import '../state/progress.dart';
import 'lesson_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<LessonInfo> _results = [];
  String _term = '';
  Timer? _debounce;

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      final results = await ProgressScope.read(context).content.search(v);
      if (!mounted) return;
      setState(() {
        _term = v;
        _results = results;
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = ProgressScope.of(context).content;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Search lessons…', border: InputBorder.none, filled: false),
          onChanged: _onChanged,
        ),
      ),
      body: _term.trim().isEmpty
          ? const Center(child: Text('Type a word, e.g. "migration" or "token"'))
          : _results.isEmpty
              ? const Center(child: Text('No lessons match.'))
              : ListView(children: [
                  for (final l in _results)
                    ListTile(
                      leading: Icon(content.moduleOf(l).icon, color: content.moduleOf(l).color),
                      title: Text(l.title),
                      subtitle: Text('${content.courseOf(l).title} · ${l.summary}', maxLines: 2, overflow: TextOverflow.ellipsis),
                      onTap: () => openLesson(context, l),
                    ),
                ]),
    );
  }
}
