import 'package:flutter/material.dart';
import '../../data/app_db.dart';
import '../../services/learning_space_service.dart';

class LearningRecordsPage extends StatefulWidget {
  final LearningSpaceService spaceService;
  final String? activeSpaceId;

  const LearningRecordsPage({
    super.key,
    required this.spaceService,
    this.activeSpaceId,
  });

  @override
  State<LearningRecordsPage> createState() => _LearningRecordsPageState();
}

class _LearningRecordsPageState extends State<LearningRecordsPage> {
  late LearningSpaceService _spaceService;
  String? _activeSpaceId;

  @override
  void initState() {
    super.initState();
    _spaceService = widget.spaceService;
    _activeSpaceId = widget.activeSpaceId;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '学习记录',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 24),
          _buildProgressCard(
            title: '整体进度',
            icon: Icons.trending_up,
            value: '68%',
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          const Text(
            '各科目进度',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _buildSubjectProgress('语文', 75, Colors.red),
          const SizedBox(height: 12),
          _buildSubjectProgress('英语', 62, Colors.green),
          const SizedBox(height: 12),
          _buildSubjectProgress('数学', 68, Colors.orange),
          const SizedBox(height: 24),
          const Text(
            '最近学习',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _buildRecentRecord('你播我写', '第五章：常用词汇', '2分钟前', '85%'),
          const SizedBox(height: 8),
          _buildRecentRecord('知乐岛', '第二节：语法练习', '1小时前', '7/10'),
          const SizedBox(height: 8),
          _buildRecentRecord('聪明屋', '应用题训练', '昨天', '82分'),
          const SizedBox(height: 24),
          const Text(
            '学习统计',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('本周学习', '5天', Colors.blue),
              _buildStatCard('累计时长', '12.5小时', Colors.purple),
              _buildStatCard('完成题目', '48个', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard({
    required String title,
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          Icon(icon, size: 48, color: color),
        ],
      ),
    );
  }

  Widget _buildSubjectProgress(String subject, int percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(subject, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            Text('$percentage%', style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentRecord(String module, String content, String time, String result) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(module, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(content, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(time, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              result,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color[200]!),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
