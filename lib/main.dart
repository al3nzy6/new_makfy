import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:makfy_new/Widget/lib/utils/MyRouteObserver.dart';
import 'package:makfy_new/routes.dart';

void main() {
  runApp(const MakfyApp());
}

class MakfyApp extends StatelessWidget {
  const MakfyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [routeObserver],
      title: 'Makfy',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          textTheme: GoogleFonts.cairoTextTheme()),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate, // لدعم واجهات iOS
      ],
      locale: const Locale('ar'),
      supportedLocales: const [Locale('en', 'US'), Locale('ar')],
      // onGenerateRoute: AppRoutes.generateRoute,
      routes: AppRoutes.routes,
    );
  }
}
