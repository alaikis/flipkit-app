import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../config/ai_config.dart';
import '../../config/app_config.dart';
import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/storage_helper.dart';
import '../../data/models/learning_space.dart';
import '../../data/database/database_helper.dart';
import '../../core/curriculum_cache.dart';
import '../../services/curriculum_sync_service.dart';

/// 设置页面
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedProvider = AIConfig.currentProvider;
  bool _darkMode = false;
  List<LearningSpace> _spaces = [];
  String? _currentSpaceId;
  static const String _defaultUserId = 'default_user';
  bool _curriculumSyncing = false;
  String? _curriculumUpdatedAt;

  @override
  void initState() {
    super.initState();
    _loadSpaces();
  }

  Future<void> _loadSpaces() async {
    _currentSpaceId = await StorageHelper().getString(AppConstants.keyCurrentSpaceId);
    _curriculumUpdatedAt = await StorageHelper().getString(AppConstants.keyCurriculumUpdatedAt);
    final list = await DatabaseHelper().getLearningSpaces(_defaultUserId);
    if (mounted) setState(() {
      _spaces = list;
      if (_currentSpaceId == null && list.isNotEmpty) {
        _currentSpaceId = list.first.id;
        StorageHelper().setString(AppConstants.keyCurrentSpaceId, list.first.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('学习空间（多学生）'),
          _buildLearningSpacesSection(),
          _buildSectionHeader('科目与知识点'),
          _buildCurriculumSection(),
          _buildSectionHeader('AI 设置'),
          _buildAIProviderSection(),
          _buildSectionHeader('应用设置'),
          _buildDarkModeSection(),
          _buildSectionHeader('开源策略'),
          _buildOpenSourceSection(),
          _buildSectionHeader('关于'),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildLearningSpacesSection() {
    return GFCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      content: Column(
        children: [
          ..._spaces.map((space) {
            final isCurrent = _currentSpaceId == space.id;
            return GFListTile(
              title: Text(space.childName),
              subTitle: Text('${space.grade} · ${space.childGender}'),
              icon: Icon(
                Icons.person,
                color: isCurrent ? Colors.green : null,
              ),
              avatar: isCurrent
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () async {
                await StorageHelper().setString(AppConstants.keyCurrentSpaceId, space.id);
                setState(() => _currentSpaceId = space.id);
                Get.snackbar('已切换', '当前：${space.childName}');
              },
            );
          }),
          const Divider(),
          GFButton(
            text: '添加学生',
            icon: const Icon(Icons.add),
            type: GFButtonType.outline,
            blockButton: true,
            onPressed: _showAddSpaceDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildCurriculumSection() {
    final updatedStr = _curriculumUpdatedAt != null
        ? _formatCurriculumUpdatedAt(_curriculumUpdatedAt!)
        : '未更新过';
    return GFCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      content: Column(
        children: [
          GFListTile(
            title: const Text('科目与知识点'),
            subTitle: Text(
              '由大模型从网络更新，上次：$updatedStr',
              style: Get.textTheme.bodySmall,
            ),
            icon: const Icon(Icons.school),
          ),
          const Divider(),
          GFButton(
            text: _curriculumSyncing ? '更新中…' : '立即更新科目与知识点',
            icon: Icon(_curriculumSyncing ? Icons.hourglass_empty : Icons.cloud_sync),
            type: GFButtonType.outline,
            blockButton: true,
            onPressed: _curriculumSyncing ? null : _syncCurriculum,
          ),
        ],
      ),
    );
  }

  String _formatCurriculumUpdatedAt(String ms) {
    final t = int.tryParse(ms);
    if (t == null) return ms;
    final dt = DateTime.fromMillisecondsSinceEpoch(t);
    return '${dt.month}月${dt.day}日 ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _syncCurriculum() async {
    setState(() => _curriculumSyncing = true);
    try {
      final ok = await CurriculumSyncService().fetchAndSaveCurriculum();
      await _loadSpaces();
      if (mounted) {
        Get.snackbar(ok ? '更新成功' : '更新失败', ok ? '科目与知识点已从大模型更新' : '请检查网络与 AI 配置');
      }
    } finally {
      if (mounted) setState(() => _curriculumSyncing = false);
    }
  }

  void _showAddSpaceDialog() {
    String name = '';
    String gender = '男';
    String grade = AppConstants.gradeLevels.first;
    Get.dialog(
      AlertDialog(
        title: const Text('添加学习空间'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: '学生姓名',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => name = v,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: gender,
                    decoration: const InputDecoration(
                      labelText: '性别',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: '男', child: Text('男')),
                      DropdownMenuItem(value: '女', child: Text('女')),
                    ],
                    onChanged: (v) => setDialogState(() => gender = v ?? '男'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: grade,
                    decoration: const InputDecoration(
                      labelText: '年级',
                      border: OutlineInputBorder(),
                    ),
                    items: AppConstants.gradeLevels
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => grade = v ?? grade),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          GFButton(
            text: '添加',
            onPressed: () async {
              if (name.trim().isEmpty) {
                Get.snackbar('提示', '请输入学生姓名');
                return;
              }
              Get.back();
              final now = DateTime.now();
              final space = LearningSpace(
                id: const Uuid().v4(),
                userId: _defaultUserId,
                childName: name.trim(),
                childGender: gender,
                grade: grade,
                textbookVersion: '通用',
                isActive: true,
                createdAt: now,
                updatedAt: now,
              );
              await DatabaseHelper().insertLearningSpace(space);
              if (_spaces.isEmpty) {
                await StorageHelper().setString(AppConstants.keyCurrentSpaceId, space.id);
              }
              await _loadSpaces();
              Get.snackbar('已添加', '${space.childName}（${space.grade}）');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: Get.textTheme.titleMedium?.copyWith(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAIProviderSection() {
    return GFCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      content: Column(
        children: [
          GFListTile(
            title: const Text('AI 提供商'),
            subTitle: Text(_selectedProvider),
            icon: const Icon(Icons.psychology),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '题目由大模型/联网大模型组题，无需下载或上传题库资源。',
              style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ),
          const Divider(),
          ...AIConfig.providers.map((provider) {
            return GFListTile(
              title: Text(provider.name),
              avatar: _selectedProvider == provider.name
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.radio_button_unchecked),
              onTap: () => _selectProvider(provider.name),
            );
          }).toList(),
          const Divider(),
          GFButton(
            text: '配置 API Key',
            type: GFButtonType.outline,
            blockButton: true,
            onPressed: _showAPIKeyDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildDarkModeSection() {
    return GFCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      content: GFListTile(
        title: const Text('深色模式'),
        subTitle: const Text('切换应用主题'),
        icon: const Icon(Icons.dark_mode),
        avatar: GFToggle(
          onChanged: (val) => _toggleDarkMode(val ?? false),
          value: _darkMode,
          type: GFToggleType.ios,
        ),
      ),
    );
  }

  Widget _buildOpenSourceSection() {
    return GFCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      content: GFListTile(
        title: const Text('开源策略'),
        subTitle: const Text('查看开源组件和策略'),
        icon: const Icon(Icons.code),
        onTap: () => AppRoutes.toOpenSourcePolicy(),
      ),
    );
  }

  Widget _buildAboutSection() {
    return GFCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      content: Column(
        children: [
          GFListTile(
            title: const Text('隐私政策'),
            subTitle: const Text('查看隐私政策详情'),
            icon: const Icon(Icons.privacy_tip),
            onTap: () => AppRoutes.toPrivacyPolicy(),
          ),
          const Divider(),
          GFListTile(
            title: const Text('使用条款'),
            subTitle: const Text('查看使用条款详情'),
            icon: const Icon(Icons.gavel),
            onTap: () => AppRoutes.toTermsOfService(),
          ),
          const Divider(),
          GFListTile(
            title: const Text('应用版本'),
            subTitle: Text('${AppConfig.appVersion} (Build ${AppConfig.buildNumber})'),
            icon: const Icon(Icons.info_outline),
          ),
          const Divider(),
          GFListTile(
            title: const Text('反馈与建议'),
            icon: const Icon(Icons.feedback),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _selectProvider(String provider) {
    setState(() => _selectedProvider = provider);
    Get.snackbar('成功', '已切换到 $provider');
  }

  void _toggleDarkMode(bool value) {
    setState(() => _darkMode = value);
    // TODO: 实现主题切换
    Get.snackbar('提示', '主题切换功能待实现');
  }

  void _showAPIKeyDialog() {
    final controller = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('配置 ${_selectedProvider} API Key'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'API Key',
            border: OutlineInputBorder(),
            hintText: '请输入 API Key',
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          GFButton(
            text: '保存',
            onPressed: () {
              if (controller.text.isNotEmpty) {
                // TODO: 保存 API Key
                Get.back();
                Get.snackbar('成功', 'API Key 已保存');
              }
            },
          ),
        ],
      ),
    );
  }
}
