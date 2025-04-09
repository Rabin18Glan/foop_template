import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

import '../../../core/routes/app_router.dart';
import '../../../domain/entities/post.dart';
import '../../blocs/connectivity/connectivity_bloc.dart';
import '../../blocs/post/post_bloc.dart';
import '../../widgets/error_message.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/post_list_item.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.router.push(const SettingsRoute()),
          ),
        ],
      ),
      body: BlocBuilder<ConnectivityBloc, ConnectivityState>(
        builder: (context, connectivityState) {
          return BlocBuilder<PostBloc, PostState>(
            builder: (context, state) {
              if (state is PostInitial) {
                context.read<PostBloc>().add(PostFetched());
                return const LoadingIndicator();
              } else if (state is PostLoading) {
                return const LoadingIndicator();
              } else if (state is PostLoaded) {
                return _buildPostList(context, state.posts, connectivityState);
              } else if (state is PostError) {
                return ErrorMessage(
                  message: state.message,
                  onRetry: () => context.read<PostBloc>().add(PostRefreshed()),
                );
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create post page
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildPostList(BuildContext context, List<Post> posts, ConnectivityState connectivityState) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<PostBloc>().add(PostRefreshed());
      },
      child: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostListItem(
            post: post,
            onTap: () => context.router.push(PostDetailsRoute(post: post)),
          );
        },
      ),
    );
  }
}
