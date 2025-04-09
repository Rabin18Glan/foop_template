import 'package:dartz/dartz.dart';

import '../entities/post.dart';
import '../../core/error/failures.dart';

abstract class PostRepository {
  /// Gets all posts from the API or local cache if offline
  Future<Either<Failure, List<Post>>> getPosts();
  
  /// Gets a specific post by ID
  Future<Either<Failure, Post>> getPostById(int id);
  
  /// Creates a new post
  Future<Either<Failure, Post>> createPost(Post post);
  
  /// Updates an existing post
  Future<Either<Failure, Post>> updatePost(Post post);
  
  /// Deletes a post
  Future<Either<Failure, bool>> deletePost(int id);
  
  /// Syncs local changes with the remote server when back online
  Future<Either<Failure, bool>> syncPosts();
}
