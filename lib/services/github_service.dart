import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../core/utils/logger.dart';

/// GitHub 服务 - 搜索和下载 GitHub 资源
class GitHubService {
  static final GitHubService _instance = GitHubService._internal();
  factory GitHubService() => _instance;

  GitHubService._internal();

  late final Dio _dio;

  /// 初始化
  Future<void> init() async {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(milliseconds: 30000),
      receiveTimeout: const Duration(milliseconds: 60000),
      sendTimeout: const Duration(milliseconds: 30000),
      headers: {
        'Accept': 'application/vnd.github.v3+json',
      },
    ));

    Logger.info('GitHub Service initialized', tag: 'GitHubService');
  }

  /// 搜索仓库
  Future<List<Map<String, dynamic>>> searchRepositories({
    required String query,
    String? language,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      Logger.network('GET', 'search/repositories', tag: 'GitHubService');

      final searchQuery = language != null ? '$query language:$language' : query;

      final response = await _dio.get(
        'https://api.github.com/search/repositories',
        queryParameters: {
          'q': searchQuery,
          'page': page,
          'per_page': perPage,
          'sort': 'updated',
          'order': 'desc',
        },
      );

      Logger.response(
        'search/repositories',
        statusCode: response.statusCode,
        tag: 'GitHubService',
      );

      final items = response.data['items'] as List;
      return items.map((item) {
        return {
          'id': item['id'],
          'name': item['name'],
          'fullName': item['full_name'],
          'description': item['description'],
          'url': item['html_url'],
          'stars': item['stargazers_count'],
          'forks': item['forks_count'],
          'language': item['language'],
          'updatedAt': item['updated_at'],
          'owner': {
            'login': item['owner']['login'],
            'avatarUrl': item['owner']['avatar_url'],
          },
        };
      }).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to search repositories',
          error: e, stackTrace: stackTrace, tag: 'GitHubService');
      rethrow;
    }
  }

  /// 搜索文件
  Future<List<Map<String, dynamic>>> searchFiles({
    required String query,
    String? repo,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      Logger.network('GET', 'search/code', tag: 'GitHubService');

      final searchQuery = repo != null ? '$query repo:$repo' : query;

      final response = await _dio.get(
        'https://api.github.com/search/code',
        queryParameters: {
          'q': searchQuery,
          'page': page,
          'per_page': perPage,
        },
      );

      Logger.response('search/code', statusCode: response.statusCode, tag: 'GitHubService');

      final items = response.data['items'] as List;
      return items.map((item) {
        return {
          'name': item['name'],
          'path': item['path'],
          'url': item['html_url'],
          'repository': item['repository']['full_name'],
        };
      }).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to search files',
          error: e, stackTrace: stackTrace, tag: 'GitHubService');
      rethrow;
    }
  }

  /// 获取仓库内容
  Future<List<Map<String, dynamic>>> getRepositoryContents({
    required String owner,
    required String repo,
    String path = '',
  }) async {
    try {
      Logger.network('GET', 'repos/$owner/$repo/contents/$path', tag: 'GitHubService');

      final response = await _dio.get(
        'https://api.github.com/repos/$owner/$repo/contents/$path',
      );

      Logger.response(
        'repos/$owner/$repo/contents/$path',
        statusCode: response.statusCode,
        tag: 'GitHubService',
      );

      if (response.data is List) {
        return (response.data as List).map((item) {
          return {
            'name': item['name'],
            'type': item['type'],
            'path': item['path'],
            'url': item['url'],
            'downloadUrl': item['download_url'],
            'size': item['size'],
          };
        }).toList();
      } else {
        return [response.data as Map<String, dynamic>];
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to get repository contents',
          error: e, stackTrace: stackTrace, tag: 'GitHubService');
      rethrow;
    }
  }

  /// 下载文件
  Future<String> downloadFile({
    required String url,
    required String fileName,
  }) async {
    try {
      Logger.info('Downloading file: $fileName', tag: 'GitHubService');

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/resources/$fileName';

      // 确保目录存在
      await Directory('${directory.path}/resources').create(recursive: true);

      // 下载文件
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(2);
            Logger.debug('Download progress: $progress%', tag: 'GitHubService');
          }
        },
      );

      Logger.info('File downloaded: $filePath', tag: 'GitHubService');
      return filePath;
    } catch (e, stackTrace) {
      Logger.error('Failed to download file',
          error: e, stackTrace: stackTrace, tag: 'GitHubService');
      rethrow;
    }
  }

  /// 获取仓库文件列表
  Future<List<Map<String, dynamic>>> getRepositoryFiles({
    required String owner,
    required String repo,
    String path = '',
    String? extension,
  }) async {
    try {
      final contents = await getRepositoryContents(
        owner: owner,
        repo: repo,
        path: path,
      );

      // 过滤文件类型
      if (extension != null) {
        return contents
            .where((item) =>
                item['type'] == 'file' && item['name'].toString().endsWith(extension))
            .toList();
      }

      return contents.where((item) => item['type'] == 'file').toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get repository files',
          error: e, stackTrace: stackTrace, tag: 'GitHubService');
      return [];
    }
  }

  /// 获取 PDF 文件列表
  Future<List<Map<String, dynamic>>> getPdfFiles({
    required String owner,
    required String repo,
    String path = '',
  }) async {
    return await getRepositoryFiles(
      owner: owner,
      repo: repo,
      path: path,
      extension: '.pdf',
    );
  }

  /// 获取图片文件列表
  Future<List<Map<String, dynamic>>> getImageFiles({
    required String owner,
    required String repo,
    String path = '',
  }) async {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];

    final files = await getRepositoryFiles(
      owner: owner,
      repo: repo,
      path: path,
    );

    return files.where((item) {
      final fileName = item['name'].toString().toLowerCase();
      return imageExtensions.any((ext) => fileName.endsWith(ext));
    }).toList();
  }

  /// 克隆仓库（仅下载特定文件）
  Future<List<String>> cloneRepository({
    required String owner,
    required String repo,
    String? path,
    String? fileExtension,
  }) async {
    try {
      Logger.info('Cloning repository: $owner/$repo', tag: 'GitHubService');

      final files = await getRepositoryFiles(
        owner: owner,
        repo: repo,
        path: path,
        extension: fileExtension,
      );

      final downloadedFiles = <String>[];

      for (var file in files) {
        final downloadUrl = file['downloadUrl'];
        if (downloadUrl != null) {
          try {
            final localPath = await downloadFile(
              url: downloadUrl,
              fileName: file['name'],
            );
            downloadedFiles.add(localPath);
          } catch (e) {
            Logger.error('Failed to download file: ${file['name']}',
                error: e, tag: 'GitHubService');
          }
        }
      }

      Logger.info('Repository cloned: ${downloadedFiles.length} files',
          tag: 'GitHubService');
      return downloadedFiles;
    } catch (e, stackTrace) {
      Logger.error('Failed to clone repository',
          error: e, stackTrace: tag: 'GitHubService');
      rethrow;
    }
  }
}
