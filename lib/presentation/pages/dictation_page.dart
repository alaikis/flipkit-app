import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../services/tts_service.dart';

/// 听写页面
class DictationPage extends StatefulWidget {
  const DictationPage({super.key});

  @override
  State<DictationPage> createState() => _DictationPageState();
}

class _DictationPageState extends State<DictationPage> {
  final TTSService _ttsService = TTSService();

  String _selectedSubject = '语文';
  String _selectedGrade = '三年级';
  int _currentStep = 0;

  String? _dictationText;
  String? _ocrText;
  double? _similarity;
  List<Map<String, dynamic>>? _errors;

  final List<String> _subjects = AppConstants.subjects;
  final List<String> _grades = AppConstants.gradeLevels;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('听写'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_currentStep) {
      case 0:
        return _buildSelectStep();
      case 1:
        return _buildPreviewStep();
      case 2:
        return _buildPlayStep();
      case 3:
        return _buildWriteStep();
      case 4:
        return _buildResultStep();
      default:
        return _buildSelectStep();
    }
  }

  // 步骤1：选择科目和年级
  Widget _buildSelectStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressIndicator(0),
          const SizedBox(height: 32),
          Text('选择科目', style: Get.textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildSubjectSelector(),
          const SizedBox(height: 24),
          Text('选择年级', style: Get.textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildGradeSelector(),
          const Spacer(),
          GFButton(
            text: '下一步',
            size: GFSize.LARGE,
            blockButton: true,
            onPressed: _generateDictationText,
          ),
        ],
      ),
    );
  }

  // 步骤2：预览内容
  Widget _buildPreviewStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressIndicator(1),
          const SizedBox(height: 32),
          Text('听写内容', style: Get.textTheme.titleLarge),
          const SizedBox(height: 16),
          GFCard(
            content: Text(
              _dictationText ?? '',
              style: Get.textTheme.bodyLarge,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: GFButton(
                  text: '上一步',
                  type: GFButtonType.outline,
                  blockButton: true,
                  onPressed: () => setState(() => _currentStep--),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GFButton(
                  text: '开始听写',
                  size: GFSize.LARGE,
                  blockButton: true,
                  onPressed: () => setState(() => _currentStep++),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 步骤3：播放听写
  Widget _buildPlayStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressIndicator(2),
          const SizedBox(height: 32),
          Text('正在播放', style: Get.textTheme.titleLarge),
          const SizedBox(height: 48),
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                Icons.volume_up,
                size: 80,
                color: Get.theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GFButton(
                icon: Icon(Icons.replay),
                text: '重播',
                type: GFButtonType.outline,
                onPressed: _playDictation,
              ),
              const SizedBox(width: 16),
              GFButton(
                icon: Icon(Icons.check),
                text: '开始书写',
                size: GFSize.LARGE,
                onPressed: () => setState(() => _currentStep++),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 步骤4：拍照书写
  Widget _buildWriteStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressIndicator(3),
          const SizedBox(height: 32),
          Text('拍照上传', style: Get.textTheme.titleLarge),
          const SizedBox(height: 16),
          GFCard(
            content: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '点击拍照上传手写内容',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          GFButton(
            text: '拍照',
            size: GFSize.LARGE,
            icon: Icon(Icons.camera_alt),
            blockButton: true,
            onPressed: _takePhoto,
          ),
        ],
      ),
    );
  }

  // 步骤5：显示结果
  Widget _buildResultStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressIndicator(4),
          const SizedBox(height: 32),
          _buildScoreCard(),
          const SizedBox(height: 24),
          _buildErrorTable(),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: GFButton(
                  text: '重新开始',
                  type: GFButtonType.outline,
                  blockButton: true,
                  onPressed: () => setState(() {
                    _currentStep = 0;
                    _dictationText = null;
                    _ocrText = null;
                    _similarity = null;
                    _errors = null;
                  }),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GFButton(
                  text: '完成',
                  size: GFSize.LARGE,
                  blockButton: true,
                  onPressed: () => AppRoutes.back(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(int step) {
    return GFProgressBar(
      percentage: ((step + 1) / 5) * 100,
      lineHeight: 8,
      leading: Text('${step + 1}/5', style: Get.textTheme.bodySmall),
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

  Widget _buildGradeSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _grades.map((grade) {
        return GFButton(
          text: grade,
          type: _selectedGrade == grade
              ? GFButtonType.solid
              : GFButtonType.outline,
          color: Get.theme.colorScheme.primary,
          onPressed: () => setState(() => _selectedGrade = grade),
        );
      }).toList(),
    );
  }

  Widget _buildScoreCard() {
    final score = _similarity ?? 0;
    final color = score >= 80 ? Colors.green : (score >= 60 ? Colors.orange : Colors.red);

    return Container(
      padding: const EdgeInsets.all(20),
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
            '${score.toStringAsFixed(1)}%',
            style: Get.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorTable() {
    if (_errors == null || _errors!.isEmpty) {
      return const Center(child: Text('完美！没有发现错误'));
    }

    return GFCard(
      title: const GFListTile(
        avatar: Icon(Icons.error),
        title: Text('错误分析'),
      ),
      content: ListView.separated(
        shrinkWrap: true,
        itemCount: _errors!.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final error = _errors![index];
          return ListTile(
            leading: _buildErrorIcon(error['type']),
            title: Text('第 ${error['position'] + 1} 词'),
            subtitle: Text('${error['original']} → ${error['recognized']}'),
            trailing: Chip(
              label: Text(error['type']),
              backgroundColor: Get.theme.colorScheme.errorContainer,
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorIcon(String type) {
    switch (type) {
      case 'missing':
        return const Icon(Icons.remove_circle, color: Colors.red);
      case 'extra':
        return const Icon(Icons.add_circle, color: Colors.orange);
      case 'substitution':
        return const Icon(Icons.swap_horiz, color: Colors.blue);
      case 'typo':
        return const Icon(Icons.edit, color: Colors.purple);
      default:
        return const Icon(Icons.error, color: Colors.grey);
    }
  }

  Future<void> _generateDictationText() async {
    setState(() => _currentStep = 1);

    try {
      // 使用 AI 生成听写内容
      // TODO: 调用 AI 生成听写文本
      setState(() {
        _dictationText = '春眠不觉晓，处处闻啼鸟。夜来风雨声，花落知多少。';
      });
    } catch (e) {
      Get.snackbar('错误', '生成听写内容失败');
    }
  }

  Future<void> _playDictation() async {
    if (_dictationText != null) {
      await _ttsService.speak(_dictationText!);
    }
  }

  Future<void> _takePhoto() async {
    // TODO: 实现拍照功能
    Get.snackbar('提示', '拍照功能待实现');

    // 模拟 OCR 识别
    setState(() {
      _ocrText = '春眠不觉晓，处处闻啼鸟。';
      _similarity = 85.5;
      _errors = [
        {
          'type': 'typo',
          'original': '夜来',
          'recognized': '也来',
          'position': 4,
        },
      ];
      _currentStep = 4;
    });
  }
}
