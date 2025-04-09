import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

class GetPosts implements UseCase<List<Post>, NoParams> {
  final PostRepository repository;

  GetPosts({required this.repository});

  @override
  Future<Either<Failure, List<Post>>> call(NoParams params) async {
    return await repository.getPosts();
  }
}
