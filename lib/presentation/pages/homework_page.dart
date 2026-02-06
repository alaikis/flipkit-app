import 'dart:io';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../services/ocr_service.dart';
import '../../services/ai_service.dart';

/// 作业页 - 合并「拍照作业」与「语音/文字描述题目」，根据内容生成习题
class HomeworkPage extends StatefulWidget {
  const HomeworkPage({super.key});

  @override
  State<HomeworkPage> createState() => _HomeworkPageState();
}

class _HomeworkPageState extends State<HomeworkPage> {
  final OCRService _ocrService = OCRService();
  final AIService _aiService = AIService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _descController = TextEditingController();

  String _selectedGrade = AppConstants.gradeLevels.first;
  int _step = 0; // 0=选择方式, 1=拍照/输入, 2=生成中, 3=做题/结果
  String _inputText = '';
  String? _photoPath;
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _questions = [];
  int _currentQ = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _showResult = false;

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('作业'),
      ),
      body: _step == 0
          ? _buildModeSelect()
          : _step == 1
              ? _buildInputStep()
              : _step == 2
                  ? _buildLoading()
                  : _buildQuizOrDone(),
    );
  }

  /// 选择方式：拍照 or 文字/语音描述
  Widget _buildModeSelect() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '选择作业内容来源',
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildModeCard(
            icon: Icons.camera_alt,
            title: '拍照作业',
            subtitle: '拍摄学校作业或题目，自动识别并生成练习',
            color: Colors.blue,
            onTap: () => setState(() {
              _step = 1;
              _photoPath = null;
              _inputText = '';
              _descController.clear();
            }),
          ),
          const SizedBox(height: 16),
          _buildModeCard(
            icon: Icons.mic_none,
            title: '语音/文字描述',
            subtitle: '用文字描述作业要求或题目，生成对应习题',
            color: Colors.green,
            onTap: () => setState(() {
              _step = 1;
              _photoPath = null;
              _inputText = '';
              _descController.clear();
            }),
          ),
          const SizedBox(height: 32),
          Text('选择年级（用于题目难度）', style: Get.textTheme.titleMedium),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: AppConstants.gradeLevels.map((g) {
                final selected = _selectedGrade == g;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GFButton(
                    text: g,
                    type: selected ? GFButtonType.solid : GFButtonType.outline,
                    size: GFSize.SMALL,
                    onPressed: () => setState(() => _selectedGrade = g),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Get.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputStep() {
    final isPhotoMode = _photoPath == null && _inputText.isEmpty;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _step = 0),
              ),
              Text(
                isPhotoMode ? '拍照作业' : '描述作业内容',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_photoPath != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_photoPath!),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            GFButton(
              text: '重新拍照',
              type: GFButtonType.outline,
              onPressed: _takePhoto,
            ),
            const SizedBox(height: 16),
            const Text('识别结果（可编辑）：', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                maxLines: null,
                controller: _descController,
                decoration: const InputDecoration(
                  hintText: '识别出的文字将显示在这里',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _inputText = v),
              ),
            ),
          ] else ...[
            const Text(
              '描述作业要求或题目内容，例如：\n「三年级数学，两位数加减法」或「语文课后第三题生字听写」',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                maxLines: null,
                controller: _descController,
                decoration: const InputDecoration(
                  hintText: '输入作业描述或题目要求...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _inputText = v),
              ),
            ),
            const SizedBox(height: 12),
            GFButton(
              text: '拍照识别',
              icon: const Icon(Icons.camera_alt),
              type: GFButtonType.outline,
              blockButton: true,
              onPressed: _takePhoto,
            ),
          ],
          const SizedBox(height: 16),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          GFButton(
            text: '生成习题',
            size: GFSize.LARGE,
            blockButton: true,
            onPressed: (_inputText.trim().isEmpty) ? null : _generateFromContent,
          ),
        ],
      ),
    );
  }

  Future<void> _takePhoto() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.camera);
    if (file == null) return;
    setState(() {
      _photoPath = file.path;
      _isLoading = true;
      _error = null;
    });
    try {
      final text = await _ocrService.recognizeText(file.path);
      setState(() {
        _inputText = text;
        _descController.text = text;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _inputText = '识别失败，请手动输入或重拍。';
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _generateFromContent() async {
    final content = _descController.text.trim();
    if (content.isEmpty) {
      Get.snackbar('提示', '请先拍照或输入作业描述');
      return;
    }
    setState(() {
      _step = 2;
      _isLoading = true;
      _error = null;
    });
    try {
      final list = await _aiService.generateQuestions(
        subject: '综合',
        grade: _selectedGrade,
        chapter: '根据以下作业内容出题：\n$content',
        count: 5,
        difficulty: '中等',
        type: '选择题',
      );
      setState(() {
        _questions = list;
        _step = 3;
        _currentQ = 0;
        _score = 0;
        _selectedAnswer = null;
        _showResult = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _step = 1;
        _error = '生成失败：$e';
      });
      Get.snackbar('生成失败', '$e');
    }
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('正在根据作业内容生成习题...'),
        ],
      ),
    );
  }

  Widget _buildQuizOrDone() {
    if (_questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            const Text('暂无题目'),
            GFButton(
              text: '返回',
              onPressed: () => setState(() => _step = 0),
            ),
          ],
        ),
      );
    }
    if (_currentQ >= _questions.length) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '得分：$_score / ${_questions.length * 100}',
              style: Get.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            GFButton(
              text: '再练一次',
              onPressed: () => setState(() {
                _currentQ = 0;
                _score = 0;
                _selectedAnswer = null;
                _showResult = false;
              }),
            ),
            const SizedBox(height: 8),
            GFButton(
              text: '返回作业',
              type: GFButtonType.outline,
              onPressed: () => setState(() => _step = 0),
            ),
          ],
        ),
      );
    }
    final q = _questions[_currentQ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '第 ${_currentQ + 1} / ${_questions.length} 题',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            q['content'] ?? '',
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (q['type'] == '选择题' && q['options'] != null)
            ...List<Widget>.from((q['options'] as List).map((opt) {
              final optStr = opt.toString();
              final selected = _selectedAnswer == optStr;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GFButton(
                  text: optStr,
                  type: selected ? GFButtonType.solid : GFButtonType.outline,
                  blockButton: true,
                  onPressed: _showResult
                      ? null
                      : () => setState(() => _selectedAnswer = optStr),
                ),
              );
            })),
          if (_showResult) ...[
            const SizedBox(height: 12),
            Text(
              '正确答案：${q['answer']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              if (_currentQ > 0)
                Expanded(
                  child: GFButton(
                    text: '上一题',
                    type: GFButtonType.outline,
                    onPressed: () => setState(() {
                      _currentQ--;
                      _selectedAnswer = null;
                      _showResult = false;
                    }),
                  ),
                ),
              if (_currentQ > 0) const SizedBox(width: 16),
              Expanded(
                child: GFButton(
                  text: _showResult
                      ? (_currentQ < _questions.length - 1 ? '下一题' : '完成')
                      : '提交',
                  onPressed: () {
                    if (_showResult) {
                      if (_currentQ < _questions.length - 1) {
                        setState(() {
                          _currentQ++;
                          _selectedAnswer = null;
                          _showResult = false;
                        });
                      } else {
                        setState(() => _currentQ = _questions.length);
                      }
                    } else {
                      final correct = _selectedAnswer == q['answer'];
                      if (correct) setState(() => _score += 100);
                      setState(() => _showResult = true);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
