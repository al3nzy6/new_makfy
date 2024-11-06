import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  int? isServiceProvider;
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
      isServiceProvider = prefs.getInt('isServiceProvider');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainScreenWidget(
      isLoading: isLoading,
      start: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15, right: 5, left: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          ),
          SizedBox(
            height: 50,
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _NormalUserprofileSections(),
          ),
          if (isServiceProvider == 1) ...[
            SizedBox(
              height: 10,
            ),
            H1text(text: "قسم موفري الخدمات"),
            SizedBox(
              height: 10,
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _serviceProviderProfileSections(),
            ),
          ]
        ],
      ),
    );
  }

  List<Widget> _NormalUserprofileSections() {
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
    ];
  }

  List<Widget> _serviceProviderProfileSections() {
    return [
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
      boxWidget(
        title: 'الاحياء التي اعمل بها',
        icon: FontAwesomeIcons.mapLocation,
        route: '/my_districts',
        data: [userID, userName],
      ),
    ];
  }
}
