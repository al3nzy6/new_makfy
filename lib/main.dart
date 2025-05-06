import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:makfy_new/Widget/lib/utils/MyRouteObserver.dart';
import 'package:makfy_new/routes.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';


void main() {
    WidgetsFlutterBinding.ensureInitialized(); // ضروري قبل أي async
   TabbySDK().setup(
    withApiKey: 'pk_test_0196535c-5b48-f8f0-a61c-348d25dbcee5', // Put here your Api key, given by the Tabby integrations team
  );
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
