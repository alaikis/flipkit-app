import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../modules/smart_house_module.dart';

class SmartHousePage extends StatefulWidget {
  final SmartHouseModule module;

  const SmartHousePage({super.key, required this.module});

  @override
  State<SmartHousePage> createState() => _SmartHousePageState();
}

class _SmartHousePageState extends State<SmartHousePage> {
  String? selectedSubject;
  String? selectedChapter;
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  XFile? submittedImage;
  Map<String, dynamic>? gradingResult;
  bool isGrading = false;

  final subjectsList = ['English', 'Chinese', 'Math'];
  final chaptersList = {
    'English': ['Unit 1', 'Unit 2', 'Unit 3'],
    'Chinese': ['第一章', '第二章', '第三章'],
    'Math': ['第一节', '第二节', '第三节'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('聪明屋', style: GoogleFonts.notoSansSc()),
        backgroundColor: const Color(0xFFFFC107),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (questions.isEmpty) _buildChapterSelector(),
            if (questions.isNotEmpty && gradingResult == null)
              _buildQuestionInterface(),
            if (gradingResult != null) _buildGradingResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('选择科目和章节',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        DropdownButton<String>(
          value: selectedSubject,
          hint: const Text('选择科目'),
          items: subjectsList
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (v) => setState(() {
            selectedSubject = v;
            selectedChapter = null;
          }),
          isExpanded: true,
        ),
        const SizedBox(height: 12),
        if (selectedSubject != null)
          DropdownButton<String>(
            value: selectedChapter,
            hint: const Text('选择章节'),
            items: (chaptersList[selectedSubject] ?? [])
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => selectedChapter = v),
            isExpanded: true,
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: selectedChapter == null ? null : _loadQuestions,
            child: const Text('加载题目'),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionInterface() {
    final currentQuestion = questions[currentQuestionIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '第 ${currentQuestionIndex + 1}/${questions.length} 题',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            currentQuestion['content'] ?? '题目内容',
            style: const TextStyle(fontSize: 14, height: 1.6),
          ),
        ),
        const SizedBox(height: 16),
        if (submittedImage != null) ...[
          const Text('已上传的答案',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(submittedImage!.path),
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: GFButton(
            onPressed: _captureImage,
            text: '拍照上传答案',
            icon: const Icon(Icons.camera_alt),
            color: GFColors.PRIMARY,
            blockButton: true,
            size: GFSize.MEDIUM,
          ),
        ),
        const SizedBox(height: 12),
        if (submittedImage != null)
          SizedBox(
            width: double.infinity,
            child: GFButton(
              onPressed: isGrading ? null : _gradeAndShowResult,
              text: isGrading ? '评分中...' : '提交并阅卷',
              blockButton: true,
              color: const Color(0xFFFF7043),
              icon: isGrading ? const Icon(Icons.hourglass_top) : null,
            ),
          ),
      ],
    );
  }

  Future<void> _loadQuestions() async {
    // Mock: Load questions from module or database
    setState(() {
      questions = [
        {'id': '1', 'content': '请写一篇关于春节的作文，要求不少于200字。'},
        {'id': '2', 'content': '用英文介绍你最喜欢的一个地方。'},
        {'id': '3', 'content': '解释长方形和正方形的区别，并计算周长。'},
      ];
      currentQuestionIndex = 0;
    });
  }

  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        submittedImage = image;
        gradingResult = null;
      });
    }
  }

  Future<void> _gradeAndShowResult() async {
    if (submittedImage == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请先拍照上传答案')),
        );
      }
      return;
    }

    if (questions.isEmpty || currentQuestionIndex >= questions.length) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('没有可评分的问题')),
        );
      }
      return;
    }

    setState(() => isGrading = true);

    try {
      final currentQuestion = questions[currentQuestionIndex];
      final result = await widget.module.gradeEssaySubmission(
        questionContent: currentQuestion['content'] ?? '',
        submissionImageFile: File(submittedImage!.path),
        modelId: 'default',
      );

      if (mounted) {
        setState(() => gradingResult = result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('评分失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isGrading = false);
      }
    }
  }

  Widget _buildGradingResult() {
    if (gradingResult == null) return const SizedBox.shrink();

    final num rawScore = gradingResult!['score'] ?? 0;
    final num rawMax = gradingResult!['maxScore'] ?? 100;
    final score = rawScore.toDouble();
    final maxScore = rawMax.toDouble();
    final recognizedText = gradingResult!['recognizedText'] as String? ?? '';
    final strengths =
        (gradingResult!['strengths'] as List?)?.cast<String>() ?? [];
    final weaknesses =
        (gradingResult!['weaknesses'] as List?)?.cast<String>() ?? [];
    final correctionExplanation =
        gradingResult!['correctionExplanation'] as String? ?? '';
    final videoKeywords =
        (gradingResult!['videoSearchKeywords'] as List?)?.cast<String>() ?? [];
    final num g = gradingResult!['grammarScore'] ?? 0;
    final grammarScore = g.toDouble();
    final num cr = gradingResult!['contentRelevance'] ?? 0;
    final contentRelevance = cr.toDouble();
    final plagiarismCheck = gradingResult!['plagiarismCheck'] as String? ?? 'Unknown';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Playful header with illustration
          GFCard(
            color: const Color(0xFFFFF8E1),
            boxFit: BoxFit.cover,
            content: Row(
              children: [
                SvgPicture.asset('assets/illustrations/smiley_sun.svg', width: 72, height: 72),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('评分结果', style: GoogleFonts.notoSansSc(fontSize: 14, color: Colors.grey[700])),
                    Text(
                      '${(score / maxScore * 100).toStringAsFixed(1)}%',
                      style: GoogleFonts.notoSansSc(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                    ),
                    Text('$score/$maxScore 分', style: GoogleFonts.notoSansSc(fontSize: 14, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Grammar score
          const Text('语法分数',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('$grammarScore/100',
              style: const TextStyle(fontSize: 13, height: 1.6)),
          const SizedBox(height: 16),

          // Content relevance
          const Text('内容相关性',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('$contentRelevance/100',
              style: const TextStyle(fontSize: 13, height: 1.6)),
          const SizedBox(height: 16),

          // Plagiarism check
          const Text('抄袭检查',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(plagiarismCheck,
              style: const TextStyle(fontSize: 13, height: 1.6)),
          const SizedBox(height: 16),

          // OCR recognized text
          const Text('识别文本',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              recognizedText.isEmpty ? '[未识别到文本]' : recognizedText,
              style: const TextStyle(fontSize: 13, height: 1.6),
            ),
          ),
          const SizedBox(height: 16),

          // Strengths
          if (strengths.isNotEmpty) ...[
            const Text('✓ 优点',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                )),
            const SizedBox(height: 8),
            ...strengths.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      )),
                  Expanded(child: Text(s, style: const TextStyle(fontSize: 13))),
                ],
              ),
            )),
            const SizedBox(height: 12),
          ],

          // Weaknesses
          if (weaknesses.isNotEmpty) ...[
            const Text('○ 需要改进',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                )),
            const SizedBox(height: 8),
            ...weaknesses.map((w) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      )),
                  Expanded(child: Text(w, style: const TextStyle(fontSize: 13))),
                ],
              ),
            )),
            const SizedBox(height: 12),
          ],

          // Correction explanation
          if (correctionExplanation.isNotEmpty) ...[
            const Text('✎ 详细解释',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(correctionExplanation,
                  style: const TextStyle(fontSize: 13, height: 1.6)),
            ),
            const SizedBox(height: 12),
          ],

          // Video recommendations
          if (videoKeywords.isNotEmpty) ...[
            const Text('📺 推荐学习视频',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: videoKeywords.map((kw) {
                return Chip(
                  label: Text(kw),
                  backgroundColor: Colors.blue[100],
                  labelStyle: TextStyle(color: Colors.blue[900]),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GFButton(
                onPressed: _goToPreviousQuestion,
                text: '上一题',
                size: GFSize.MEDIUM,
              ),
              GFButton(
                onPressed: _startOver,
                text: '重新开始',
                icon: const Icon(Icons.refresh),
                color: GFColors.SUCCESS,
              ),
              GFButton(
                onPressed: currentQuestionIndex < questions.length - 1
                    ? _goToNextQuestion
                    : null,
                text: '下一题',
                size: GFSize.MEDIUM,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _goToPreviousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        submittedImage = null;
        gradingResult = null;
      });
    }
  }

  void _goToNextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        submittedImage = null;
        gradingResult = null;
      });
    }
  }

  void _startOver() {
    setState(() {
      selectedSubject = null;
      selectedChapter = null;
      questions.clear();
      currentQuestionIndex = 0;
      submittedImage = null;
      gradingResult = null;
    });
  }
}
