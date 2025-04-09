import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/entities/post.dart';
import '../../../domain/usecases/get_posts.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final GetPosts getPosts;
  
  PostBloc({required this.getPosts}) : super(PostInitial()) {
    on<PostFetched>(_onPostFetched);
    on<PostRefreshed>(_onPostRefreshed);
  }
  
  Future<void> _onPostFetched(
    PostFetched event,
    Emitter<PostState> emit,
  ) async {
    if (state is PostInitial) {
      emit(PostLoading());
      
      final result = await getPosts(NoParams());
      
      result.fold(
        (failure) => emit(PostError(_mapFailureToMessage(failure))),
        (posts) => emit(PostLoaded(posts)),
      );
    }
  }
  
  Future<void> _onPostRefreshed(
    PostRefreshed event,
    Emitter<PostState> emit,
  ) async {
    emit(PostLoading());
    
    final result = await getPosts(NoParams());
    
    result.fold(
      (failure) => emit(PostError(_mapFailureToMessage(failure))),
      (posts) => emit(PostLoaded(posts)),
    );
  }
  
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message;
      case CacheFailure:
        return failure.message;
      case ConnectionFailure:
        return failure.message;
      case UnauthorizedFailure:
        return failure.message;
      default:
        return 'Unexpected error';
    }
  }
}
