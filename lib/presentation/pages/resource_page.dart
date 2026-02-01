import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:get/get.dart';
import '../../services/github_service.dart';
import '../../services/resource_service.dart';

/// 资源页面
class ResourcePage extends StatefulWidget {
  const ResourcePage({super.key});

  @override
  State<ResourcePage> createState() => _ResourcePageState();
}

class _ResourcePageState extends State<ResourcePage> {
  final GitHubService _githubService = GitHubService();
  final ResourceService _resourceService = ResourceService();

  late int _currentTabIndex;
  late String _searchQuery;

  @override
  void initState() {
    super.initState();
    _currentTabIndex = 0;
    _searchQuery = '';
  }

  final List<Widget> _tabs = [
    Tab(text: '本地资源'),
    Tab(text: 'GitHub 搜索'),
    Tab(text: '网络资源'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('资源中心'),
        bottom: TabBar(
          tabs: _tabs,
          onTap: (index) => setState(() => _currentTabIndex = index),
        ),
      ),
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          _buildLocalResourcesTab(),
          _buildGitHubSearchTab(),
          _buildWebResourcesTab(),
        ],
      ),
      floatingActionButton: _currentTabIndex == 0
          ? GFButton(
              icon: const Icon(Icons.add),
              text: '添加资源',
              type: GFButtonType.solid,
              onPressed: _showAddResourceDialog,
            )
          : null,
    );
  }

  Widget _buildLocalResourcesTab() {
    return Column(
      children: [
        // 搜索栏
        Padding(
          padding: const EdgeInsets.all(16),
          child: GFSearchBar(
            searchList: [],
            searchQueryBuilder: (query, list) {
              setState(() => _searchQuery = query);
              return list;
            },
            overlaySearchListItemBuilder: (item) => Container(),
            noItemsFoundWidget: Container(),
          ),
        ),
        // 资源列表
        Expanded(
          child: _buildResourceList([
            _buildResourceItem(
              icon: Icons.picture_as_pdf,
              title: '小学数学练习册.pdf',
              subtitle: '1.2 MB · 今天',
              color: Colors.red,
            ),
            _buildResourceItem(
              icon: Icons.video_library,
              title: '英语听力训练.mp4',
              subtitle: '50.5 MB · 昨天',
              color: Colors.blue,
            ),
            _buildResourceItem(
              icon: Icons.insert_drive_file,
              title: '语文复习资料.docx',
              subtitle: '256 KB · 3天前',
              color: Colors.green,
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildGitHubSearchTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 搜索栏
          GFSearchBar(
            searchList: [],
            searchQueryBuilder: (query, list) {
              setState(() => _searchQuery = query);
              return list;
            },
            overlaySearchListItemBuilder: (item) => Container(),
            noItemsFoundWidget: Container(),
          ),
          const SizedBox(height: 16),
          // 搜索按钮
          GFButton(
            text: '搜索 GitHub',
            size: GFSize.LARGE,
            blockButton: true,
            icon: const Icon(Icons.search),
            onPressed: _searchGitHub,
          ),
          const SizedBox(height: 16),
          // 搜索结果
          Expanded(
            child: _buildGitHubResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildWebResourcesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GFSearchBar(
            searchList: [],
            searchQueryBuilder: (query, list) {
              setState(() => _searchQuery = query);
              return list;
            },
            overlaySearchListItemBuilder: (item) => Container(),
            noItemsFoundWidget: Container(),
          ),
          const SizedBox(height: 16),
          GFButton(
            text: '搜索网络资源',
            size: GFSize.LARGE,
            blockButton: true,
            icon: const Icon(Icons.search),
            onPressed: _searchWeb,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildWebResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceList(List<Widget> children) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: children.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => children[index],
    );
  }

  Widget _buildResourceItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return GFCard(
      content: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
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
          GFButton(
            icon: const Icon(Icons.open_in_new),
            type: GFButtonType.transparent,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildGitHubResults() {
    return ListView(
      children: [
        _buildRepositoryCard(
          name: 'elementary-school-math',
          description: '小学数学练习题库',
          stars: 1234,
          language: 'Python',
          owner: 'education-org',
        ),
        _buildRepositoryCard(
          name: 'english-learning-materials',
          description: '英语学习资料集合',
          stars: 856,
          language: 'English',
          owner: 'learn-english',
        ),
      ],
    );
  }

  Widget _buildRepositoryCard({
    required String name,
    required String description,
    required int stars,
    required String language,
    required String owner,
  }) {
    return GFCard(
      margin: const EdgeInsets.only(bottom: 16),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.book, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.orange, size: 16),
              const SizedBox(width: 4),
              Text('$stars', style: Get.textTheme.bodySmall),
              const SizedBox(width: 16),
              Icon(Icons.code, color: Colors.blue[700], size: 16),
              const SizedBox(width: 4),
              Text(language, style: Get.textTheme.bodySmall),
              const SizedBox(width: 16),
              Icon(Icons.person, color: Colors.grey, size: 16),
              const SizedBox(width: 4),
              Text(owner, style: Get.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          GFButton(
            text: '查看并下载',
            size: GFSize.SMALL,
            blockButton: true,
            onPressed: () => _showRepositoryDetail(name),
          ),
        ],
      ),
    );
  }

  Widget _buildWebResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '输入关键词搜索网络资源',
            style: Get.textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddResourceDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '添加资源',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildAddResourceButton(
              icon: Icons.camera_alt,
              title: '拍照添加',
              subtitle: '拍照识别文档',
              color: Colors.blue,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildAddResourceButton(
              icon: Icons.link,
              title: '从链接下载',
              subtitle: '输入资源链接',
              color: Colors.green,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildAddResourceButton(
              icon: Icons.code,
              title: 'GitHub 下载',
              subtitle: '从 GitHub 仓库下载',
              color: Colors.purple,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddResourceButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
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
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Future<void> _searchGitHub() async {
    if (_searchQuery.isEmpty) {
      Get.snackbar('提示', '请输入搜索关键词');
      return;
    }

    Get.showOverlay(
      asyncFunction: () async {
        await Future.delayed(const Duration(seconds: 1));
        Get.snackbar('成功', '搜索完成');
      },
    );
  }

  Future<void> _searchWeb() async {
    if (_searchQuery.isEmpty) {
      Get.snackbar('提示', '请输入搜索关键词');
      return;
    }

    Get.showOverlay(
      asyncFunction: () async {
        await Future.delayed(const Duration(seconds: 1));
        Get.snackbar('成功', '搜索完成');
      },
    );
  }

  void _showRepositoryDetail(String repoName) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              repoName,
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text('文件列表', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _buildFileItem('Chapter1.pdf', 'PDF', 1.2),
                  _buildFileItem('Chapter2.pdf', 'PDF', 1.5),
                  _buildFileItem('Exercises.docx', 'Word', 0.5),
                ],
              ),
            ),
            GFButton(
              text: '下载全部',
              size: GFSize.LARGE,
              blockButton: true,
              onPressed: () {
                Get.back();
                Get.snackbar('成功', '开始下载...');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem(String name, String type, double size) {
    return ListTile(
      leading: Icon(
        type == 'PDF' ? Icons.picture_as_pdf : Icons.insert_drive_file,
        color: type == 'PDF' ? Colors.red : Colors.blue,
      ),
      title: Text(name),
      trailing: Text('${size} MB', style: const TextStyle(color: Colors.grey)),
    );
  }
}
