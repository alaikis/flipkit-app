import 'dart:convert';
import 'dart:io';

class PluginManifest {
  final String id;
  final String version;
  final String type;
  final String entry;
  final Map<String, dynamic> meta;

  PluginManifest({required this.id, required this.version, required this.type, required this.entry, required this.meta});

  factory PluginManifest.fromJson(Map<String, dynamic> j) {
    return PluginManifest(
      id: j['id'] ?? '',
      version: j['version'] ?? '0.0.0',
      type: j['type'] ?? 'content',
      entry: j['entry'] ?? '',
      meta: j['meta'] ?? {},
    );
  }
}

class PluginManager {
  final Directory pluginsDir;

  PluginManager(this.pluginsDir);

  Future<PluginManifest> loadManifest(File manifestFile) async {
    final content = await manifestFile.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;
    return PluginManifest.fromJson(json);
  }

  Future<List<PluginManifest>> listInstalled() async {
    if (!await pluginsDir.exists()) return [];
    final children = pluginsDir.listSync();
    final manifests = <PluginManifest>[];
    for (var c in children) {
      if (c is Directory) {
        final mf = File('${c.path}/manifest.json');
        if (await mf.exists()) {
          manifests.add(await loadManifest(mf));
        }
      }
    }
    return manifests;
  }
}
