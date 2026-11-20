import 'package:flutter/material.dart';

/// Everything that makes this app "SwiftLab". The engine (content, state, ui)
/// is shared with LaravelLab; only this config and the assets differ.
class AppConfig {
  static const appName = 'SwiftLab';
  static const tagline = 'Swift 6 from zero to advanced, plus interview prep.';
  static const seed = Color(0xFFF05138); // Swift orange
  static const logoLetter = 'S';

  /// Course folders under assets/lessons, in path order.
  static const courses = ['swift'];

  /// Language assumed for code blocks without one.
  static const defaultCodeLanguage = 'swift';

  /// Interview questions (assets/interview/questions.json).
  static const interviewAsset = 'assets/interview/questions.json';
}
