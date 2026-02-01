import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';

/// 主页
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlipKit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => AppRoutes.toSettings(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 欢迎卡片
            _buildWelcomeCard(),

            const SizedBox(height: 24),

            // 学习模块
            _buildSectionTitle('学习模块'),
            const SizedBox(height: 16),
            _buildLearningModules(),

            const SizedBox(height: 24),

            // 学习统计
            _buildSectionTitle('今日学习'),
            const SizedBox(height: 16),
            _buildLearningStats(),

            const SizedBox(height: 24),

            // 资源推荐
            _buildSectionTitle('资源推荐'),
            const SizedBox(height: 16),
            _buildResourceRecommendation(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Get.theme.colorScheme.primary,
            Get.theme.colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '你好，同学！',
                  style: Get.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '今天也要加油学习哦！',
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.emoji_events,
            color: Colors.white,
            size: 48,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Get.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildLearningModules() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildModuleCard(
          icon: Icons.hearing,
          title: '听写',
          color: Color(0xFF2196F3),
          onTap: () => AppRoutes.toDictation(),
        ),
        _buildModuleCard(
          icon: Icons.quiz,
          title: '问答',
          color: Color(0xFFFF9800),
          onTap: () => AppRoutes.toQuiz(),
        ),
        _buildModuleCard(
          icon: Icons.edit_note,
          title: '作文',
          color: Color(0xFF4CAF50),
          onTap: () => AppRoutes.toEssay(),
        ),
        _buildModuleCard(
          icon: Icons.auto_stories,
          title: '道法',
          color: Color(0xFF9C27B0),
          onTap: () => AppRoutes.toDaoism(),
        ),
        _buildModuleCard(
          icon: Icons.folder_open,
          title: '资源',
          color: Color(0xFF9C27B0),
          onTap: () => AppRoutes.toResources(),
        ),
      ],
    );
  }

  Widget _buildModuleCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GFCard(
      elevation: 2,
      padding: const EdgeInsets.all(16),
      color: color.withOpacity(0.1),
      content: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningStats() {
    return GFCard(
      content: Column(
        children: [
          _buildStatItem(
            icon: Icons.timer,
            title: '学习时长',
            value: '25 分钟',
            color: Color(0xFF2196F3),
          ),
          const Divider(),
          _buildStatItem(
            icon: Icons.check_circle,
            title: '完成题目',
            value: '12 道',
            color: Color(0xFF4CAF50),
          ),
          const Divider(),
          _buildStatItem(
            icon: Icons.star,
            title: '正确率',
            value: '85%',
            color: Color(0xFFFF9800),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: Get.textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceRecommendation() {
    return GFCard(
      content: Column(
        children: [
          _buildResourceItem(
            icon: Icons.picture_as_pdf,
            title: '小学数学练习册',
            subtitle: 'GitHub · 百星项目',
            onTap: () => AppRoutes.toResources(),
          ),
          const SizedBox(height: 12),
          _buildResourceItem(
            icon: Icons.video_library,
            title: '英语听力训练',
            subtitle: '视频 · 50 分钟',
            onTap: () => AppRoutes.toResources(),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Get.theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
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
          Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '首页',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: '学习',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder),
          label: '资源',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '我的',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 2:
            AppRoutes.toResources();
            break;
        }
      },
    );
  }
}
