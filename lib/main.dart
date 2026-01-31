import 'package:flutter/material.dart';
import 'data/app_db.dart';
import 'sync/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ui/initial_setup.dart';
import 'ui/user_center.dart';
import 'ui/learning_records_page.dart';
import 'ui/modules/dictation_page.dart';
import 'ui/modules/knowledge_quest_page.dart';
import 'ui/modules/smart_house_page.dart';
import 'ui/space_switcher.dart';
import 'services/learning_space_service.dart';
import 'services/image_processing_service.dart';
@@import 'services/tts_service.dart';
import 'modules/dictation_module.dart';
import 'modules/knowledge_quest_module.dart';
import 'modules/smart_house_module.dart';
import 'models/model_adapter.dart';
import 'models/adapters/openai_adapter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isConfigured = prefs.getBool('isConfigured') ?? false;
  runApp(MyApp(isConfigured: isConfigured));
}

class MyApp extends StatelessWidget {
  final bool isConfigured;
  const MyApp({super.key, required this.isConfigured});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qukit K12',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: isConfigured ? const HomePage() : const InitialSetupPage(),
      routes: {
        '/home': (c) => const HomePage(),
        '/settings': (c) => const UserCenterPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AppDatabase _db;
  late LearningSpaceService _spaceService;
  late ImageProcessingService _imageService;
  late ModelAdapter _modelAdapter;
  @@  late TTSService _ttsService;
  String? activeSpaceId;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    _db = AppDatabase();
    _spaceService = LearningSpaceService(_db);
    _imageService = ImageProcessingService();
    @@    _ttsService = TTSService();
    @@    await _ttsService.init(language: 'zh-CN', pitch: 1.0, rate: 0.5, volume: 1.0);
    final prefs = await SharedPreferences.getInstance();
    activeSpaceId = prefs.getString('activeSpaceId');
    
    // Initialize with OpenAI by default (would be replaced with user-selected provider)
    _modelAdapter = OpenAIAdapter();
    await _modelAdapter.init({'apiKey': 'sk-demo'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Qukit K12')),
      body: _buildTabContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) => setState(() => _selectedTabIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.school), label: '学堂'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: '记录'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildLearningTab();
      case 1:
        return LearningRecordsPage(
          spaceService: _spaceService,
          activeSpaceId: activeSpaceId,
        );
      case 2:
        return const UserCenterPage();
      default:
        return _buildLearningTab();
    }
  }

  Widget _buildLearningTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SpaceSwitcher(
            spaceService: _spaceService,
            parentId: 'parent-user-id',
            onSpaceChanged: (spaceId) => setState(() => activeSpaceId = spaceId),
          ),
          const SizedBox(height: 24),
          const Text('功能模块', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildModuleCard(
                context,
                title: '你播我写',
                description: '听写功能',
                icon: Icons.hearing,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (c) => DictationPage(
                      module: DictationModule(
                        modelAdapter: _modelAdapter,
                        imageService: _imageService,
                        spaceId: activeSpaceId ?? '',
                      @@                        ttsService: _ttsService,
                      ),
                    ),
                  ));
                },
              ),
              _buildModuleCard(
                context,
                title: '知乐岛',
                description: '知识闯关',
                icon: Icons.quiz,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (c) => KnowledgeQuestPage(
                      module: KnowledgeQuestModule(
                        modelAdapter: _modelAdapter,
                        spaceId: activeSpaceId ?? '',
                      ),
                    ),
                  ));
                },
              ),
              _buildModuleCard(
                context,
                title: '聪明屋',
                description: '应用题训练',
                icon: Icons.school,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (c) => SmartHousePage(
                      module: SmartHouseModule(
                        modelAdapter: _modelAdapter,
                        imageService: _imageService,
                        spaceId: activeSpaceId ?? '',
                      ),
                    ),
                  ));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.blue),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _db.close();
    _modelAdapter.close();
    @@    _ttsService.dispose();
    super.dispose();
  }
}
