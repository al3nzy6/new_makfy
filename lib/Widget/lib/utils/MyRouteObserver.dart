import 'package:flutter/material.dart';

class MyRouteObserver extends NavigatorObserver {
  String? lastRoute;
  Object? lastRouteArguments; // Store arguments
  String? theFourthRoute; // متغير جديد لتخزين الصفحة الرابعة

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute?.settings.name != null &&
        previousRoute?.settings.name != '/login' &&
        previousRoute?.settings.name != '/update_times' &&
        previousRoute?.settings.name != '/update_location' &&
        previousRoute?.settings.name != '/register') {
      lastRoute = previousRoute!.settings.name;
      lastRouteArguments = previousRoute.settings.arguments; // Store arguments
    }
    super.didPush(route, previousRoute);
  }
}

final MyRouteObserver routeObserver = MyRouteObserver();
