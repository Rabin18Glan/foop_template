import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

class CreatePost implements UseCase<Post, CreatePostParams> {
  final PostRepository repository;

  CreatePost({required this.repository});

  @override
  Future<Either<Failure, Post>> call(CreatePostParams params) async {
    return await repository.createPost(params.post);
  }
}

class CreatePostParams extends Equatable {
  final Post post;

  const CreatePostParams({required this.post});

  @override
  List<Object> get props => [post];
}
