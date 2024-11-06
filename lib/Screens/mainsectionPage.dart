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
import 'package:makfy_new/Widget/serviceProviderWidget.dart';

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
  List<Widget> serviceProviders = [];
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
                count: 0,
              );
            }).toList() ??
            [];
        serviceProviders = category.service_providers?.map((service_provider) {
              return serviceProviderWidget(
                  title: service_provider.name, id: service_provider.id);
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
          // H1text(text: "قريباً"),
          SizedBox(
            height: 20,
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              // ...serviceProviders,
              // ...services,
            ],
          )
        ],
      ),
    );
  }
}
