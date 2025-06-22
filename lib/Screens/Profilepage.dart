import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';

import 'package:makfy_new/Widget/H1textWidget.dart';
import 'package:makfy_new/Widget/H2Text.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';
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
                    if (userID == null) {
                      Navigator.pushReplacementNamed(context, '/login');
                    } else {
                      apiConfig.logout();
                      Navigator.pushReplacementNamed(context, '/');
                    }
                  },
                  child: Container(
                      height: 50,
                      padding: EdgeInsets.all(1),
                      decoration: const BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        color: Color(0XFFEF5B2C),
                      ),
                      child: H2Text(
                        text: userID == null ? "تسجيل الدخول" : "تسجيل لخروج",
                        textColor: Colors.white,
                      )),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: (userID != null) ? _NormalUserprofileSections() : [],
          ),
          if (isServiceProvider == 1) ...[
            const SizedBox(
              height: 10,
            ),
            H1text(text: "قسم موفري الخدمات"),
            const SizedBox(
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
        icon: FontAwesomeIcons.cartFlatbed,
        width: 120,
        height: 120,
        iconSize: 40,
      ),
      boxWidget(
          title: 'بياناتي',
          icon: Icons.person_2_sharp,
          route: '/personal_profile',
          iconSize: 50,
          width: 100,
          height: 120,
          data: [2]),
      boxWidget(
        title: 'السلة',
        icon: Icons.shopping_cart,
        iconSize: 50,
        width: 100,
        height: 120,
        route: '/shopping_cert',
      ),
      boxWidget(
        title: 'حذف الحساب',
        icon: Icons.archive,
        iconSize: 50,
        width: 100,
        height: 120,
        route: '/account_delete',
      ),
    ];
  }

  List<Widget> _serviceProviderProfileSections() {
    return [
      boxWidget(
        title: 'طلبات العملاء',
        icon: Icons.request_page,
        route: '/customer_orders',
        iconSize: 50,
        width: 100,
        height: 120,
      ),
      InkWell(
        onTap: () {
          print(userID);
          Navigator.pushNamed(context, '/user_page',
              arguments: {"id": userID, "title": userName});
        },
        child: boxWidget(
          title: 'خدماتي',
          icon: Icons.list,
          iconSize: 50,
          width: 100,
          height: 120,
        ),
      ),
      // boxWidget(
      //   title: 'الاحياء التي اعمل بها',
      //   icon: FontAwesomeIcons.mapLocation,
      //   route: '/my_districts',
      //   data: [userID, userName],
      //   iconSize: 50,
      //   width: 100,
      //   height: 120,
      // ),
      boxWidget(
        title: 'مستحقاتي',
        icon: FontAwesomeIcons.moneyCheck,
        route: '/my_dues',
        data: [userID, userName],
        iconSize: 50,
        width: 100,
        height: 120,
      ),
      boxWidget(
        title: 'تحديث الموقع',
        icon: FontAwesomeIcons.locationCrosshairs,
        route: '/update_location',
        data: [userID, userName],
        iconSize: 50,
        width: 100,
        height: 120,
      ),
      boxWidget(
        title: 'اوقات العمل',
        icon: FontAwesomeIcons.clock,
        route: '/update_times',
        data: [userID, userName],
        iconSize: 50,
        width: 100,
        height: 120,
      ),
      boxWidget(
        title: 'الاجازات',
        icon: FontAwesomeIcons.businessTime,
        route: '/vacation_page',
        data: [userID, userName],
        iconSize: 50,
        width: 100,
        height: 120,
      ),
    ];
  }
}
