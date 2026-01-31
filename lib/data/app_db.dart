import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';
part 'app_db.g.dart';

@DriftDatabase(tables: [Users, Courses, Lessons, Exercises, Attempts, Progress, Plugins, ChangeLogs, Settings, LearningSpace, UserConfig, QuestionBank, AnswerRecord, DictationExercise, EssaySubmission, SpaceProgress])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Example DAO-like methods can be added here.
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'qukit.sqlite'));
    return NativeDatabase(file);
  });
}
