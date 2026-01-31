import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class UserCenterPage extends StatefulWidget {
  const UserCenterPage({super.key});

  @override
  State<UserCenterPage> createState() => _UserCenterPageState();
}

class _UserCenterPageState extends State<UserCenterPage> {
  final _settings = SettingsService();
  String? _backupProvider;
  String? _modelProvider;
  String? _token;

  final _tokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final map = await _settings.getBasicSettings();
    final token = await _settings.getProviderToken(map['backupProvider'] ?? '');
    setState(() {
      _backupProvider = map['backupProvider'];
      _modelProvider = map['modelProvider'];
      _token = token;
      _tokenController.text = token ?? '';
    });
  }

  Future<void> _save() async {
    await _settings.saveBasicSettings(backupProvider: _backupProvider ?? 'none', modelProvider: _modelProvider);
    if ((_backupProvider ?? 'none') != 'none') {
      await _settings.saveProviderToken(_backupProvider!, _tokenController.text);
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已保存')));
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('用户中心')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Row(children: [const Text('备份服务: '), const SizedBox(width: 8), Text(_backupProvider ?? '未配置')]),
          const SizedBox(height: 12),
          DropdownButton<String>(
            value: _backupProvider ?? 'none',
            items: const [
              DropdownMenuItem(value: 'none', child: Text('不启用')),
              DropdownMenuItem(value: 'baidu', child: Text('百度网盘')),
              DropdownMenuItem(value: 'wechat', child: Text('微信云')),
            ],
            onChanged: (v) => setState(() => _backupProvider = v),
          ),
          const SizedBox(height: 12),
          TextField(controller: _tokenController, decoration: const InputDecoration(labelText: '服务 Token（演示）')),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _save, child: const Text('保存')),
        ]),
      ),
    );
  }
}
