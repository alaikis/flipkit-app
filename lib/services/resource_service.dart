import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../core/utils/logger.dart';
import '../data/models/resource.dart';
import '../data/database/database_helper.dart';
import 'github_service.dart';

/// 资源服务 - 管理各种教育资源
class ResourceService {
  static final ResourceService _instance = ResourceService._internal();
  factory ResourceService() => _instance;

  ResourceService._internal();

  late final Dio _dio;
  final DatabaseHelper _db = DatabaseHelper();
  final GitHubService _githubService = GitHubService();

  /// 初始化
  Future<void> init() async {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(milliseconds: 30000),
      receiveTimeout: const Duration(milliseconds: 60000),
      sendTimeout: const Duration(milliseconds: 30000),
    ));

    await _githubService.init();
    Logger.info('Resource Service initialized', tag: 'ResourceService');
  }

  /// 搜索网络资源
  Future<List<Map<String, dynamic>>> searchWebResources(String query) async {
    try {
      Logger.network('GET', 'search/resources', tag: 'ResourceService');

      // 这里可以使用搜索引擎 API 或爬虫
      // 暂时返回模拟数据
      await Future.delayed(const Duration(seconds: 1));

      return [
        {
          'title': '$query - 学习资源1',
          'description': '优质的学习资源',
          'url': 'https://example.com/resource1',
          'type': 'pdf',
          'source': 'web',
        },
        {
          'title': '$query - 学习视频',
          'description': '教学视频',
          'url': 'https://example.com/video1',
          'type': 'video',
          'source': 'web',
        },
      ];
    } catch (e, stackTrace) {
      Logger.error('Failed to search web resources',
          error: e, stackTrace: stackTrace, tag: 'ResourceService');
      return [];
    }
  }

  /// 下载网络资源
  Future<String> downloadResource({
    required String url,
    required String fileName,
    required String spaceId,
  }) async {
    try {
      Logger.info('Downloading resource: $fileName', tag: 'ResourceService');

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/resources/$spaceId/$fileName';

      // 确保目录存在
      await Directory('${directory.path}/resources/$spaceId').create(recursive: true);

      // 下载文件
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(2);
            Logger.debug('Download progress: $progress%', tag: 'ResourceService');
          }
        },
      );

      // 获取文件信息
      final file = File(filePath);
      final fileSize = await file.length();

      // 保存到数据库
      final resource = Resource(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        spaceId: spaceId,
        title: fileName,
        description: '从网络下载的资源',
        type: _getResourceType(fileName),
        source: 'web',
        url: url,
        localPath: filePath,
        fileSize: fileSize,
        createdAt: DateTime.now(),
      );

      await _db.insertResource(resource);

      Logger.info('Resource downloaded and saved: $filePath', tag: 'ResourceService');
      return filePath;
    } catch (e, stackTrace) {
      Logger.error('Failed to download resource',
          error: e, stackTrace: stackTrace, tag: 'ResourceService');
      rethrow;
    }
  }

  /// 从 GitHub 添加资源
  Future<List<String>> addGitHubResources({
    required String owner,
    required String repo,
    required String spaceId,
    String? path,
    String? fileExtension,
  }) async {
    try {
      Logger.info('Adding GitHub resources: $owner/$repo', tag: 'ResourceService');

      final downloadedFiles = await _githubService.cloneRepository(
        owner: owner,
        repo: repo,
        path: path,
        fileExtension: fileExtension,
      );

      // 保存到数据库
      for (var filePath in downloadedFiles) {
        final file = File(filePath);
        final fileName = file.path.split('/').last;
        final fileSize = await file.length();

        final resource = Resource(
          id: '${DateTime.now().millisecondsSinceEpoch}_${fileName}',
          spaceId: spaceId,
          title: fileName,
          description: '从 GitHub 下载的资源',
          type: _getResourceType(fileName),
          source: 'github',
          githubRepo: '$owner/$repo',
          githubPath: path ?? '',
          localPath: filePath,
          fileSize: fileSize,
          createdAt: DateTime.now(),
        );

        await _db.insertResource(resource);
      }

      Logger.info('GitHub resources added: ${downloadedFiles.length} files',
          tag: 'ResourceService');
      return downloadedFiles;
    } catch (e, stackTrace) {
      Logger.error('Failed to add GitHub resources',
          error: e, stackTrace: stackTrace, tag: 'ResourceService');
      rethrow;
    }
  }

  /// 获取资源列表
  Future<List<Resource>> getResources(String spaceId) async {
    try {
      return await _db.getResources(spaceId);
    } catch (e, stackTrace) {
      Logger.error('Failed to get resources',
          error: e, stackTrace: stackTrace, tag: 'ResourceService');
      return [];
    }
  }

  /// 搜索 GitHub 仓库
  Future<List<Map<String, dynamic>>> searchGitHubRepositories({
    required String query,
    String? language,
  }) async {
    try {
      return await _githubService.searchRepositories(
        query: query,
        language: language,
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to search GitHub repositories',
          error: e, stackTrace: stackTrace, tag: 'ResourceService');
      return [];
    }
  }

  /// 获取 GitHub 仓库文件
  Future<List<Map<String, dynamic>>> getGitHubRepositoryFiles({
    required String owner,
    required String repo,
    String? path,
    String? extension,
  }) async {
    try {
      return await _githubService.getRepositoryFiles(
        owner: owner,
        repo: repo,
        path: path ?? '',
        extension: extension ?? '',
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to get GitHub repository files',
          error: e, stackTrace: stackTrace, tag: 'ResourceService');
      return [];
    }
  }

  /// 删除资源
  Future<void> deleteResource(String resourceId) async {
    try {
      // 从数据库获取资源信息
      final resources = await _db.getResources('');
      final resource = resources.firstWhere((r) => r.id == resourceId);

      // 删除本地文件
      if (resource.localPath != null) {
        final file = File(resource.localPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // 从数据库删除
      await _db.deleteResource(resourceId);

      Logger.info('Resource deleted: $resourceId', tag: 'ResourceService');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete resource',
          error: e, stackTrace: stackTrace, tag: 'ResourceService');
    }
  }

  /// 清理缓存
  Future<void> clearCache(String spaceId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final resourceDir = Directory('${directory.path}/resources/$spaceId');

      if (await resourceDir.exists()) {
        await resourceDir.delete(recursive: true);
        Logger.info('Cache cleared for space: $spaceId', tag: 'ResourceService');
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to clear cache',
          error: e, stackTrace: stackTrace, tag: 'ResourceService');
    }
  }

  /// 获取缓存大小
  Future<int> getCacheSize(String spaceId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final resourceDir = Directory('${directory.path}/resources/$spaceId');

      if (!await resourceDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (var entity in resourceDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      return totalSize;
    } catch (e, stackTrace) {
      Logger.error('Failed to get cache size',
          error: e, stackTrace: stackTrace, tag: 'ResourceService');
      return 0;
    }
  }

  /// 获取资源类型
  String _getResourceType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return 'pdf';
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'mkv':
        return 'video';
      case 'mp3':
      case 'wav':
      case 'm4a':
        return 'audio';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return 'image';
      case 'md':
      case 'txt':
        return 'text';
      default:
        return 'other';
    }
  }

  /// 格式化文件大小
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
