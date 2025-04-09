import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

class GetPostDetails implements UseCase<Post, PostParams> {
  final PostRepository repository;

  GetPostDetails({required this.repository});

  @override
  Future<Either<Failure, Post>> call(PostParams params) async {
    return await repository.getPostById(params.id);
  }
}

class PostParams extends Equatable {
  final int id;

  const PostParams({required this.id});

  @override
  List<Object> get props => [id];
}
