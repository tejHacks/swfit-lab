import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../content/repository.dart';

/// Learner progress, saved on the device.
class Progress extends ChangeNotifier {
  Progress._(this._prefs, this.content) {
    _completed.addAll(_prefs.getStringList('completed') ?? const []);
    _bookmarks.addAll(_prefs.getStringList('bookmarks') ?? const []);
    _known.addAll(_prefs.getStringList('known') ?? const []);
    _lastLesson = _prefs.getString('lastLesson');
    _themeMode = ThemeMode.values[_prefs.getInt('themeMode') ?? 0];
    _textScale = _prefs.getDouble('textScale') ?? 1.0;
    _answered = _prefs.getInt('answered') ?? 0;
    _correct = _prefs.getInt('correct') ?? 0;
    _streak = _prefs.getInt('streak') ?? 0;
    _lastDay = _prefs.getString('lastDay');
    _touchStreak();
  }

  static Future<Progress> load(ContentRepository content) async =>
      Progress._(await SharedPreferences.getInstance(), content);

  final SharedPreferences _prefs;
  final ContentRepository content;
  final Set<String> _completed = {};
  final Set<String> _bookmarks = {};
  final Set<String> _known = {};
  String? _lastLesson;
  ThemeMode _themeMode = ThemeMode.system;
  double _textScale = 1.0;
  int _answered = 0, _correct = 0, _streak = 0;
  String? _lastDay;

  Set<String> get completed => _completed;
  Set<String> get bookmarks => _bookmarks;
  Set<String> get known => _known;
  String? get lastLesson => _lastLesson;
  ThemeMode get themeMode => _themeMode;
  double get textScale => _textScale;
  int get answered => _answered;
  int get correct => _correct;
  int get streak => _streak;

  bool isDone(String id) => _completed.contains(id);
  bool isBookmarked(String id) => _bookmarks.contains(id);
  bool isKnown(String id) => _known.contains(id);

  int get doneCount => content.allLessons.where((l) => _completed.contains(l.id)).length;
  double get overall => content.allLessons.isEmpty ? 0 : doneCount / content.allLessons.length;

  void setDone(String id, bool done) {
    done ? _completed.add(id) : _completed.remove(id);
    _prefs.setStringList('completed', _completed.toList());
    notifyListeners();
  }

  void toggleBookmark(String id) {
    if (!_bookmarks.remove(id)) _bookmarks.add(id);
    _prefs.setStringList('bookmarks', _bookmarks.toList());
    notifyListeners();
  }

  void setKnown(String id, bool known) {
    known ? _known.add(id) : _known.remove(id);
    _prefs.setStringList('known', _known.toList());
    notifyListeners();
  }

  void opened(String id) {
    _lastLesson = id;
    _prefs.setString('lastLesson', id);
    _touchStreak();
    notifyListeners();
  }

  void recordAnswer(bool correct) {
    _answered++;
    if (correct) _correct++;
    _prefs.setInt('answered', _answered);
    _prefs.setInt('correct', _correct);
    notifyListeners();
  }

  void setThemeMode(ThemeMode m) {
    _themeMode = m;
    _prefs.setInt('themeMode', m.index);
    notifyListeners();
  }

  void setTextScale(double s) {
    _textScale = s;
    _prefs.setDouble('textScale', s);
    notifyListeners();
  }

  Future<void> reset() async {
    _completed.clear();
    _bookmarks.clear();
    _known.clear();
    _lastLesson = null;
    _answered = _correct = 0;
    for (final k in ['completed', 'bookmarks', 'known', 'lastLesson', 'answered', 'correct']) {
      await _prefs.remove(k);
    }
    notifyListeners();
  }

  void _touchStreak() {
    String key(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final today = key(DateTime.now());
    if (_lastDay == today) return;
    _streak = _lastDay == key(DateTime.now().subtract(const Duration(days: 1))) ? _streak + 1 : 1;
    _lastDay = today;
    _prefs.setInt('streak', _streak);
    _prefs.setString('lastDay', today);
  }
}

class ProgressScope extends InheritedNotifier<Progress> {
  const ProgressScope({super.key, required Progress progress, required super.child}) : super(notifier: progress);

  static Progress of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ProgressScope>()!.notifier!;
  static Progress read(BuildContext context) => context.getInheritedWidgetOfExactType<ProgressScope>()!.notifier!;
}
