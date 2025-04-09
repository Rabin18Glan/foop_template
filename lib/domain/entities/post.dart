import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final int id;
  final String title;
  final String body;
  final DateTime createdAt;
  final int userId;
  
  const Post({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.userId,
  });
  
  @override
  List<Object?> get props => [id, title, body, createdAt, userId];
}
