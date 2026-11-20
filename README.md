# SwiftLab

Learn Swift 6 from zero to advanced: 41 lessons with code and quizzes, plus 62 interview questions with model answers and a flashcard drill.

## Run it
```bash
cd ~/Developer/swift_lab
flutter run                  # pick a simulator/phone
flutter build apk --release --split-per-abi   # Android APK
flutter test                 # run the tests
```

## Editing content
```bash
python3 tool/build_lessons.py tool/content assets/lessons        # lessons
python3 tool/build_interview.py tool/interview.md assets/interview/questions.json   # interview Qs
```
