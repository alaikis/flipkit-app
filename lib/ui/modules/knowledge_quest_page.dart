import 'package:flutter/material.dart';
import '../../modules/knowledge_quest_module.dart';

class KnowledgeQuestPage extends StatefulWidget {
  final KnowledgeQuestModule module;

  const KnowledgeQuestPage({super.key, required this.module});

  @override
  State<KnowledgeQuestPage> createState() => _KnowledgeQuestPageState();
}

class _KnowledgeQuestPageState extends State<KnowledgeQuestPage> {
  String? selectedSubject;
  String? selectedChapter;
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  bool isLoading = false;

  final subjectsList = ['English', 'Chinese', 'Math'];
  final chaptersList = {
    'English': ['Unit 1', 'Unit 2', 'Unit 3'],
    'Chinese': ['第一章', '第二章', '第三章'],
    'Math': ['第一节', '第二节', '第三节'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('知乐岛')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('选择科目和章节', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: selectedSubject,
              hint: const Text('选择科目'),
              items: subjectsList.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => selectedSubject = v),
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
                onPressed: selectedChapter == null ? null : _generateQuestions,
                child: isLoading ? const Text('生成中...') : const Text('开始闯关'),
              ),
            ),
            const SizedBox(height: 24),
            if (questions.isNotEmpty) ...[
              Text(
                '第 ${currentQuestionIndex + 1}/${questions.length} 题',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),
              _buildQuestionCard(),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (currentQuestionIndex > 0)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() => currentQuestionIndex--),
                        child: const Text('上一题'),
                      ),
                    ),
                  if (currentQuestionIndex > 0) const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: currentQuestionIndex < questions.length - 1
                          ? () => setState(() => currentQuestionIndex++)
                          : null,
                      child: const Text('下一题'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard() {
    final q = questions[currentQuestionIndex];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q['question'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            ...((q['options'] as List?) ?? []).map((opt) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () => _showFeedback(opt, q['answer']),
                child: Text(opt, style: const TextStyle(color: Colors.black)),
              ),
            )),
            const SizedBox(height: 12),
            if (q['explanation'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue[50]),
                  child: Text('解释：${q['explanation']}', style: const TextStyle(fontSize: 12)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateQuestions() async {
    setState(() => isLoading = true);
    try {
      final qs = await widget.module.generateQuestions(
        subject: selectedSubject!,
        chapter: selectedChapter!,
        count: 5,
      );
      setState(() {
        questions = qs;
        currentQuestionIndex = 0;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('生成失败: $e')));
    }
  }

  void _showFeedback(String selected, String correct) {
    final isCorrect = selected.replaceAll(RegExp(r'[^\w]'), '') == correct.replaceAll(RegExp(r'[^\w]'), '');
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(isCorrect ? '正确！' : '错误'),
        content: Text(isCorrect ? '很好！' : '正确答案是：$correct'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('继续')),
        ],
      ),
    );
  }
}
