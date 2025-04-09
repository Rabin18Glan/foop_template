import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../core/usecases/usecase.dart';
import '../../../domain/usecases/sync_posts.dart';
import '../../blocs/connectivity/connectivity_bloc.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          BlocBuilder<ConnectivityBloc, ConnectivityState>(
            builder: (context, state) {
              final isOnline = state is ConnectivityOnline;
              
              return ListTile(
                leading: Icon(
                  isOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: isOnline ? Colors.green : Colors.red,
                ),
                title: Text(isOnline ? 'Online' : 'Offline'),
                subtitle: Text(
                  isOnline
                      ? 'Your data is being synced automatically'
                      : 'Changes will be synced when you\'re back online',
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Sync Data'),
            subtitle: const Text('Manually sync local changes with the server'),
            onTap: () async {
              final syncPosts = GetIt.instance<SyncPosts>();
              final result = await syncPosts(NoParams());
              
              result.fold(
                (failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sync failed: ${failure.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data synced successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Clear Local Data'),
            subtitle: const Text('Delete all cached data from your device'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Local Data'),
                  content: const Text(
                    'Are you sure you want to delete all cached data? '
                    'This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Clear local data
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Local data cleared'),
                          ),
                        );
                      },
                      child: const Text('Clear'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('App information and version'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Flutter Offline/Online Template',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2023 Your Company',
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'A template for creating Flutter apps with offline/online functionality.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
