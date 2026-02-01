import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:get/get.dart';

/// 隐私政策页面
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('隐私政策'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildUpdateInfo(),
            const SizedBox(height: 24),
            _buildSection('1. 信息收集', _buildDataCollection()),
            const SizedBox(height: 24),
            _buildSection('2. 信息使用', _buildDataUsage()),
            const SizedBox(height: 24),
            _buildSection('3. 信息共享', _buildDataSharing()),
            const SizedBox(height: 24),
            _buildSection('4. 信息存储与安全', _buildDataStorage()),
            const SizedBox(height: 24),
            _buildSection('5. 用户权利', _buildUserRights()),
            const SizedBox(height: 24),
            _buildSection('6. 未成年人保护', _buildMinorProtection()),
            const SizedBox(height: 24),
            _buildSection('7. 隐私政策更新', _buildPolicyUpdate()),
            const SizedBox(height: 24),
            _buildContactSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return GFCard(
      color: Colors.blue.withOpacity(0.1),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield, color: Colors.blue, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '趣学 - 隐私政策',
                      style: Get.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '福州阿莱克斯信息技术有限公司',
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateInfo() {
    return GFCard(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.update, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Text(
                '最后更新日期：2026年2月1日',
                style: Get.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '感谢您使用"趣学"应用！我们深知个人信息对您的重要性，并会尽全力保护您的个人信息安全可靠。我们致力于维持您对我们的信任，恪守以下原则，保护您的个人信息：权责一致原则、目的明确原则、选择同意原则、最少够用原则、确保安全原则、主体参与原则、公开透明原则等。',
            style: Get.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return GFCard(
      title: GFListTile(
        avatar: Icon(Icons.article, color: Get.theme.colorScheme.primary),
        title: Text(title, style: Get.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        )),
      ),
      content: content,
    );
  }

  Widget _buildDataCollection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubSection('1.1 我们收集哪些信息'),
        const SizedBox(height: 12),
        _buildDataItem('设备信息', '设备型号、操作系统版本、唯一设备标识符'),
        _buildDataItem('日志信息', '应用使用记录、错误日志、访问时间'),
        _buildDataItem('学习数据', '学习进度、答题记录、成绩统计'),
        _buildDataItem('权限信息', '摄像头（拍照识别）、麦克风（语音听写）'),
        const SizedBox(height: 12),
        _buildSubSection('1.2 信息收集方式'),
        const SizedBox(height: 8),
        Text(
          '我们在您使用本应用时主动收集上述信息。对于某些功能，我们需要您授权相应的权限后才能使用。',
          style: Get.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildDataUsage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataItem('提供服务', '为您提供AI智能组题、OCR识别、语音听写等功能'),
        _buildDataItem('优化体验', '分析使用数据，优化应用性能和用户体验'),
        _buildDataItem('学习分析', '生成学习报告，帮助您了解学习进度'),
        _buildDataItem('安全保障', '检测和预防安全风险，保护账户安全'),
      ],
    );
  }

  Widget _buildDataSharing() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '我们不会出售、出租或以其他方式披露您的个人信息',
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: Colors.green[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '在以下情况下，我们可能会共享您的信息：',
          style: Get.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        _buildDataItem('法律法规要求', '应法律法规或政府主管部门要求'),
        _buildDataItem('第三方服务', '为提供服务所需的第三方（如AI模型提供商）'),
        _buildDataItem('业务转让', '合并、收购或资产转让时的必要信息共享'),
      ],
    );
  }

  Widget _buildDataStorage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataItem('本地存储', '大部分数据存储在您的设备本地'),
        _buildDataItem('安全措施', '采用加密技术保护数据安全'),
        _buildDataItem('数据保留', '仅在必要时保留相关数据'),
        _buildDataItem('删除权', '您可以随时申请删除个人数据'),
      ],
    );
  }

  Widget _buildUserRights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataItem('访问权', '了解我们收集的个人信息情况'),
        _buildDataItem('更正权', '要求更正或补充您的个人信息'),
        _buildDataItem('删除权', '要求删除您的个人信息'),
        _buildDataItem('撤回同意', '随时撤回对信息处理的同意'),
        _buildDataItem('注销账户', '申请注销您的账户及关联数据'),
        const SizedBox(height: 12),
        GFButton(
          text: '行使我的权利',
          type: GFButtonType.outline,
          blockButton: true,
          onPressed: () {
            Get.snackbar(
              '提示',
              '请通过下方联系方式与我们联系',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMinorProtection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.child_care, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              Text(
                '未成年人特别保护',
                style: Get.textTheme.titleMedium?.copyWith(
                  color: Colors.orange[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '本应用主要面向未成年人用户。我们非常重视未成年人个人信息的保护。如果您是未成年人，请在监护人指导下阅读和使用本应用。',
            style: Get.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '如果您是未成年人的监护人，请关注未成年人的个人信息使用情况，如您发现我们收集了未成年人的信息且未经监护人同意，请及时与我们联系，我们会尽快处理。',
            style: Get.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyUpdate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '我们可能会适时更新本隐私政策。当我们更新隐私政策时，会通过应用内通知或弹窗的方式告知您。请您在使用本应用时定期查看隐私政策。',
          style: Get.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Text(
          '如您在本政策更新后继续使用我们的服务，即表示您已充分阅读、理解并接受更新后的隐私政策。',
          style: Get.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return GFCard(
      title: GFListTile(
        avatar: Icon(Icons.contact_mail, color: Get.theme.colorScheme.primary),
        title: Text('联系我们', style: Get.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        )),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContactItem('公司名称', '福州阿莱克斯信息技术有限公司'),
          _buildContactItem('联系邮箱', 'support@flipkit-app.com'),
          _buildContactItem('应用名称', '趣学'),
          const SizedBox(height: 12),
          Text(
            '如果您对本隐私政策有任何疑问、意见或建议，请通过上述方式与我们联系。我们将在收到您的反馈后尽快回复。',
            style: Get.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubSection(String title) {
    return Text(
      title,
      style: Get.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Get.theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildDataItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Get.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label：',
              style: Get.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Get.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
