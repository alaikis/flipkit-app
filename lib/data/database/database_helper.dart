import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../config/app_config.dart';
import '../models/learning_space.dart';
import '../models/question.dart';
import '../models/answer_record.dart';
import '../models/resource.dart';
import '../../core/utils/logger.dart';

/// 数据库辅助类
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database;

  /// 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConfig.dbName);

    Logger.info('Initializing database at: $path', tag: 'Database');

    return await openDatabase(
      path,
      version: AppConfig.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    Logger.info('Creating database tables', tag: 'Database');

    // 学习空间表
    await db.execute('''
      CREATE TABLE learning_spaces (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        child_name TEXT NOT NULL,
        child_gender TEXT NOT NULL,
        grade TEXT NOT NULL,
        avatar TEXT,
        textbook_version TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 题目表
    await db.execute('''
      CREATE TABLE questions (
        id TEXT PRIMARY KEY,
        space_id TEXT NOT NULL,
        subject TEXT NOT NULL,
        grade TEXT NOT NULL,
        chapter TEXT NOT NULL,
        type TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        content TEXT NOT NULL,
        options TEXT,
        answer TEXT,
        explanation TEXT,
        tags TEXT,
        source TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (space_id) REFERENCES learning_spaces (id) ON DELETE CASCADE
      )
    ''');

    // 答题记录表
    await db.execute('''
      CREATE TABLE answer_records (
        id TEXT PRIMARY KEY,
        space_id TEXT NOT NULL,
        question_id TEXT NOT NULL,
        user_answer TEXT,
        correct_answer TEXT,
        score REAL NOT NULL,
        max_score REAL NOT NULL DEFAULT 100.0,
        is_correct INTEGER NOT NULL DEFAULT 0,
        attempt_count INTEGER NOT NULL DEFAULT 1,
        feedback TEXT,
        image_url TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (space_id) REFERENCES learning_spaces (id) ON DELETE CASCADE,
        FOREIGN KEY (question_id) REFERENCES questions (id) ON DELETE CASCADE
      )
    ''');

    // 资源表
    await db.execute('''
      CREATE TABLE resources (
        id TEXT PRIMARY KEY,
        space_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        source TEXT NOT NULL,
        url TEXT,
        local_path TEXT,
        tags TEXT,
        file_size INTEGER NOT NULL DEFAULT 0,
        github_repo TEXT,
        github_path TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (space_id) REFERENCES learning_spaces (id) ON DELETE CASCADE
      )
    ''');

    // 创建索引
    await db.execute('CREATE INDEX idx_questions_space_id ON questions(space_id)');
    await db.execute('CREATE INDEX idx_questions_subject ON questions(subject)');
    await db.execute('CREATE INDEX idx_answer_records_space_id ON answer_records(space_id)');
    await db.execute('CREATE INDEX idx_answer_records_question_id ON answer_records(question_id)');
    await db.execute('CREATE INDEX idx_resources_space_id ON resources(space_id)');

    Logger.info('Database tables created successfully', tag: 'Database');
  }

  /// 升级数据库
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    Logger.info('Upgrading database from $oldVersion to $newVersion', tag: 'Database');
    // 根据版本进行升级
  }

  // ==================== 学习空间操作 ====================

  /// 插入学习空间
  Future<int> insertLearningSpace(LearningSpace space) async {
    final db = await database;
    return await db.insert('learning_spaces', space.toJson());
  }

  /// 获取所有学习空间
  Future<List<LearningSpace>> getLearningSpaces(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'learning_spaces',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => LearningSpace.fromJson(map)).toList();
  }

  /// 获取活跃学习空间
  Future<LearningSpace?> getActiveLearningSpace(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'learning_spaces',
      where: 'user_id = ? AND is_active = ?',
      whereArgs: [userId, 1],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return LearningSpace.fromJson(maps.first);
  }

  /// 更新学习空间
  Future<int> updateLearningSpace(LearningSpace space) async {
    final db = await database;
    return await db.update(
      'learning_spaces',
      space.toJson(),
      where: 'id = ?',
      whereArgs: [space.id],
    );
  }

  /// 删除学习空间
  Future<int> deleteLearningSpace(String id) async {
    final db = await database;
    return await db.delete(
      'learning_spaces',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== 题目操作 ====================

  /// 插入题目
  Future<int> insertQuestion(Question question) async {
    final db = await database;
    return await db.insert('questions', question.toJson());
  }

  /// 批量插入题目
  Future<void> insertQuestions(List<Question> questions) async {
    final db = await database;
    final batch = db.batch();
    for (var question in questions) {
      batch.insert('questions', question.toJson());
    }
    await batch.commit(noResult: true);
  }

  /// 获取学习空间的题目
  Future<List<Question>> getQuestions(String spaceId, {String? subject, String? chapter}) async {
    final db = await database;
    String where = 'space_id = ?';
    List<dynamic> whereArgs = [spaceId];

    if (subject != null) {
      where += ' AND subject = ?';
      whereArgs.add(subject);
    }

    if (chapter != null) {
      where += ' AND chapter = ?';
      whereArgs.add(chapter);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'questions',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Question.fromJson(map)).toList();
  }

  /// 删除题目
  Future<int> deleteQuestion(String id) async {
    final db = await database;
    return await db.delete(
      'questions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== 答题记录操作 ====================

  /// 插入答题记录
  Future<int> insertAnswerRecord(AnswerRecord record) async {
    final db = await database;
    return await db.insert('answer_records', record.toJson());
  }

  /// 获取答题记录
  Future<List<AnswerRecord>> getAnswerRecords(String spaceId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'answer_records',
      where: 'space_id = ?',
      whereArgs: [spaceId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => AnswerRecord.fromJson(map)).toList();
  }

  /// 获取题目的答题记录
  Future<List<AnswerRecord>> getAnswerRecordsByQuestion(String questionId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'answer_records',
      where: 'question_id = ?',
      whereArgs: [questionId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => AnswerRecord.fromJson(map)).toList();
  }

  // ==================== 资源操作 ====================

  /// 插入资源
  Future<int> insertResource(Resource resource) async {
    final db = await database;
    return await db.insert('resources', resource.toJson());
  }

  /// 获取资源
  Future<List<Resource>> getResources(String spaceId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'resources',
      where: 'space_id = ?',
      whereArgs: [spaceId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Resource.fromJson(map)).toList();
  }

  /// 更新资源
  Future<int> updateResource(Resource resource) async {
    final db = await database;
    return await db.update(
      'resources',
      resource.toJson(),
      where: 'id = ?',
      whereArgs: [resource.id],
    );
  }

  /// 删除资源
  Future<int> deleteResource(String id) async {
    final db = await database;
    return await db.delete(
      'resources',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 清空数据库
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('learning_spaces');
    await db.delete('questions');
    await db.delete('answer_records');
    await db.delete('resources');
    Logger.warning('Database cleared', tag: 'Database');
  }

  /// 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
