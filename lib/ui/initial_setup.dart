import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitialSetupPage extends StatefulWidget {
  const InitialSetupPage({super.key});

  @override
  State<InitialSetupPage> createState() => _InitialSetupPageState();
}

class _InitialSetupPageState extends State<InitialSetupPage> {
  final _settings = SettingsService();
  String _selectedProvider = 'none';
  final _tokenController = TextEditingController();

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    await _settings.saveBasicSettings(backupProvider: _selectedProvider, modelProvider: null);
    if (_selectedProvider != 'none' && _tokenController.text.isNotEmpty) {
      await _settings.saveProviderToken(_selectedProvider, _tokenController.text);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isConfigured', true);
    if (mounted) Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('初始配置')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('请选择云端备份服务（可稍后在用户中心修改）'),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: _selectedProvider,
              items: const [
                DropdownMenuItem(value: 'none', child: Text('不启用')),
                DropdownMenuItem(value: 'baidu', child: Text('百度网盘')),
                DropdownMenuItem(value: 'wechat', child: Text('微信云')),
              ],
              onChanged: (v) => setState(() => _selectedProvider = v ?? 'none'),
            ),
            const SizedBox(height: 16),
            if (_selectedProvider != 'none') ...[
              const Text('（演示用）请输入服务访问 token，正式环境应使用 OAuth 流') ,
              TextField(controller: _tokenController, decoration: const InputDecoration(labelText: '访问 Token')),
            ],
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(onPressed: _saveAndContinue, child: const Text('保存并进入应用')),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
