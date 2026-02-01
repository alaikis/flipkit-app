import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:get/get.dart';
import '../../services/ocr_factory.dart';

/// 开源策略配置页面
class OpenSourcePolicyPage extends StatelessWidget {
  const OpenSourcePolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('开源策略'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverview(),
            const SizedBox(height: 24),
            _buildOCRProviderSection(),
            const SizedBox(height: 24),
            _buildPrinciplesSection(),
            const SizedBox(height: 24),
            _buildComponentsList(),
            const SizedBox(height: 24),
            _buildBenefitsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverview() {
    return GFCard(
      title: const GFListTile(
        avatar: Icon(Icons.info_outline, color: GFColors.INFO),
        title: Text('开源优先原则'),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FlipKit 积极拥抱开源技术，优先使用国内开源解决方案，',
            style: Get.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '确保应用的安全、可控和可持续发展。',
            style: Get.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          _buildPrincipleChip('✅ 国内开源优先', Colors.green),
          _buildPrincipleChip('✅ 完全开源免费', Colors.blue),
          _buildPrincipleChip('✅ 本地数据处理', Colors.orange),
          _buildPrincipleChip('✅ 活跃社区支持', Colors.purple),
        ],
      ),
    );
  }

  Widget _buildPrincipleChip(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Chip(
        label: Text(label),
        backgroundColor: color.withOpacity(0.1),
        avatar: Icon(Icons.check_circle, size: 16, color: color),
      ),
    );
  }

  Widget _buildOCRProviderSection() {
    return GFCard(
      title: const GFListTile(
        avatar: Icon(Icons.text_fields, color: GFColors.PRIMARY),
        title: Text('OCR 引擎选择'),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '选择适合您需求的 OCR 引擎：',
            style: Get.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildProviderCard(
            provider: OCRProvider.paddleOCR,
            icon: Icons.star,
            iconColor: Colors.orange,
            title: 'PaddleOCR（推荐）',
            subtitle: '百度开源，中文识别准确率高',
            advantages: ['中文识别最准确', '模型轻量', '国内开源'],
          ),
          const SizedBox(height: 12),
          _buildProviderCard(
            provider: OCRProvider.tesseract,
            icon: Icons.public,
            iconColor: Colors.blue,
            title: 'Tesseract',
            subtitle: 'Google 开源，支持多语言',
            advantages: ['支持100+语言', '社区活跃', '跨平台'],
          ),
          const SizedBox(height: 12),
          _buildProviderCard(
            provider: OCRProvider.googleMLKit,
            icon: Icons.phone_iphone,
            iconColor: Colors.green,
            title: 'Google ML Kit',
            subtitle: '移动端专用，闭源方案',
            advantages: ['移动端优化', '识别速度快', '云端支持'],
          ),
          const SizedBox(height: 16),
          GFButton(
            text: '保存设置',
            size: GFSize.LARGE,
            blockButton: true,
            onPressed: () {
              Get.snackbar(
                '设置已保存',
                'OCR 引擎配置已更新',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard({
    required OCRProvider provider,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required List<String> advantages,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          GFListTile(
            avatar: Icon(icon, color: iconColor),
            title: Text(title),
            subTitle: Text(subtitle),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: advantages.map((advantage) {
                return Chip(
                  label: Text(advantage, style: const TextStyle(fontSize: 12)),
                  backgroundColor: GFColors.LIGHT,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrinciplesSection() {
    return GFCard(
      title: const GFListTile(
        avatar: Icon(Icons.rule, color: GFColors.SUCCESS),
        title: Text('技术选型标准'),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStandardItem('1. 活跃维护', '最近6个月有更新'),
          _buildStandardItem('2. 宽松许可证', 'Apache 2.0 / MIT / BSD'),
          _buildStandardItem('3. 完善文档', '文档清晰，示例丰富'),
          _buildStandardItem('4. 社区支持', '活跃的社区和贡献者'),
          _buildStandardItem('5. 跨平台', '支持多平台运行'),
        ],
      ),
    );
  }

  Widget _buildStandardItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 20, color: GFColors.SUCCESS),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Get.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(description, style: Get.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentsList() {
    return GFCard(
      title: const GFListTile(
        avatar: Icon(Icons.extension, color: GFColors.WARNING),
        title: Text('开源组件清单'),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildComponentSection('核心框架', [
            _buildComponentItem('Flutter', 'Google', 'BSD'),
            _buildComponentItem('Dart', 'Google', 'BSD'),
          ]),
          const SizedBox(height: 16),
          _buildComponentSection('UI 组件', [
            _buildComponentItem('GetWidget', 'GetX', 'MIT'),
            _buildComponentItem('GetX', 'GetX', 'MIT'),
          ]),
          const SizedBox(height: 16),
          _buildComponentSection('AI/OCR', [
            _buildComponentItem('PaddleOCR', '百度', 'Apache 2.0'),
            _buildComponentItem('Tesseract', 'Google', 'Apache 2.0'),
          ]),
          const SizedBox(height: 16),
          _buildComponentSection('数据存储', [
            _buildComponentItem('SQLite', 'SQLite', 'Public Domain'),
            _buildComponentItem('Hive', 'Hive', 'Apache 2.0'),
          ]),
        ],
      ),
    );
  }

  Widget _buildComponentSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Get.textTheme.titleMedium),
        const SizedBox(height: 8),
        ...items,
      ],
    );
  }

  Widget _buildComponentItem(String name, String author, String license) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(name, style: Get.textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(author, style: Get.textTheme.bodySmall),
          ),
          Chip(
            label: Text(license, style: const TextStyle(fontSize: 10)),
            backgroundColor: Colors.blue[50],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return GFCard(
      title: GFListTile(
        avatar: const Icon(Icons.lightbulb, color: Colors.amber),
        title: const Text('开源带来的好处'),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBenefitItem(
            Icons.security,
            '数据安全',
            '本地处理，不上传到云端',
          ),
          _buildBenefitItem(
            Icons.offline_pin,
            '离线可用',
            '无需网络连接，随时使用',
          ),
          _buildBenefitItem(
            Icons.code,
            '透明可控',
            '代码公开，可审计和定制',
          ),
          _buildBenefitItem(
            Icons.groups,
            '社区支持',
            '全球开发者共同维护',
          ),
          _buildBenefitItem(
            Icons.attach_money,
            '成本降低',
            '无需昂贵的商业授权',
          ),
          _buildBenefitItem(
            Icons.update,
            '持续更新',
            '社区驱动，功能持续演进',
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.amber, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Get.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(description, style: Get.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
