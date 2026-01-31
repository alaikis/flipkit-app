import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class Users extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();
  TextColumn get email => text().nullable()();
  TextColumn get role => text()(); // parent/teacher/admin
  IntColumn get createdAt => integer().withDefault(const Constant(0))();
  TextColumn get lastSyncToken => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LearningSpace extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();
  TextColumn get parentId => text()(); // Parent user ID
  TextColumn get childName => text()(); // e.g., "小明"
  TextColumn get childGender => text().nullable()(); // male/female
  TextColumn get grade => text().nullable()(); // e.g., "grade_7"
  TextColumn get textbookVersion => text().nullable()(); // e.g., "renai", "minjiao"
  TextColumn get favoriteSubjects => text().nullable()(); // JSON array
  TextColumn get profileImageUrl => text().nullable()(); // Avatar URL
  BoolColumn get isActive => boolean().withDefault(const Constant(false))(); // Which space is currently active
  IntColumn get createdAt => integer().nullable()();
  IntColumn get lastAccessedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Courses extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();
  TextColumn get title => text()();
  TextColumn get language => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  IntColumn get schemaVersion => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

class Lessons extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();
  TextColumn get courseId => text()();
  TextColumn get title => text()();
  IntColumn get order => integer().withDefault(const Constant(0))();
  TextColumn get contentBlob => text().nullable()();
  TextColumn get metadata => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Exercises extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();
  TextColumn get lessonId => text()();
  TextColumn get type => text()();
  TextColumn get content => text()();
  TextColumn get answerKey => text().nullable()();
  TextColumn get hint => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Attempts extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();
  TextColumn get exerciseId => text()();
  TextColumn get userId => text()();
  IntColumn get startedAt => integer().nullable()();
  IntColumn get finishedAt => integer().nullable()();
  TextColumn get responsesJson => text().nullable()();
  RealColumn get score => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Progress extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();
  TextColumn get userId => text()();
  TextColumn get courseId => text()();
  TextColumn get lessonId => text().nullable()();
  IntColumn get lastAccessed => integer().nullable()();
  RealColumn get percent => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}

class Plugins extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();
  TextColumn get name => text()();
  TextColumn get version => text().nullable()();
  TextColumn get type => text().nullable()();
  TextColumn get manifestJson => text().nullable()();
  IntColumn get installedAt => integer().nullable()();
  TextColumn get hash => text().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class ChangeLogs extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()(); // create/update/delete
  TextColumn get payloadJson => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get author => text().nullable()();
  IntColumn get timestamp => integer().withDefault(const Constant(0))();
  BoolColumn get tombstone => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Settings extends Table {
  TextColumn get id => text().withDefault(const Constant('singleton'))();
  TextColumn get backupProvider => text().withDefault(const Constant('none'))(); // none|baidu|wechat|other
  TextColumn get backupConfigJson => text().nullable()(); // json for provider-specific metadata (non-secret)
  TextColumn get modelProvider => text().nullable()();
  TextColumn get modelConfigJson => text().nullable()();
  IntColumn get lastBackupAt => integer().nullable()();
  BoolColumn get configured => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class UserConfig extends Table {
  TextColumn get spaceId => text()(); // Foreign key to LearningSpace
  TextColumn get grade => text().nullable()();
  TextColumn get textbookVersion => text().nullable()();
  TextColumn get favoriteSubjects => text().nullable()();
  IntColumn get lastUpdated => integer().nullable()();

  @override
  Set<Column> get primaryKey => {spaceId};
}

class SpaceProgress extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();
  TextColumn get spaceId => text()(); // which child's space
  TextColumn get subject => text()();
  TextColumn get chapter => text()();
  IntColumn get totalQuestions => integer().withDefault(const Constant(0))();
  IntColumn get correctCount => integer().withDefault(const Constant(0))();
  RealColumn get correctRate => real().withDefault(const Constant(0.0))();
  IntColumn get lastStudiedAt => integer().nullable()();
  TextColumn get performanceLevel => text().nullable()(); // weak/normal/strong

  @override
  Set<Column> get primaryKey => {id};
}

class QuestionBank extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();
  TextColumn get subject => text()(); // English, Chinese, Math, etc.
  TextColumn get chapter => text()(); // Chapter/section identifier
  TextColumn get questionType => text()(); // single, multiple, essay, application
  TextColumn get content => text()(); // Question text
  TextColumn get answer => text().nullable()(); // Answer(s)
  TextColumn get explanation => text().nullable()(); // Why this is correct
  TextColumn get source => text().nullable()(); // Generated by model or manually created
  TextColumn get difficulty => text().withDefault(const Constant('medium'))(); // easy, medium, hard
  IntColumn get createdAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class AnswerRecord extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();
  TextColumn get spaceId => text()(); // Isolate by learning space (child)
  TextColumn get questionId => text()();
  TextColumn get subject => text()();
  TextColumn get userAnswer => text().nullable()();
  TextColumn get correctAnswer => text().nullable()();
  RealColumn get score => real().nullable()();
  TextColumn get feedback => text().nullable()(); // AI feedback
  BoolColumn get isCorrect => boolean().nullable()();
  IntColumn get attemptCount => integer().withDefault(const Constant(1))();
  IntColumn get timestamp => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class DictationExercise extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();
  TextColumn get spaceId => text()(); // Isolate by space
  TextColumn get subject => text()(); // English, Chinese
  TextColumn get chapter => text()();
  TextColumn get dictationText => text()(); // Original text to dictate
  TextColumn get userSubmission => text().nullable()(); // User's written answer (JSON from OCR)
  TextColumn get imageUrl => text().nullable()(); // Uploaded image path
  RealColumn get score => real().nullable()();
  TextColumn get errorAnalysis => text().nullable()(); // JSON with error corrections
  IntColumn get createdAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class EssaySubmission extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();
  TextColumn get spaceId => text()(); // Isolate by space
  TextColumn get questionId => text()();
  TextColumn get imageUrl => text().nullable()(); // Uploaded image/scan
  TextColumn get extractedText => text().nullable()(); // OCR result
  RealColumn get score => real().nullable()();
  TextColumn get gradingFeedback => text().nullable()(); // AI grading result
  TextColumn get correctionExplanation => text().nullable()(); // Error correction + suggestions
  TextColumn get videoLinks => text().nullable()(); // JSON: recommended teaching videos
  IntColumn get submittedAt => integer().nullable()();
  BoolColumn get videoWatched => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
