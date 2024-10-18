import 'package:flutter/material.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';

import 'package:makfy_new/Widget/H1textWidget.dart';
import 'package:makfy_new/Widget/H2Text.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';
import 'package:makfy_new/Widget/appHeadWidget.dart';
import 'package:makfy_new/Widget/boxWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profilepage extends StatefulWidget {
  const Profilepage({super.key});

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  bool isLoading = false;
  String? userName;
  int? userID;
  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'غير معروف';
      userID = prefs.getInt('user_id');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainScreenWidget(
      isLoading: isLoading,
      start: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              H1text(text: userName ?? 'non'),
              InkWell(
                onTap: () {
                  ApiConfig apiConfig = ApiConfig();
                  apiConfig.logout();
                  Navigator.pushReplacementNamed(context, '/');
                },
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0XFFEF5B2C),
                  ),
                  child: Icon(
                    Icons.logout_sharp,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 50,
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _profileSections(),
          ),
        ],
      ),
    );
  }

  List<Widget> _profileSections() {
    return [
      boxWidget(
        title: 'طلباتي',
        route: '/my_orders',
      ),
      boxWidget(
          title: 'بياناتي',
          icon: Icons.person_2_sharp,
          route: '/personal_profile',
          data: [2]),
      boxWidget(
          title: 'السلة', icon: Icons.shopping_cart, route: '/shopping_cert'),
      boxWidget(
          title: 'طلبات خدماتي',
          icon: Icons.request_page,
          route: '/customer_orders'),
      boxWidget(
        title: 'خدماتي',
        icon: Icons.list,
        route: '/user_page',
        data: [userID, userName],
      ),
    ];
  }
}
