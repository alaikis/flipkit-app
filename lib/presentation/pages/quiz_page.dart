import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../services/ai_service.dart';

/// 问答页面
class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final AIService _aiService = AIService();

  String _selectedSubject = '数学';
  String _selectedDifficulty = '中等';
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _totalQuestions = 10;

  List<Map<String, dynamic>> _questions = [];
  String? _selectedAnswer;
  bool _showResult = false;
  bool _isLoading = false;

  final List<String> _subjects = AppConstants.subjects;
  final List<String> _difficulties = AppConstants.difficultyLevels;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('智能问答'),
      ),
      body: _questions.isEmpty
          ? _buildSetupScreen()
          : _buildQuizScreen(),
    );
  }

  Widget _buildSetupScreen() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '开始练习',
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI 将为您生成个性化的练习题目',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          Text('选择科目', style: Get.textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildSubjectSelector(),
          const SizedBox(height: 24),
          Text('选择难度', style: Get.textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildDifficultySelector(),
          const SizedBox(height: 24),
          Text('题目数量', style: Get.textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildQuestionCountSelector(),
          const Spacer(),
          GFButton(
            text: _isLoading ? '生成中...' : '生成题目',
            size: GFSize.LARGE,
            blockButton: true,
            onPressed: _isLoading ? null : _generateQuestions,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizScreen() {
    final currentQuestion = _questions[_currentQuestionIndex];

    return Column(
      children: [
        // 进度条
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.primary.withOpacity(0.1),
          ),
          child: Row(
            children: [
              Expanded(
                child: GFProgressBar(
                  percentage: ((_currentQuestionIndex + 1) / _questions.length) * 100,
                  lineHeight: 8,
                  backgroundColor: const Color(0xFFE0E0E0),
                  leading: Text(
                    '${_currentQuestionIndex + 1}/${_questions.length}',
                    style: Get.textTheme.bodySmall,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '得分: $_score',
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 题目标签
                Row(
                  children: [
                    Chip(
                      label: Text(currentQuestion['subject']),
                      backgroundColor: Get.theme.colorScheme.primaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(currentQuestion['difficulty']),
                      backgroundColor: Colors.orange[100],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 题目内容
                Text(
                  currentQuestion['content'],
                  style: Get.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // 选项
                if (currentQuestion['type'] == '选择题')
                  _buildOptions(currentQuestion)
                else
                  _buildAnswerInput(),

                const SizedBox(height: 24),

                // 结果反馈
                if (_showResult) _buildResult(currentQuestion),
              ],
            ),
          ),
        ),

        // 底部按钮
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_currentQuestionIndex > 0)
                Expanded(
                  child: GFButton(
                    text: '上一题',
                    type: GFButtonType.outline,
                    blockButton: true,
                    onPressed: _previousQuestion,
                  ),
                ),
              if (_currentQuestionIndex > 0) const SizedBox(width: 16),
              Expanded(
                child: GFButton(
                  text: _showResult
                      ? (_currentQuestionIndex < _questions.length - 1
                          ? '下一题'
                          : '查看结果')
                      : '提交答案',
                  size: GFSize.LARGE,
                  blockButton: true,
                  onPressed: _showResult ? _nextQuestion : _submitAnswer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _subjects.map((subject) {
        return GFButton(
          text: subject,
          type: _selectedSubject == subject
              ? GFButtonType.solid
              : GFButtonType.outline,
          color: Get.theme.colorScheme.primary,
          onPressed: () => setState(() => _selectedSubject = subject),
        );
      }).toList(),
    );
  }

  Widget _buildDifficultySelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _difficulties.map((difficulty) {
        return GFButton(
          text: difficulty,
          type: _selectedDifficulty == difficulty
              ? GFButtonType.solid
              : GFButtonType.outline,
          color: Get.theme.colorScheme.primary,
          onPressed: () => setState(() => _selectedDifficulty = difficulty),
        );
      }).toList(),
    );
  }

  Widget _buildQuestionCountSelector() {
    return Row(
      children: [
        Expanded(
          child: GFButton(
            text: '5 题',
            type: _totalQuestions == 5
                ? GFButtonType.solid
                : GFButtonType.outline,
            blockButton: true,
            onPressed: () => setState(() => _totalQuestions = 5),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GFButton(
            text: '10 题',
            type: _totalQuestions == 10
                ? GFButtonType.solid
                : GFButtonType.outline,
            blockButton: true,
            onPressed: () => setState(() => _totalQuestions = 10),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GFButton(
            text: '20 题',
            type: _totalQuestions == 20
                ? GFButtonType.solid
                : GFButtonType.outline,
            blockButton: true,
            onPressed: () => setState(() => _totalQuestions = 20),
          ),
        ),
      ],
    );
  }

  Widget _buildOptions(Map<String, dynamic> question) {
    final options = question['options'] as List<String>;

    return Column(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final optionLetter = String.fromCharCode(65 + index); // A, B, C, D

        return GFListTile(
          title: Text(option),
          avatar: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _selectedAnswer == optionLetter
                  ? Get.theme.colorScheme.primary
                  : Get.theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                optionLetter,
                style: TextStyle(
                  color: _selectedAnswer == optionLetter
                      ? Colors.white
                      : Get.theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          onTap: () => setState(() => _selectedAnswer = optionLetter),
        );
      }).toList(),
    );
  }

  Widget _buildAnswerInput() {
    return GFCard(
      content: TextField(
        decoration: const InputDecoration(
          hintText: '请输入答案',
          border: OutlineInputBorder(),
        ),
        maxLines: 5,
        onChanged: (value) => setState(() => _selectedAnswer = value),
      ),
    );
  }

  Widget _buildResult(Map<String, dynamic> question) {
    final isCorrect = _selectedAnswer == question['answer'];
    final color = isCorrect ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? '回答正确！' : '回答错误',
                style: Get.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 12),
            Text(
              '正确答案：${question['answer']}',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: color,
              ),
            ),
          ],
          if (question['explanation'] != null) ...[
            const SizedBox(height: 12),
            Text(
              '解析：${question['explanation']}',
              style: Get.textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _generateQuestions() async {
    setState(() => _isLoading = true);

    try {
      final questions = await _aiService.generateQuestions(
        subject: _selectedSubject,
        grade: '三年级',
        chapter: '第一章',
        count: _totalQuestions,
        difficulty: _selectedDifficulty,
      );

      setState(() {
        _questions = questions.map((q) {
          return {
            ...q,
            'subject': _selectedSubject,
            'difficulty': _selectedDifficulty,
          };
        }).toList();
      });
    } catch (e) {
      Get.snackbar('错误', '生成题目失败');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _submitAnswer() {
    setState(() => _showResult = true);
  }

  void _nextQuestion() {
    setState(() {
      _showResult = false;
      _selectedAnswer = null;
    });

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    } else {
      _showSummary();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _showResult = false;
        _selectedAnswer = null;
      });
    }
  }

  void _showSummary() {
    Get.defaultDialog(
      title: '练习完成',
      middleText: '得分：$_score / $_totalQuestions',
      textConfirm: '重新开始',
      textCancel: '返回首页',
      onConfirm: () {
        Get.back();
        setState(() {
          _questions = [];
          _currentQuestionIndex = 0;
          _score = 0;
          _showResult = false;
          _selectedAnswer = null;
        });
      },
      onCancel: () => Get.back(),
    );
  }
}
