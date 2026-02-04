import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:get/get.dart';
import '../../config/ai_config.dart';
import '../../config/app_config.dart';
import '../../app/routes.dart';

/// 设置页面
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedProvider = AIConfig.currentProvider;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
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
