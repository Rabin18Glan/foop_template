import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

class UpdatePost implements UseCase<Post, UpdatePostParams> {
  final PostRepository repository;

  UpdatePost({required this.repository});

  @override
  Future<Either<Failure, Post>> call(UpdatePostParams params) async {
    return await repository.updatePost(params.post);
  }
}

class UpdatePostParams extends Equatable {
  final Post post;

  const UpdatePostParams({required this.post});

  @override
  List<Object> get props => [post];
}
