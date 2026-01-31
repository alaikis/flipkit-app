import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../modules/dictation_module.dart';

class DictationPage extends StatefulWidget {
  final DictationModule module;
  
  const DictationPage({super.key, required this.module});

  @override
  State<DictationPage> createState() => _DictationPageState();
}

class _DictationPageState extends State<DictationPage> {
  late DictationModule _module;

  String? selectedSubject;
  String? selectedChapter;
  String? dictationText;
  XFile? capturedImage;
  Map<String, dynamic>? evaluationResult;

  bool isLoading = false;
  bool isPlaying = false;
  bool isEvaluating = false;

  enum DictationStage { selectChapter, viewText, playback, capture, evaluate, result }
  DictationStage currentStage = DictationStage.selectChapter;

  @override
  Widget build(BuildContext context) {
      _module = widget.module;
    return Scaffold(
      appBar: AppBar(
        title: const Text('你播我写'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressIndicator(),
            const SizedBox(height: 24),
            _buildCurrentStageWidget(),
          ],
        ),
      ),
    );

    Widget _buildProgressIndicator() {
      final stages = [
        ('选择', DictationStage.selectChapter),
        ('预览', DictationStage.viewText),
        ('播放', DictationStage.playback),
        ('拍照', DictationStage.capture),
        ('评估', DictationStage.evaluate),
        ('结果', DictationStage.result),
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('学习进度', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: stages.map((stage) {
                final isActive = currentStage.index >= stage.$2.index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Chip(
                    label: Text(stage.$1),
                    backgroundColor: isActive ? Colors.blue : Colors.grey[300],
                    labelStyle: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    }

    Widget _buildCurrentStageWidget() {
      switch (currentStage) {
        case DictationStage.selectChapter:
          return _buildChapterSelector();
        case DictationStage.viewText:
          return _buildTextDisplay();
        case DictationStage.playback:
          return _buildPlaybackControl();
        case DictationStage.capture:
          return _buildCameraCapture();
        case DictationStage.evaluate:
          return _buildEvaluationWidget();
        case DictationStage.result:
          return _buildResultDisplay();
      }
    }

    Widget _buildChapterSelector() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('选择科目', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          DropdownButton<String>(
            isExpanded: true,
            value: selectedSubject,
            hint: const Text('选择科目'),
            items: _module.getSubjects().map((s) {
              return DropdownMenuItem(value: s, child: Text(s));
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedSubject = value;
                selectedChapter = null;
                dictationText = null;
              });
            },
          ),
          if (selectedSubject != null) ...[
            const SizedBox(height: 20),
            const Text('选择章节', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedChapter,
              hint: const Text('选择章节'),
              items: _module.getChapters(selectedSubject!).map((c) {
                return DropdownMenuItem(value: c, child: Text(c));
              }).toList(),
              onChanged: (value) {
                setState(() => selectedChapter = value);
              },
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedChapter == null ? null : _loadAndPreview,
              child: const Text('开始听写'),
            ),
          ),
        ],
      );
    }

    Widget _buildTextDisplay() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('听写内容', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(8),
              color: Colors.blue[50],
            ),
            child: Text(
              dictationText ?? '',
              style: const TextStyle(fontSize: 16, height: 1.8, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => currentStage = DictationStage.playback),
              child: const Text('开始播放'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => setState(() => currentStage = DictationStage.selectChapter),
              child: const Text('返回选择'),
            ),
          ),
        ],
      );
    }

    Widget _buildPlaybackControl() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('播放听写内容', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 24),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue[50],
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: isPlaying
                  ? const Icon(Icons.volume_up, size: 48, color: Colors.blue)
                  : const Icon(Icons.volume_mute, size: 48, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _playDictation,
              icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
              label: Text(isPlaying ? '停止' : '播放'),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text('点击播放按钮开始听听写内容', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => currentStage = DictationStage.capture),
              child: const Text('开始拍照'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => setState(() => currentStage = DictationStage.viewText),
              child: const Text('返回预览'),
            ),
          ),
        ],
      );
    }

    Widget _buildCameraCapture() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('拍照上传答案', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
            ),
            child: capturedImage == null
                ? const Center(
                    child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                  )
                : Image.file(
                    File(capturedImage!.path),
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _captureImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('拍照'),
            ),
          ),
          const SizedBox(height: 12),
          if (capturedImage != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _evaluateDictation,
                child: const Text('开始评估'),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => setState(() => currentStage = DictationStage.playback),
              child: const Text('返回播放'),
            ),
          ),
        ],
      );
    }

    Widget _buildEvaluationWidget() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('正在评估...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 24),
          const Center(
            child: CircularProgressIndicator(),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text('正在处理您的拍照...', style: TextStyle(color: Colors.grey)),
          ),
        ],
      );
    }

    Widget _buildResultDisplay() {
      if (evaluationResult == null) {
        return const SizedBox.shrink();
      }

      final score = evaluationResult!['score'] as double? ?? 0.0;
      final ocrText = evaluationResult!['ocrText'] as String? ?? '';
      final errors = (evaluationResult!['errors'] as List?) ?? [];
      final feedback = evaluationResult!['feedback'] as String? ?? '';
      final suggestions = (evaluationResult!['suggestions'] as List?)?.cast<String>() ?? [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: score >= 80 ? Colors.green[50] : score >= 60 ? Colors.orange[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: score >= 80 ? Colors.green : score >= 60 ? Colors.orange : Colors.red,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('您的成绩', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(
                      '${score.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                ),
                Icon(
                  score >= 80 ? Icons.check_circle : score >= 60 ? Icons.info : Icons.cancel,
                  size: 56,
                  color: score >= 80 ? Colors.green : score >= 60 ? Colors.orange : Colors.red,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('识别文本', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(ocrText, style: const TextStyle(fontSize: 13, height: 1.6)),
          ),
          const SizedBox(height: 20),
          if (errors.isNotEmpty) ...[
            const Text('错误分析', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('位置')),
                  DataColumn(label: Text('原文')),
                  DataColumn(label: Text('识别')),
                  DataColumn(label: Text('错误类型')),
                ],
                rows: (errors as List)
                    .cast<Map<String, dynamic>>()
                    .map((e) => DataRow(cells: [
                          DataCell(Text(e['position'].toString())),
                          DataCell(Text(e['original'] ?? '')),
                          DataCell(Text(e['recognized'] ?? '')),
                          DataCell(Chip(label: Text(e['type'] ?? ''))),
                        ]))
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (feedback.isNotEmpty) ...[
            const Text('评价', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(feedback, style: const TextStyle(fontSize: 13, height: 1.6)),
            ),
            const SizedBox(height: 20),
          ],
          if (suggestions.isNotEmpty) ...[
            const Text('改进建议', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            ...suggestions.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(s, style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                )),
            const SizedBox(height: 20),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _resetDictation,
              child: const Text('重新开始'),
            ),
          ),
        ],
      );
    }

    Future<void> _loadAndPreview() async {
      setState(() => isLoading = true);
      try {
        final content = await _module.loadDictationContent(selectedSubject!, selectedChapter!);
        setState(() {
          dictationText = content;
          currentStage = DictationStage.viewText;
        });
      } finally {
        setState(() => isLoading = false);
      }
    }

    Future<void> _playDictation() async {
      if (dictationText == null) return;

      if (isPlaying) {
        await _module.stopPlayback();
        setState(() => isPlaying = false);
      } else {
        await _module.playDictation(dictationText!);
        setState(() => isPlaying = true);
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() => isPlaying = false);
          }
        });
      }
    }

    Future<void> _captureImage() async {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() => capturedImage = image);
      }
    }

    Future<void> _evaluateDictation() async {
      if (capturedImage == null || dictationText == null) return;

      setState(() {
        currentStage = DictationStage.evaluate;
        isEvaluating = true;
      });

      try {
        final result = await _module.evaluateDictation(
          originalText: dictationText!,
          userImageFile: File(capturedImage!.path),
        );
        setState(() {
          evaluationResult = result;
          currentStage = DictationStage.result;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('评估失败: $e')),
          );
          setState(() => currentStage = DictationStage.capture);
        }
      } finally {
        setState(() => isEvaluating = false);
      }
    }

    void _resetDictation() {
      setState(() {
        selectedSubject = null;
        selectedChapter = null;
        dictationText = null;
        capturedImage = null;
        evaluationResult = null;
        currentStage = DictationStage.selectChapter;
      });
    }
  }

  Widget _buildEvaluationResult() {
  @override
  void dispose() {
    super.dispose();
  }
}
