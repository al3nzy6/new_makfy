import 'package:flutter/material.dart';
import 'package:makfy_new/Widget/H2Text.dart';
import 'package:makfy_new/Widget/lib/utils/MyRouteObserver.dart';
import 'package:shared_preferences/shared_preferences.dart';

class appHeadWidget extends StatefulWidget {
  final List? routeArguments;

  appHeadWidget({
    Key? key,
    this.routeArguments,
  }) : super(key: key);

  @override
  State<appHeadWidget> createState() => _appHeadWidgetState();
}

class _appHeadWidgetState extends State<appHeadWidget> {
  final prefs = SharedPreferences.getInstance();

  int? isServiceProvider = 0;
  String? user_email;
  String? redirectToPage;

  @override
  @override
  void initState() {
    super.initState();
    _loadSharedPreferences();
  }

  Future<void> _loadSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        isServiceProvider = prefs.getInt('isServiceProvider');
        user_email = prefs.getString('user_email');
      });
    }
  }

  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
        color: Colors.black.withOpacity(0.1),
        width: 1,
      ))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Text("${ModalRoute.of(context)?.settings.name}"),
          Image.asset(
            'images/logo.png',
            height: 100,
          ),
          if (user_email == null)
            if (ModalRoute.of(context)?.settings.name != '/login' &&
                ModalRoute.of(context)?.settings.name != '/register')
              InkWell(
                onTap: () {
                  routeObserver.lastRouteArguments = args;
                  Navigator.pushNamed(context, '/login');
                },
                child: Container(
                    height: 50,
                    padding: EdgeInsets.all(1),
                    decoration: const BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      color: Color(0XFFEF5B2C),
                    ),
                    child: H2Text(
                      text: "تسجيل الدخول",
                      textColor: Colors.white,
                    )),
              ),
          if (user_email != null)
            (isServiceProvider == 1)
                ? Expanded(
                    child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/customer_orders');
                          // Navigator.pushNamed(context, '/shopping_cert');
                        },
                        child: Container(
                          height: 50,
                          margin: EdgeInsets.only(left: 15, right: 15),
                          alignment: Alignment.centerLeft,
                          decoration: const BoxDecoration(
                              color: Color(0XFFEF5B2C),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30))),
                          child: Center(
                              child: H2Text(
                            text: "طلبات العملاء",
                            textColor: Colors.white,
                            size: 16,
                          )),
                        )))
                : Expanded(
                    child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/shopping_cert');
                        },
                        child: Container(
                          height: 50,
                          margin: EdgeInsets.only(left: 15, right: 15),
                          alignment: Alignment.centerLeft,
                          decoration: const BoxDecoration(
                              color: Color(0XFFEF5B2C),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30))),
                          child: Center(
                              child: H2Text(
                            text: "السلة",
                            textColor: Colors.white,
                            size: 16,
                          )),
                        ))),
          // (ModalRoute.of(context)?.settings.name != '/login')
          InkWell(
            onTap: () {
              if (ModalRoute.of(context)?.settings.name == '/home' ||
                  ModalRoute.of(context)?.settings.name == '/') {
                Navigator.pushNamed(context, '/profile');
              } else {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context); // الرجوع للصفحة السابقة
                } else {
                  Navigator.pushReplacementNamed(context,
                      '/home'); // لا يوجد صفحة سابقة، الذهاب للصفحة الرئيسية
                }
              }
            },
            child: Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: Color(0XFFEF5B2C), shape: BoxShape.circle),
              child: Center(
                  child: Icon(
                (ModalRoute.of(context)?.settings.name == '/home' ||
                        ModalRoute.of(context)?.settings.name == '/')
                    ? Icons.person
                    : Icons.arrow_forward,
                color: Colors.white,
                size: 35,
              )),
            ),
          )
          // : SizedBox.shrink(),
        ],
      ),
    );
  }
}
