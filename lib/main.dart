import 'package:flutter/material.dart';

import 'config.dart';
import 'content/repository.dart';
import 'state/progress.dart';
import 'ui/shell.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final content = await ContentRepository.load();
  final progress = await Progress.load(content);
  runApp(ProgressScope(progress: progress, child: const LabApp()));
}

class LabApp extends StatelessWidget {
  const LabApp({super.key});

  @override
  Widget build(BuildContext context) {
    final p = ProgressScope.of(context);
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: p.themeMode,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(MediaQuery.textScalerOf(context).scale(1) * p.textScale),
        ),
        child: child!,
      ),
      home: const Shell(),
    );
  }
}
