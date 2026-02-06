import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:get/get.dart';

/// 使用条款页面
class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('使用条款'),
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
            _buildSection('1. 服务条款的接受', _buildAcceptance()),
            const SizedBox(height: 24),
            _buildSection('2. 服务描述', _buildServiceDescription()),
            const SizedBox(height: 24),
            _buildSection('3. 用户行为规范', _buildUserConduct()),
            const SizedBox(height: 24),
            _buildSection('4. 知识产权', _buildIntellectualProperty()),
            const SizedBox(height: 24),
            _buildSection('5. 免责声明', _buildDisclaimer()),
            const SizedBox(height: 24),
            _buildSection('6. 服务变更与终止', _buildServiceChanges()),
            const SizedBox(height: 24),
            _buildSection('7. 适用法律与争议解决', _buildLawAndDispute()),
            const SizedBox(height: 24),
            _buildContactSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return GFCard(
      color: Colors.orange.withOpacity(0.1),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gavel, color: Colors.orange, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '快学喵 - 使用条款',
                      style: Get.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
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
            '欢迎使用"快学喵"应用！本使用条款（以下简称"本条款"）是您与福州阿莱克斯信息技术有限公司（以下简称"我们"）之间关于使用"快学喵"应用的法律协议。请您仔细阅读本条款，在使用本应用前，您必须同意并接受本条款的所有内容。',
            style: Get.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return GFCard(
      title: GFListTile(
        avatar: Icon(Icons.assignment, color: Get.theme.colorScheme.primary),
        title: Text(title, style: Get.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        )),
      ),
      content: content,
    );
  }

  Widget _buildAcceptance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '通过下载、安装或使用"快学喵"应用，即表示您已阅读、理解并同意接受本条款的约束。如果您不同意本条款的任何内容，请立即停止使用本应用。',
          style: Get.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '未满18周岁的用户应在监护人指导下阅读并同意本条款',
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: Colors.red[800],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubSection('2.1 服务内容'),
        const SizedBox(height: 8),
        Text(
          '本应用提供以下功能服务：',
          style: Get.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        _buildServiceItem('AI智能组题', '基于人工智能技术的个性化题目生成'),
        _buildServiceItem('OCR智能识别', '拍照识别手写内容并智能评分'),
        _buildServiceItem('语音听写', '语音转文字的听写练习功能'),
        _buildServiceItem('作文辅导', 'AI辅助的作文写作指导'),
        _buildServiceItem('资源搜索', 'GitHub资源搜索和下载功能'),
        const SizedBox(height: 12),
        _buildSubSection('2.2 服务变更'),
        const SizedBox(height: 8),
        Text(
          '我们保留随时修改、中断或终止部分或全部服务的权利，无需对您或第三方承担责任。我们会尽可能提前通知您重大的服务变更。',
          style: Get.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildUserConduct() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubSection('3.1 您承诺'),
        const SizedBox(height: 8),
        Text(
          '在使用本应用时，您承诺遵守以下行为规范：',
          style: Get.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        _buildConductItem('合法合规', '遵守中华人民共和国法律法规及相关政策'),
        _buildConductItem('真实信息', '提供真实、准确、完整的个人信息'),
        _buildConductItem('文明使用', '文明使用服务，不传播违法有害信息'),
        _buildConductItem('保护账户', '妥善保管账户信息，对账户活动负责'),
        const SizedBox(height: 12),
        _buildSubSection('3.2 禁止行为'),
        const SizedBox(height: 8),
        Text(
          '您不得进行以下行为：',
          style: Get.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        _buildConductItem('逆向工程', '对应用进行反编译、逆向工程或破解'),
        _buildConductItem('恶意攻击', '利用应用漏洞进行攻击或传播恶意软件'),
        _buildConductItem('商业利用', '未经授权将应用用于商业目的'),
        _buildConductItem('侵权行为', '侵犯他人知识产权或合法权益'),
      ],
    );
  }

  Widget _buildIntellectualProperty() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubSection('4.1 应用所有权'),
        const SizedBox(height: 8),
        Text(
          '本应用及其所有内容，包括但不限于软件代码、界面设计、文字内容、图片、商标等，均受知识产权法保护，归福州阿莱克斯信息技术有限公司或其授权方所有。',
          style: Get.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        _buildSubSection('4.2 用户内容'),
        const SizedBox(height: 8),
        Text(
          '您在使用本应用过程中产生的内容（包括但不限于答题记录、学习数据等），您保留其知识产权。您授予我们在提供服务的范围内使用、存储、处理您的内容的权利。',
          style: Get.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        _buildSubSection('4.3 开源组件'),
        const SizedBox(height: 8),
        Text(
          '本应用使用了部分开源组件，这些组件的许可证信息详见《开源策略》页面。这些开源组件的知识产权归其原始开发者所有。',
          style: Get.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '免责声明',
                    style: Get.textTheme.titleSmall?.copyWith(
                      color: Colors.red[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildDisclaimerItem(
                '服务按"现状"提供，不保证服务的及时性、安全性或无错误',
              ),
              _buildDisclaimerItem(
                'AI生成内容仅供参考，不构成专业建议',
              ),
              _buildDisclaimerItem(
                '因不可抗力导致的服务中断不承担责任',
              ),
              _buildDisclaimerItem(
                '第三方内容的准确性和可靠性由第三方负责',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceChanges() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubSection('6.1 服务变更'),
        const SizedBox(height: 8),
        Text(
          '我们有权根据业务发展需要，对应用功能、服务内容、收费政策等进行调整。重大变更将通过应用内通知、弹窗或其他合理方式告知您。',
          style: Get.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        _buildSubSection('6.2 终止服务'),
        const SizedBox(height: 8),
        Text(
          '在以下情况下，我们有权终止或限制您的服务：',
          style: Get.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        _buildTerminationItem('违反本条款或相关法律法规'),
        _buildTerminationItem('提供虚假信息或冒用他人身份'),
        _buildTerminationItem('恶意使用或滥用服务'),
        _buildTerminationItem('长期不活跃账户（连续12个月未登录）'),
      ],
    );
  }

  Widget _buildLawAndDispute() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubSection('7.1 适用法律'),
        const SizedBox(height: 8),
        Text(
          '本条款的订立、执行、解释及争议解决均适用中华人民共和国法律法规。',
          style: Get.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        _buildSubSection('7.2 争议解决'),
        const SizedBox(height: 8),
        Text(
          '因本条款引起的或与本条款有关的任何争议，双方应友好协商解决。协商不成的，任何一方均可向公司所在地人民法院提起诉讼。',
          style: Get.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        _buildSubSection('7.3 条款效力'),
        const SizedBox(height: 8),
        Text(
          '本条款中的任何条款因任何原因被认定为无效或不可执行，不影响其他条款的效力。被认定为无效或不可执行的条款应被可执行的条款所替代，该替代条款应尽可能体现原条款的商业意图。',
          style: Get.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return GFCard(
      title: GFListTile(
        avatar: Icon(Icons.contact_phone, color: Get.theme.colorScheme.primary),
        title: Text('联系我们', style: Get.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        )),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContactItem('公司名称', '福州阿莱克斯信息技术有限公司'),
          _buildContactItem('联系邮箱', 'support@flipkit-app.com'),
          _buildContactItem('应用名称', '快学喵'),
          const SizedBox(height: 12),
          Text(
            '如果您对本使用条款有任何疑问，请通过上述方式与我们联系。',
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

  Widget _buildServiceItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 8),
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

  Widget _buildConductItem(String label, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 12),
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
            child: RichText(
              text: TextSpan(
                style: Get.textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: label,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  TextSpan(
                    text: '：$description',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.arrow_right, color: Colors.grey[600], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Get.textTheme.bodySmall?.copyWith(
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminationItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.close, color: Colors.red[700], size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Get.textTheme.bodyMedium,
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
