import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/post.dart';
import '../../../domain/usecases/get_post_details.dart';

part 'post_details_event.dart';
part 'post_details_state.dart';

class PostDetailsBloc extends Bloc<PostDetailsEvent, PostDetailsState> {
  final GetPostDetails getPostDetails;
  
  PostDetailsBloc({required this.getPostDetails}) : super(PostDetailsInitial()) {
    on<PostDetailsFetched>(_onPostDetailsFetched);
  }
  
  Future<void> _onPostDetailsFetched(
    PostDetailsFetched event,
    Emitter<PostDetailsState> emit,
  ) async {
    emit(PostDetailsLoading());
    
    final result = await getPostDetails(PostParams(id: event.id));
    
    result.fold(
      (failure) => emit(PostDetailsError(_mapFailureToMessage(failure))),
      (post) => emit(PostDetailsLoaded(post)),
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
