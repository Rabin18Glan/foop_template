part of 'post_bloc.dart';

@immutable
abstract class PostEvent extends Equatable {
  const PostEvent();
  
  @override
  List<Object> get props => [];
}

class PostFetched extends PostEvent {}

class PostRefreshed extends PostEvent {}
