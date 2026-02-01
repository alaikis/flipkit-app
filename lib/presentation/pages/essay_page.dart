import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../services/ai_service.dart';
import '../../services/ocr_service.dart';

/// 作文页面
class EssayPage extends StatefulWidget {
  const EssayPage({super.key});

  @override
  State<EssayPage> createState() => _EssayPageState();
}

class _EssayPageState extends State<EssayPage> {
  final AIService _aiService = AIService();
  final OCRService _ocrService = OCRService();

  String _selectedSubject = '语文';
  String _selectedGrade = '三年级';
  int _currentStep = 0;

  String? _essayQuestion;
  String? _ocrText;
  Map<String, dynamic>? _gradingResult;

  final List<String> _subjects = ['语文', '英语'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('作文评分'),
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
        return _buildUploadStep();
      case 3:
        return _buildResultStep();
      default:
        return _buildSelectStep();
    }
  }

  Widget _buildSelectStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '作文评分',
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI 将为您智能评分并提供详细反馈',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          Text('选择科目', style: Get.textTheme.titleLarge),
          const SizedBox(height: 16),
          Wrap(
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
          ),
          const Spacer(),
          GFButton(
            text: '生成题目',
            size: GFSize.LARGE,
            blockButton: true,
            onPressed: _generateQuestion,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '作文题目',
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GFCard(
            content: Text(
              _essayQuestion ?? '',
              style: Get.textTheme.bodyLarge,
            ),
          ),
          const Spacer(),
          GFButton(
            text: '开始写作',
            size: GFSize.LARGE,
            blockButton: true,
            onPressed: () => setState(() => _currentStep++),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '上传作文',
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GFCard(
            content: InkWell(
              onTap: _takePhoto,
              child: Column(
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '点击拍照上传手写作文',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          GFButton(
            text: '或输入文本',
            type: GFButtonType.outline,
            blockButton: true,
            onPressed: _inputText,
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildResultStep() {
    if (_gradingResult == null) {
      return const Center(child: GFLoader());
    }

    final score = _gradingResult!['score'] ?? 0;
    final maxScore = _gradingResult!['max_score'] ?? 100;
    final percentage = (score / maxScore * 100);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分数卡片
          _buildScoreCard(score.toDouble(), maxScore.toDouble(), percentage),
          const SizedBox(height: 24),

          // 总体评价
          GFCard(
            title: const Text('总体评价'),
            content: Text(
              _gradingResult!['overall_feedback'] ?? '',
              style: Get.textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 16),

          // 优点
          GFCard(
            title: const Text('优点'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (_gradingResult!['strengths'] as List?)
                      ?.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.green, size: 20),
                                const SizedBox(width: 8),
                                Expanded(child: Text(s)),
                              ],
                            ),
                          ))
                      .toList() ??
                  [],
            ),
          ),
          const SizedBox(height: 16),

          // 不足
          GFCard(
            title: const Text('不足'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (_gradingResult!['weaknesses'] as List?)
                      ?.map((w) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.cancel, color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Expanded(child: Text(w)),
                              ],
                            ),
                          ))
                      .toList() ??
                  [],
            ),
          ),
          const SizedBox(height: 16),

          // 修改建议
          GFCard(
            title: const Text('修改建议'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (_gradingResult!['correction_suggestions'] as List?)
                      ?.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.lightbulb,
                                    color: Colors.orange, size: 20),
                                const SizedBox(width: 8),
                                Expanded(child: Text(s)),
                              ],
                            ),
                          ))
                      .toList() ??
                  [],
            ),
          ),
          const SizedBox(height: 24),

          // 按钮
          Row(
            children: [
              Expanded(
                child: GFButton(
                  text: '重新开始',
                  type: GFButtonType.outline,
                  blockButton: true,
                  onPressed: () => setState(() {
                    _currentStep = 0;
                    _essayQuestion = null;
                    _ocrText = null;
                    _gradingResult = null;
                  }),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GFButton(
                  text: '完成',
                  size: GFSize.LARGE,
                  blockButton: true,
                  onPressed: () => Get.back(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(double score, double maxScore, double percentage) {
    Color color;
    if (percentage >= 90) {
      color = Colors.green;
    } else if (percentage >= 60) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.8),
            color.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '得分',
            style: Get.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            '$score / $maxScore',
            style: Get.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateQuestion() async {
    try {
      // TODO: 调用 AI 生成作文题目
      setState(() {
        _essayQuestion = '题目：我的梦想\n\n要求：\n1. 字数不少于300字\n2. 内容真实，感情真挚\n3. 条理清晰，语句通顺';
        _currentStep = 1;
      });
    } catch (e) {
      Get.snackbar('错误', '生成题目失败');
    }
  }

  Future<void> _takePhoto() async {
    // TODO: 实现拍照功能
    Get.snackbar('提示', '拍照功能待实现');

    // 模拟 OCR 和评分
    setState(() {
      _ocrText = '我的梦想是成为一名科学家...\n';
      _gradingResult = {
        'score': 85,
        'max_score': 100,
        'overall_feedback': '这篇作文整体表现良好，内容充实，感情真挚。',
        'strengths': ['内容充实', '感情真挚', '条理清晰'],
        'weaknesses': ['部分语句可以更加优美', '词汇量可以更加丰富'],
        'correction_suggestions': ['多读优秀作文，积累优美词句', '注意运用修辞手法'],
      };
      _currentStep = 3;
    });
  }

  Future<void> _inputText() async {
    // TODO: 实现文本输入
    Get.snackbar('提示', '文本输入功能待实现');
  }
}
