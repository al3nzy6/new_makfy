import 'package:flutter/material.dart';
import 'package:makfy_new/Models/Category.dart';
import 'package:makfy_new/Models/Service.dart';
import 'package:makfy_new/Models/SubCategory.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';
import 'package:makfy_new/Widget/H1textWidget.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';
import 'package:makfy_new/Widget/ServiceAddedWidget.dart';
import 'package:makfy_new/Widget/appHeadWidget.dart';
import 'package:makfy_new/Widget/boxWidget.dart';

class Mainsectionpage extends StatefulWidget {
  Mainsectionpage({super.key});

  @override
  State<Mainsectionpage> createState() => _MainsectionpageState();
}

class _MainsectionpageState extends State<Mainsectionpage> {
  late int id;
  late String name;
  bool isLoading = true;
  List<SubCategory> categories = [];
  List<Widget> categoryWidgets = [];
  List<Widget> services = [];

  Future<void> _getTheCategory() async {
    try {
      Category category = await ApiConfig.getCategory(id.toInt());
      setState(() {
        categoryWidgets = category.categories?.map((subcat) {
              return boxWidget(
                title: subcat.name,
                route: '/sub_section',
                data: [subcat.id, subcat.name],
              );
            }).toList() ??
            [];
        services = category.services?.map((service) {
              return ServiceAddedWidget(
                title: service.title,
                fields: service.insertedValues?.split(','),
                serviceProvider: service.user.name,
                price: service.price,
                id: service.id,
              );
            }).toList() ??
            [];
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // استلام البيانات الممررة من خلال ModalRoute
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is int) {
      id = arguments; // تعيين الـ id
    }
    if (arguments is List) {
      id = arguments[0];
      name = arguments[1];
    }
    _getTheCategory();
  }

  Widget build(BuildContext context) {
    return MainScreenWidget(
      onRefresh: _getTheCategory,
      isLoading: isLoading,
      start: Column(
        children: [
          H1text(text: name),
          SizedBox(
            height: 20,
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: categoryWidgets,
          ),
          SizedBox(
            height: 40,
          ),
          H1text(text: "احدث الخدمات"),
          SizedBox(
            height: 20,
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ...services,
            ],
          )
        ],
      ),
    );
  }
}

Widget _latestServiceAdded() {
  return Column(
    mainAxisSize: MainAxisSize.max,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      ServiceAddedWidget(
          title: "title",
          fields: ['ملح فقط', 'بهارات'],
          serviceProvider: "حلبي",
          price: '300.50',
          id: 12),
      SizedBox(height: 15),
      ServiceAddedWidget(
          title: "ذبيحه كاملة مقطعه انصاص وانصاص",
          fields: ['ملح فقط', 'بهارات'],
          serviceProvider: "حلبي",
          price: '300.50',
          id: 12),
      SizedBox(height: 15),
      ServiceAddedWidget(
          title: "title",
          fields: ['ملح فقط', 'بهارات'],
          serviceProvider: "حلبي",
          price: '300.50',
          id: 12),
      SizedBox(height: 15),
      ServiceAddedWidget(
          title: "title",
          fields: ['ملح فقط', 'بهارات'],
          serviceProvider: "حلبي",
          price: '300.50',
          id: 12),
      SizedBox(height: 15),
    ],
  );
}
