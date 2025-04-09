import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/post.dart';
import '../../blocs/post_details/post_details_bloc.dart';
import '../../widgets/error_message.dart';
import '../../widgets/loading_indicator.dart';

@RoutePage()
class PostDetailsPage extends StatelessWidget {
  final Post post;
  
  const PostDetailsPage({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
      ),
      body: BlocBuilder<PostDetailsBloc, PostDetailsState>(
        builder: (context, state) {
          if (state is PostDetailsInitial) {
            context.read<PostDetailsBloc>().add(PostDetailsFetched(post.id));
            return _buildInitialContent();
          } else if (state is PostDetailsLoading) {
            return const LoadingIndicator();
          } else if (state is PostDetailsLoaded) {
            return _buildPostDetails(context, state.post);
          } else if (state is PostDetailsError) {
            return ErrorMessage(
              message: state.message,
              onRetry: () => context.read<PostDetailsBloc>().add(PostDetailsFetched(post.id)),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
  
  Widget _buildInitialContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Posted on ${DateFormatter.formatDate(post.createdAt)}',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            post.body,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Center(
            child: CircularProgressIndicator(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading additional details...',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildPostDetails(BuildContext context, Post post) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Posted on ${DateFormatter.formatDate(post.createdAt)}',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            post.body,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // Edit post
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Delete post
                },
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
