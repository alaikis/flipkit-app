import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/child_theme_transitions.dart';

/// 道德与法治页面
class MoralityPage extends StatefulWidget {
  const MoralityPage({super.key});

  @override
  State<MoralityPage> createState() => _MoralityPageState();
}

class _MoralityPageState extends State<MoralityPage> {
  String _selectedSubject = '道德';
  String _selectedGrade = '三年级';
  String _selectedTopic = '诚信';
  int _currentStep = 0;

  String? _questionText;
  String? _studentAnswer;
  Map<String, dynamic>? _evaluationResult;
  bool _isAnalyzing = false;

  final List<String> _subjects = [
    '道德',
    '法治',
  ];

  final List<String> _topics = [
    '诚信',
    '友善',
    '孝敬',
    '爱国',
    '责任',
    '正义',
  ];

  final List<String> _grades = AppConstants.gradeLevels;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('道德与法治'),
        actions: [
          if (_currentStep > 0)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _reset,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_currentStep) {
      case 0:
        return _buildSelectStep();
      case 1:
        return _buildQuestionStep();
      case 2:
        return _buildAnswerStep();
      case 3:
        return _buildResultStep();
      default:
        return _buildSelectStep();
    }
  }

  Widget _buildSelectStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ChildTheme.grassGreen, ChildTheme.skyBlue],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.auto_awesome, color: Colors.white, size: 40),
                SizedBox(height: 12),
                Text(
                  '选择学习内容',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ).animate().slideY(begin: 50, end: 0),

          const SizedBox(height: 24),

          _buildSectionTitle('选择科目'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _subjects.map((subject) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedSubject == subject ? ChildTheme.grassGreen : Colors.white,
                  foregroundColor: _selectedSubject == subject ? Colors.white : ChildTheme.grassGreen,
                ),
                onPressed: () => setState(() => _selectedSubject = subject),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(subject),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          _buildSectionTitle('学习主题'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _topics.map((topic) {
              final topicEmojis = {
                '诚信': '💖',
                '友善': '🤝',
                '孝敬': '👨‍👩‍👦',
                '爱国': '🇨🇳',
                '责任': '💪',
                '正义': '⚖️',
              };
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedTopic == topic ? ChildTheme.sunshineYellow : Colors.white,
                  foregroundColor: _selectedTopic == topic ? Colors.white : ChildTheme.sunshineYellow,
                ),
                onPressed: () => setState(() => _selectedTopic = topic),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text('${topicEmojis[topic] ?? ''} $topic'),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          _buildSectionTitle('选择年级'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _grades.map((grade) {
              final isSelected = _selectedGrade == grade;
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? ChildTheme.cottonPink : Colors.white,
                  foregroundColor: isSelected ? Colors.white : ChildTheme.cottonPink,
                ),
                onPressed: () => setState(() => _selectedGrade = grade),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(grade),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ChildTheme.sunshineYellow,
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              onPressed: _generateQuestion,
              child: const Text(
                '生成题目',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ChildTheme.sunshineYellow.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.lightbulb, color: ChildTheme.sunshineYellow),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _questionText ?? '加载中...',
                          style: Get.textTheme.headlineSmall?.copyWith(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildTag(_selectedSubject, ChildTheme.grassGreen),
                      _buildTag(_selectedGrade, ChildTheme.cottonPink),
                      _buildTag(_selectedTopic, ChildTheme.sunshineYellow),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ChildTheme.skyBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => setState(() => _currentStep--),
                  child: const Text('返回'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ChildTheme.grassGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => setState(() => _currentStep++),
                  child: const Text('开始回答'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.quiz, color: ChildTheme.skyBlue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '题目：$_questionText',
                          style: Get.textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ChildTheme.sunshineYellow,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('朗读'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('你的答案'),
                  const SizedBox(height: 12),
                  TextField(
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: '请输入你的想法或答案...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => _studentAnswer = value,
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ChildTheme.skyBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => setState(() => _currentStep--),
                  child: const Text('返回'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ChildTheme.grassGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _submitAnswer,
                  child: const Text('提交答案'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultStep() {
    if (_evaluationResult == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final score = _evaluationResult!['score'] as int? ?? 0;
    final maxScore = _evaluationResult!['max_score'] as int? ?? 100;
    final percentage = score / maxScore;
    final gradeColor = percentage >= 0.8 ? ChildTheme.grassGreen
                      : percentage >= 0.6 ? ChildTheme.sunshineYellow : ChildTheme.cottonPink;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                gradeColor.withOpacity(0.8),
                gradeColor.withOpacity(0.6),
              ]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: gradeColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text('得分', style: const TextStyle(color: Colors.white70, fontSize: 18)),
                const SizedBox(height: 8),
                Text('$score/$maxScore', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${(percentage * 100).toInt()}%', style: const TextStyle(color: Colors.white70, fontSize: 24, fontWeight: FontWeight.w600)),
              ],
            ),
          ).animate().scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0)),

          const SizedBox(height: 24),

          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('评价反馈'),
                  const SizedBox(height: 16),
                  Text(_evaluationResult!['feedback'] as String? ?? '做得很好！', style: Get.textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  if (_evaluationResult!['points'] != null) ...[
                    _buildSectionTitle('优点'),
                    const SizedBox(height: 12),
                    ...(_evaluationResult!['points'] as List<String>).map((point) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: ChildTheme.grassGreen, size: 24),
                              const SizedBox(width: 12),
                              Expanded(child: Text(point, style: Get.textTheme.bodyMedium)),
                            ],
                          ),
                        )),
                    const SizedBox(height: 20),
                  ],
                  if (_evaluationResult!['suggestions'] != null) ...[
                    _buildSectionTitle('改进建议'),
                    const SizedBox(height: 12),
                    ...(_evaluationResult!['suggestions'] as List<String>).map((suggestion) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb, color: ChildTheme.sunshineYellow, size: 24),
                              const SizedBox(width: 12),
                              Expanded(child: Text(suggestion, style: Get.textTheme.bodyMedium)),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ChildTheme.skyBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _reset,
                  child: const Text('重新开始'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ChildTheme.grassGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => AppRoutes.toHome(),
                  child: const Text('完成'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: ChildTheme.skyBlue),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }

  Future<void> _generateQuestion() async {
    setState(() => _isAnalyzing = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _questionText = '$_selectedSubject - $_selectedTopic：作为一名小学生，你认为什么是诚信？请结合你的实际经历谈谈你的理解。';
      _currentStep = 1;
      _isAnalyzing = false;
    });
  }

  Future<void> _submitAnswer() async {
    if (_studentAnswer == null || _studentAnswer!.isEmpty) {
      Get.snackbar('提示', '请先输入答案');
      return;
    }

    setState(() => _isAnalyzing = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _evaluationResult = {
        'score': 85,
        'max_score': 100,
        'feedback': '答案内容充实，能结合实际经历进行分析，有自己独立的思考。建议多举例说明。',
        'points': ['理解准确', '表达清晰', '联系实际'],
        'suggestions': ['可以增加更多具体的例子', '引用相关名言警句会更好'],
      };
      _currentStep = 3;
      _isAnalyzing = false;
    });
  }

  void _reset() {
    setState(() {
      _currentStep = 0;
      _questionText = null;
      _studentAnswer = null;
      _evaluationResult = null;
    });
  }
}
