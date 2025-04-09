import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/post_details/post_details_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../../domain/entities/post.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, initial: true),
    AutoRoute(page: PostDetailsRoute.page),
    AutoRoute(page: SettingsRoute.page),
  ];
}
