import 'package:flutter/material.dart';
import 'package:makfy_new/Screens/ForgotPasswordPage.dart';
import 'package:makfy_new/Screens/MyHomePage.dart';
import 'package:makfy_new/Screens/PaymentPage.dart';
import 'package:makfy_new/Screens/ProfilePage.dart';
import 'package:makfy_new/Screens/ServicePage.dart';
import 'package:makfy_new/Screens/ShoppingCertPage.dart';
import 'package:makfy_new/Screens/UpdateLocationScreen.dart';
import 'package:makfy_new/Screens/createServicePage.dart';
import 'package:makfy_new/Screens/loginPage.dart';
import 'package:makfy_new/Screens/mainsectionPage.dart';
import 'package:makfy_new/Screens/myDistrictsPage.dart';
import 'package:makfy_new/Screens/registration_page.dart';
import 'package:makfy_new/Screens/userServicesPage.dart';
import 'package:makfy_new/Screens/personalProfilePage.dart';
import 'package:makfy_new/Screens/subsectionPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> checkIfLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.containsKey('auth_token');
}

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => LoadingPage(), // استخدم صفحة تحميل كمؤقت للتحقق
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
  };
}

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _checkLoginStatus(context);
    return Scaffold(
      body: Center(child: CircularProgressIndicator()), // شاشة تحميل مؤقتة
    );
  }

  // دالة للتحقق من حالة تسجيل الدخول وتوجيه المستخدم
  void _checkLoginStatus(BuildContext context) async {
    bool isLoggedIn = await checkIfLoggedIn();

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(
          context, '/home'); // إذا كان مسجلًا، انتقل إلى الصفحة الرئيسية
    } else {
      Navigator.pushReplacementNamed(
          context, '/login'); // إذا لم يكن مسجلًا، انتقل إلى صفحة تسجيل الدخول
    }
  }
}
