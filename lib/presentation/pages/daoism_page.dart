import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:get/get.dart';
import '../../services/ai_service.dart';
import '../../services/tts_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';

/// 道法诵读页面
class DaoismPage extends StatefulWidget {
  const DaoismPage({super.key});

  @override
  State<DaoismPage> createState() => _DaoismPageState();
}

class _DaoismPageState extends State<DaoismPage> {
  final AIService _aiService = AIService();
  final TTSService _ttsService = TTSService();

  String _selectedCategory = '经典';
  String _selectedDifficulty = '中等';
  bool _isPlaying = false;
  int _currentIndex = 0;

  final List<String> _categories = [
    '经典',
    '论语',
    '道德经',
    '金刚经',
    '易经',
    '庄子',
    '孟子',
  ];

  final List<Map<String, dynamic>> _daoismContents = [
    {
      'category': '经典',
      'title': '大学',
      'content': '大学之道，在明明德，在亲民，在止于至善。',
      'difficulty': '简单',
    },
    {
      'category': '经典',
      'title': '中庸',
      'content': '天命之谓性，率性之谓道，修道之谓教。',
      'difficulty': '中等',
    },
    {
      'category': '论语',
      'title': '学而时习之',
      'content': '学而时习之，不亦说乎！有朋自远方来，不亦乐乎？',
      'difficulty': '简单',
    },
    {
      'category': '论语',
      'title': '君子不器',
      'content': '君子不器，上得志，下得民，让民于物。',
      'difficulty': '中等',
    },
    {
      'category': '道德经',
      'title': '上善若水',
      'content': '上善若水。水利万物而不争，处众人之所恶，故几于道。',
      'difficulty': '简单',
    },
    {
      'category': '道德经',
      'title': '道可道，非常道',
      'content': '道可道，非常道。名可名，非常名。无名，天地之始；有名，万物之母。',
      'difficulty': '困难',
    },
    {
      'category': '金刚经',
      'title': '一切有为法，如梦幻泡影',
      'content': '一切有为法，如梦幻泡影，如露亦如电，应作如是观。',
      'difficulty': '中等',
    },
    {
      'category': '金刚经',
      'title': '凡所有相，皆是虚妄',
      'content': '凡所有相，皆是虚妄。见诸相非相，即见如来。',
      'difficulty': '困难',
    },
    {
      'category': '庄子',
      'title': '北冥有鱼',
      'content': '北冥有鱼，其名为鲲。鲲之大，不知其几千里也。',
      'difficulty': '简单',
    },
    {
      'category': '庄子',
      'title': '逍遥游',
      'content': '若夫乘天地之正，而御六气之辩，以游无穷者，彼且恶乎待哉！',
      'difficulty': '困难',
    },
  ];

  List<Map<String, dynamic>> get _filteredContents {
    return _daoismContents
        .where((item) => item['category'] == _selectedCategory)
        .toList();
  }

  List<Map<String, dynamic>> get _filteredByDifficulty {
    final difficultyOrder = {'简单': 1, '中等': 2, '困难': 3};
    return _filteredContents
        .where((item) => item['difficulty'] == _selectedDifficulty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('道法诵读'),
        backgroundColor: Get.theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildCategorySelector(),
          _buildContentCards(),
        ],
      ),
      floatingActionButton: GFButton(
        icon: Icon(Icons.volume_up),
        text: _isPlaying ? '暂停' : '播放',
        type: GFButtonType.solid,
        size: GFSize.MEDIUM,
        onPressed: _togglePlay,
      ),
    );
  }

  Widget _buildCategorySelector() {
    return GFCard(
      margin: const EdgeInsets.all(16),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '选择经典',
            style: Get.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((category) {
              return GFButton(
                text: category,
                type: _selectedCategory == category
                    ? GFButtonType.solid
                    : GFButtonType.outline,
                onPressed: () => setState(() => _selectedCategory = category),
                size: GFSize.SMALL,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCards() {
    final contents = _filteredByDifficulty;
    
    if (contents.isEmpty) {
      return const Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.category_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text('当前选择没有内容', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contents.length,
        itemBuilder: (context, index) {
          return _buildContentCard(contents[index], index);
        },
      ),
    );
  }

  Widget _buildContentCard(Map<String, dynamic> content, int index) {
    final title = content['title'] as String;
    final text = content['content'] as String;
    final difficulty = content['difficulty'] as String;
    
    final difficultyColor = {
      '简单': Colors.green,
      '中等': Colors.orange,
      '困难': Colors.red,
    }[difficulty] ?? Colors.grey;

    return GFCard(
      margin: const EdgeInsets.only(bottom: 16),
      content: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: difficultyColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    difficulty,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              text,
              style: Get.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GFButton(
                  text: '诵读',
                  type: GFButtonType.outline,
                  size: GFSize.SMALL,
                  onPressed: () => _speakContent(text),
                ),
                const SizedBox(width: 8),
                GFButton(
                  text: '复制',
                  type: GFButtonType.outline,
                  size: GFSize.SMALL,
                  onPressed: () {
                    // 复制文本到剪贴板
                    Get.snackbar('已复制', '内容已复制到剪贴板');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _speakContent(String text) async {
    try {
      setState(() => _isPlaying = true);
      await _ttsService.speak(text);
    } catch (e) {
      Logger.error('TTS 播放失败', error: e);
      Get.snackbar('错误', '无法播放文本');
      setState(() => _isPlaying = false);
    }
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _ttsService.stop();
      setState(() => _isPlaying = false);
    } else if (_filteredContents.isNotEmpty) {
      _currentIndex = (_currentIndex + 1) % _filteredContents.length;
      final content = _filteredContents[_currentIndex];
      await _speakContent(content['content'] as String);
    }
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }
}
