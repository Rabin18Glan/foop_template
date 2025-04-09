import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/post_repository.dart';

class SyncPosts implements UseCase<bool, NoParams> {
  final PostRepository repository;

  SyncPosts({required this.repository});

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.syncPosts();
  }
}
