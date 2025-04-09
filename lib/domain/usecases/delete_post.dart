import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/post_repository.dart';

class DeletePost implements UseCase<bool, DeletePostParams> {
  final PostRepository repository;

  DeletePost({required this.repository});

  @override
  Future<Either<Failure, bool>> call(DeletePostParams params) async {
    return await repository.deletePost(params.id);
  }
}

class DeletePostParams extends Equatable {
  final int id;

  const DeletePostParams({required this.id});

  @override
  List<Object> get props => [id];
}
