part of 'post_details_bloc.dart';

@immutable
abstract class PostDetailsState extends Equatable {
  const PostDetailsState();
  
  @override
  List<Object> get props => [];
}

class PostDetailsInitial extends PostDetailsState {}

class PostDetailsLoading extends PostDetailsState {}

class PostDetailsLoaded extends PostDetailsState {
  final Post post;
  
  const PostDetailsLoaded(this.post);
  
  @override
  List<Object> get props => [post];
}

class PostDetailsError extends PostDetailsState {
  final String message;
  
  const PostDetailsError(this.message);
  
  @override
  List<Object> get props => [message];
}
