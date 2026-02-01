import 'package:json_annotation/json_annotation.dart';

part 'resource.g.dart';

/// 资源模型（GitHub、网络资源等）
@JsonSerializable()
class Resource {
  final String id;
  final String spaceId;
  final String title;
  final String description;
  final String type; // pdf, video, audio, image, text
  final String source; // github, web, local
  final String? url; // 资源链接
  final String? localPath; // 本地存储路径
  final List<String>? tags;
  final int fileSize; // 文件大小（字节）
  final String? githubRepo; // GitHub 仓库
  final String? githubPath; // GitHub 路径
  final DateTime createdAt;
  final DateTime? updatedAt;

  Resource({
    required this.id,
    required this.spaceId,
    required this.title,
    required this.description,
    required this.type,
    required this.source,
    this.url,
    this.localPath,
    this.tags,
    this.fileSize = 0,
    this.githubRepo,
    this.githubPath,
    required this.createdAt,
    this.updatedAt,
  });

  factory Resource.fromJson(Map<String, dynamic> json) =>
      _$ResourceFromJson(json);

  Map<String, dynamic> toJson() => _$ResourceToJson(this);

  Resource copyWith({
    String? id,
    String? spaceId,
    String? title,
    String? description,
    String? type,
    String? source,
    String? url,
    String? localPath,
    List<String>? tags,
    int? fileSize,
    String? githubRepo,
    String? githubPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Resource(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      source: source ?? this.source,
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
      tags: tags ?? this.tags,
      fileSize: fileSize ?? this.fileSize,
      githubRepo: githubRepo ?? this.githubRepo,
      githubPath: githubPath ?? this.githubPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 是否已下载
  bool get isDownloaded => localPath != null && localPath!.isNotEmpty;

  /// 文件大小格式化
  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(2)} KB';
    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// 是否是 PDF 资源
  bool get isPdf => type == 'pdf';

  /// 是否是视频资源
  bool get isVideo => type == 'video';

  /// 是否是音频资源
  bool get isAudio => type == 'audio';

  /// 是否是图片资源
  bool get isImage => type == 'image';
}
