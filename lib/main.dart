import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline_online_template/presentation/blocs/post/post_bloc.dart';
import 'package:flutter_offline_online_template/presentation/blocs/post_details/post_details_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'core/network/network_info.dart';
import 'core/di/injection_container.dart' as di;
import 'presentation/blocs/connectivity/connectivity_bloc.dart';
import 'presentation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDirectory.path);

  // Initialize dependency injection
  await di.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ConnectivityBloc>(
          create: (_) => ConnectivityBloc(
            connectivity: Connectivity(),
            networkInfo: GetIt.instance<NetworkInfo>(),
          )..add(ConnectivityStarted()),
        ),
        BlocProvider<PostBloc>(create: (_) => di.sl<PostBloc>()),
        BlocProvider<PostDetailsBloc>(create: (_) => di.sl<PostDetailsBloc>())
      ],
      child: const App(),
    ),
  );
}
