part of 'post_details_bloc.dart';

@immutable
abstract class PostDetailsEvent extends Equatable {
  const PostDetailsEvent();
  
  @override
  List<Object> get props => [];
}

class PostDetailsFetched extends PostDetailsEvent {
  final int id;
  
  const PostDetailsFetched(this.id);
  
  @override
  List<Object> get props => [id];
}
