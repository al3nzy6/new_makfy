import 'package:flutter/material.dart';
import 'package:makfy_new/Models/Category.dart';
import 'package:makfy_new/Models/Service.dart';
import 'package:makfy_new/Models/User.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';
import 'package:makfy_new/Widget/H1textWidget.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';
import 'package:makfy_new/Widget/ServiceAddedWidget.dart';
import 'package:makfy_new/Widget/appHeadWidget.dart';
import 'package:makfy_new/Widget/boxWidget.dart';
import 'package:makfy_new/Widget/fontIcon.dart';
import 'package:makfy_new/Widget/serviceProviderWidget.dart';
import 'package:makfy_new/Widget/shimmerLoadingWidget.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;
  List<Category> categories = [];
  List<Widget> categoryWidgets = [];
  List<Widget> services = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    _fetchCateogry();
    _fetchServices();
  }

  Future<void> _fetchCateogry() async {
    try {
      List<Category> listCategories = await ApiConfig.getCategories();
      setState(() {
        categories = listCategories;
        categoryWidgets = categories.map((category) {
              return boxWidget(
                title: category.name,
                route: "/main_section",
                data: [category.id, category.name],
              );
            }).toList() ??
            [];
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _fetchServices() async {
    try {
      List<User> listServices = await ApiConfig.initServices();
      setState(() {
        services = listServices.map((service) {
              return serviceProviderWidget(title: service.name, id: service.id);
            }).toList() ??
            [];
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScreenWidget(
      onRefresh: _fetchAllData,
      start: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          H1text(text: 'الاقسام'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: categoryWidgets,
          ),
        ],
      ),
      isLoading: isLoading,
    );
  }

  Widget _section({String? image, required String title}) {
    return Container(
      height: 157,
      width: 149,
      decoration: BoxDecoration(border: Border.all()),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image ?? 'images/logo.png', // Ensure default image exists in assets
            height: 100,
          ),
          Text(title),
        ],
      ),
    );
  }

  List<Widget> _sections() {
    return [
      boxWidget(
        title: 'sdf',
        route: '/main_section',
        image: 'images/bg.png',
        data: [23, 'sdf'],
      ),
      boxWidget(
        title: 'kkk',
        route: '/profile',
        icon: Icons.ac_unit_rounded,
      ),
      boxWidget(
        title: 'عربي',
        route: '/',
        icon: Icons.ac_unit_rounded,
      ),
      boxWidget(
        title: 'عربي',
        route: '/',
        icon: Icons.ac_unit_rounded,
      ),
      boxWidget(
        title: 'عربي',
        route: '/',
        icon: Icons.ac_unit_rounded,
      ),
      boxWidget(
        title: 'عربي',
        route: '/',
        icon: Icons.ac_unit_rounded,
      ),
      boxWidget(title: 'iiii', route: '/'),
    ];
  }
}
