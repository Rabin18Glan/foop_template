import 'package:hive/hive.dart';

import '../../domain/entities/post.dart';

part 'post_model.g.dart';

@HiveType(typeId: 0)
class PostModel extends Post {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String body;
  
  @HiveField(3)
  final DateTime createdAt;
  
  @HiveField(4)
  final int userId;
  
  @HiveField(5)
  final bool isSynced;
  
  @HiveField(6)
  final String? localId;
  
  const PostModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.userId,
    this.isSynced = true,
    this.localId,
  }) : super(
          id: id,
          title: title,
          body: body,
          createdAt: createdAt,
          userId: userId,
        );
  
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      userId: json['user_id'],
    );
  }
  
  factory PostModel.fromEntity(Post post, {bool isSynced = true, String? localId}) {
    return PostModel(
      id: post.id,
      title: post.title,
      body: post.body,
      createdAt: post.createdAt,
      userId: post.userId,
      isSynced: isSynced,
      localId: localId,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
    };
  }
  
  PostModel copyWith({
    int? id,
    String? title,
    String? body,
    DateTime? createdAt,
    int? userId,
    bool? isSynced,
    String? localId,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      isSynced: isSynced ?? this.isSynced,
      localId: localId ?? this.localId,
    );
  }
}
