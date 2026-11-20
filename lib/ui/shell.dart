import 'package:flutter/material.dart';

import '../state/progress.dart';
import 'interview_screen.dart';
import 'learn_screen.dart';
import 'me_screen.dart';
import 'practice_screen.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final hasInterview = ProgressScope.of(context).content.interview.isNotEmpty;
    final pages = [
      const LearnScreen(),
      const PracticeScreen(),
      if (hasInterview) const InterviewScreen(),
      const MeScreen(),
    ];
    final index = _tab.clamp(0, pages.length - 1);
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school), label: 'Learn'),
          const NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined), selectedIcon: Icon(Icons.fitness_center), label: 'Practice'),
          if (hasInterview)
            const NavigationDestination(
                icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'Interview'),
          const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Me'),
        ],
      ),
    );
  }
}
