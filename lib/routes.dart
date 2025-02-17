import 'package:flutter/material.dart';
import 'package:makfy_new/Screens/DeleteUserScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:makfy_new/Screens/ForgotPasswordPage.dart';
import 'package:makfy_new/Screens/MyHomePage.dart';
import 'package:makfy_new/Screens/PaymentPage.dart';
import 'package:makfy_new/Screens/ProfilePage.dart';
import 'package:makfy_new/Screens/ServicePage.dart';
import 'package:makfy_new/Screens/ShoppingCertPage.dart';
import 'package:makfy_new/Screens/UpdateLocationScreen.dart';
import 'package:makfy_new/Screens/UpdateTimesScreen.dart';
import 'package:makfy_new/Screens/VacationScreen.dart';
import 'package:makfy_new/Screens/createServicePage.dart';
import 'package:makfy_new/Screens/loginPage.dart';
import 'package:makfy_new/Screens/mainsectionPage.dart';
import 'package:makfy_new/Screens/myDistrictsPage.dart';
import 'package:makfy_new/Screens/registration_page.dart';
import 'package:makfy_new/Screens/userServicesPage.dart';
import 'package:makfy_new/Screens/personalProfilePage.dart';
import 'package:makfy_new/Screens/subsectionPage.dart';

Future<bool> checkIfLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.containsKey('auth_token'); // فحص وجود "auth_token"
}

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => MyHomePage(), // صفحة تحميل مؤقتة للتحقق
    '/home': (context) => MyHomePage(), // الصفحة الرئيسية
    '/login': (context) => LoginPage(),
    '/forgot-password': (context) => const ForgotPasswordPage(),
    '/register': (context) => RegistrationPage(),
    '/profile': (context) => Profilepage(),
    '/main_section': (context) => Mainsectionpage(),
    '/sub_section': (context) => Subsectionpage(),
    '/service_page': (context) => ServicePage(),
    '/personal_profile': (context) => RegistrationPage(),
    '/shopping_cert': (context) => ShoppingCertPage(),
    '/my_orders': (context) => ShoppingCertPage(),
    '/customer_orders': (context) => ShoppingCertPage(),
    '/create_service': (context) => createServicePage(),
    '/user_page': (context) => userServicesPage(),
    '/payment_page': (context) => PaymentPage(),
    '/my_districts': (context) => MyDistrictsPage(),
    '/my_dues': (context) => myDuesPage(),
    '/update_location': (context) => UpdateLocationScreen(),
    '/update_times': (context) => UpdateTimesScreen(),
    '/vacation_page': (context) => VacationScreen(),
    '/account_delete': (context) => DeleteUserScreen(),
  };
}

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // استدعاء الدالة للتحقق من حالة تسجيل الدخول
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus(context);
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // شاشة تحميل مؤقتة أثناء التحقق
      ),
    );
  }

  // دالة للتحقق من حالة تسجيل الدخول وتوجيه المستخدم
  Future<void> _checkLoginStatus(BuildContext context) async {
    bool isLoggedIn = await checkIfLoggedIn();

    // قائمة المسارات المسموحة دون تسجيل الدخول
    List<String> allowedRoutes = [
      '/',
      '/home',
      '/service_page',
      '/main_section',
      '/sub_section',
      '/user_page',
      '/login',
      '/forgot-password',
    ];

    if (!isLoggedIn &&
        !allowedRoutes.contains(ModalRoute.of(context)?.settings.name)) {
      // إذا لم يكن مسجلاً الدخول والمسار غير مسموح
      Navigator.pushReplacementNamed(
          context, '/login'); // التوجيه لصفحة تسجيل الدخول
    } else {
      // إذا كان المسار مسموح أو مسجل الدخول
      Navigator.pushReplacementNamed(
          context,
          ModalRoute.of(context)?.settings.name ??
              '/home'); // التوجيه للصفحة المطلوبة
    }
  }
}
