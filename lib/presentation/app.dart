import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../core/routes/app_router.dart';
import '../core/theme/app_theme.dart';
import 'blocs/connectivity/connectivity_bloc.dart';
import 'widgets/connectivity_banner.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppRouter appRouter = GetIt.instance<AppRouter>();
    
    return MaterialApp.router(
      title: 'Flutter Offline/Online Template',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerDelegate: appRouter.delegate(),
      routeInformationParser: appRouter.defaultRouteParser(),
      builder: (context, child) {
        return BlocListener<ConnectivityBloc, ConnectivityState>(
          listener: (context, state) {
            // You can add global connectivity state handling here if needed
          },
          child: Column(
            children: [
              BlocBuilder<ConnectivityBloc, ConnectivityState>(
                builder: (context, state) {
                  if (state is ConnectivityOffline) {
                    return const ConnectivityBanner(
                      message: 'You are offline. Some features may be limited.',
                      color: Colors.red,
                    );
                  } else if (state is ConnectivityOnline && state.wasOffline) {
                    return const ConnectivityBanner(
                      message: 'Back online! Syncing data...',
                      color: Colors.green,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              Expanded(child: child ?? const SizedBox.shrink()),
            ],
          ),
        );
      },
    );
  }
}
