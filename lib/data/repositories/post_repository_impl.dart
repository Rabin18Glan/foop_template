import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/local/app_database.dart';
import '../datasources/remote/api_client.dart';
import '../models/post_model.dart';

class PostRepositoryImpl implements PostRepository {
  final ApiClient remoteDataSource;
  final AppDatabase localDataSource;
  final NetworkInfo networkInfo;

  PostRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Post>>> getPosts() async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remotePosts = await remoteDataSource.getPosts();
          await localDataSource.savePosts(remotePosts);
          return Right(remotePosts);
        } on ServerException catch (e) {
          return Left(ServerFailure(message: e.message));
        } on UnauthorizedException catch (e) {
          return Left(UnauthorizedFailure(message: e.message));
        } on ConnectionException catch (e) {
          // If remote fails, try to get from local
          final localPosts = await localDataSource.getPosts();
          return Right(localPosts);
        }
      } else {
        // If offline, get from local
        final localPosts = await localDataSource.getPosts();
        return Right(localPosts);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Post>> getPostById(int id) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remotePost = await remoteDataSource.getPostById(id);
          await localDataSource.savePost(remotePost);
          return Right(remotePost);
        } on ServerException catch (e) {
          // If remote fails, try to get from local
          final localPost = await localDataSource.getPostById(id);
          if (localPost != null) {
            return Right(localPost);
          }
          return Left(ServerFailure(message: e.message));
        } on UnauthorizedException catch (e) {
          return Left(UnauthorizedFailure(message: e.message));
        } on ConnectionException catch (e) {
          // If connection fails, try to get from local
          final localPost = await localDataSource.getPostById(id);
          if (localPost != null) {
            return Right(localPost);
          }
          return Left(ConnectionFailure(message: e.message));
        }
      } else {
        // If offline, get from local
        final localPost = await localDataSource.getPostById(id);
        if (localPost != null) {
          return Right(localPost);
        }
        return Left(ConnectionFailure(message: 'No internet connection'));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Post>> createPost(Post post) async {
    try {
      final postModel = PostModel.fromEntity(post);

      if (await networkInfo.isConnected) {
        try {
          final createdPost = await remoteDataSource.createPost(postModel);
          await localDataSource.savePost(createdPost);
          return Right(createdPost);
        } on ServerException catch (e) {
          // If server fails, save locally for later sync
          final localPost = await localDataSource.createLocalPost(postModel);
          return Right(localPost);
        } on UnauthorizedException catch (e) {
          return Left(UnauthorizedFailure(message: e.message));
        } on ConnectionException catch (e) {
          // If connection fails, save locally for later sync
          final localPost = await localDataSource.createLocalPost(postModel);
          return Right(localPost);
        }
      } else {
        // If offline, save locally for later sync
        final localPost = await localDataSource.createLocalPost(postModel);
        return Right(localPost);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Post>> updatePost(Post post) async {
    try {
      final postModel = PostModel.fromEntity(post);

      if (await networkInfo.isConnected) {
        try {
          final updatedPost = await remoteDataSource.updatePost(postModel);
          await localDataSource.savePost(updatedPost);
          return Right(updatedPost);
        } on ServerException catch (e) {
          // If server fails, update locally and mark for sync
          final localPost = postModel.copyWith(isSynced: false);
          await localDataSource.savePost(localPost);
          await localDataSource.addPendingAction(
            PendingAction(
              id: const Uuid().v4(),
              actionType: ActionType.update,
              data: localPost.toJson(),
              timestamp: DateTime.now(),
            ),
          );
          return Right(localPost);
        } on UnauthorizedException catch (e) {
          return Left(UnauthorizedFailure(message: e.message));
        } on ConnectionException catch (e) {
          // If connection fails, update locally and mark for sync
          final localPost = postModel.copyWith(isSynced: false);
          await localDataSource.savePost(localPost);
          await localDataSource.addPendingAction(
            PendingAction(
              id: const Uuid().v4(),
              actionType: ActionType.update,
              data: localPost.toJson(),
              timestamp: DateTime.now(),
            ),
          );
          return Right(localPost);
        }
      } else {
        // If offline, update locally and mark for sync
        final localPost = postModel.copyWith(isSynced: false);
        await localDataSource.savePost(localPost);
        await localDataSource.addPendingAction(
          PendingAction(
            id: const Uuid().v4(),
            actionType: ActionType.update,
            data: localPost.toJson(),
            timestamp: DateTime.now(),
          ),
        );
        return Right(localPost);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deletePost(int id) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final result = await remoteDataSource.deletePost(id);
          if (result) {
            await localDataSource.deletePost(id);
          }
          return Right(result);
        } on ServerException catch (e) {
          // If server fails, mark for deletion later
          final post = await localDataSource.getPostById(id);
          if (post != null) {
            await localDataSource.addPendingAction(
              PendingAction(
                id: const Uuid().v4(),
                actionType: ActionType.delete,
                data: {'id': id},
                timestamp: DateTime.now(),
              ),
            );
          }
          return Left(ServerFailure(message: e.message));
        } on UnauthorizedException catch (e) {
          return Left(UnauthorizedFailure(message: e.message));
        } on ConnectionException catch (e) {
          // If connection fails, mark for deletion later
          final post = await localDataSource.getPostById(id);
          if (post != null) {
            await localDataSource.addPendingAction(
              PendingAction(
                id: const Uuid().v4(),
                actionType: ActionType.delete,
                data: {'id': id},
                timestamp: DateTime.now(),
              ),
            );
          }
          return Left(ConnectionFailure(message: e.message));
        }
      } else {
        // If offline, mark for deletion later
        final post = await localDataSource.getPostById(id);
        if (post != null) {
          await localDataSource.addPendingAction(
            PendingAction(
              id: const Uuid().v4(),
              actionType: ActionType.delete,
              data: {'id': id},
              timestamp: DateTime.now(),
            ),
          );
        }
        return Left(ConnectionFailure(message: 'No internet connection'));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> syncPosts() async {
    try {
      if (!(await networkInfo.isConnected)) {
        return Left(ConnectionFailure(message: 'No internet connection'));
      }

      final pendingActions = await localDataSource.getPendingActions();

      // Sort by timestamp to process in order
      pendingActions.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      for (var action in pendingActions) {
        try {
          switch (action.actionType) {
            case ActionType.create:
              final post = PostModel.fromJson(action.data);
              await remoteDataSource.createPost(post);
              break;
            case ActionType.update:
              final post = PostModel.fromJson(action.data);
              await remoteDataSource.updatePost(post);
              break;
            case ActionType.delete:
              final id = action.data['id'] as int;
              await remoteDataSource.deletePost(id);
              break;
          }

          // Remove the pending action after successful sync
          await localDataSource.removePendingAction(action.id);
        } catch (e) {
          // Continue with next action if one fails
          continue;
        }
      }

      // Refresh local data from server
      final remotePosts = await remoteDataSource.getPosts();
      await localDataSource.savePosts(remotePosts);

      return const Right(true);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
