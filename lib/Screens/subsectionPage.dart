import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:makfy_new/Models/Category.dart';
import 'package:makfy_new/Models/Option.dart';
import 'package:makfy_new/Models/Service.dart';
import 'package:makfy_new/Models/fieldSection.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';
import 'package:makfy_new/Widget/FieldWidget.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';
import 'package:makfy_new/Widget/serviceProviderWidget.dart';
import 'package:makfy_new/Widget/shimmerLoadingWidget.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:makfy_new/Widget/H1textWidget.dart';
import 'package:makfy_new/Widget/H2Text.dart';
import 'package:makfy_new/Widget/ServiceAddedWidget.dart';
import 'package:makfy_new/Widget/appHeadWidget.dart';
import 'package:makfy_new/Widget/boxWidget.dart';

class Subsectionpage extends StatefulWidget {
  Subsectionpage({super.key});

  @override
  State<Subsectionpage> createState() => _SubsectionpageState();
}

class _SubsectionpageState extends State<Subsectionpage> {
  late int id;
  late String name;
  late String selectedDate;
  late String selectedTime;
  late List Choices;
  String? date;
  String? time;
  List<Widget> services = [];
  List<Widget> serviceProviders = [];
  bool isLoading = true;
  List<fieldSection>? fields = [];
  List<Widget> fieldsWidget = [];
  // القائمة الخاصة بالعناصر
  Map<String, dynamic> fieldResults = {};

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

  Future<void> _getTheCategory() async {
    Category category = await ApiConfig.getCategory(id);
    try {
      setState(() {
        fieldsWidget = category.Fields?.where((field) =>
                    field.type != 'File') // تصفية الحقول التي نوعها ليس 'File'
                .map((field) {
              final options =
                  field.options?.map((option) => option.toJson()).toList() ??
                      [];
              return FieldWidget(
                id: field.id,
                name: field.name,
                showName: field.showName,
                type: field.type,
                onChanged: (value) {
                  fieldResults[field.name] = value;
                },
                options: options,
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
                date: date ?? null,
                time: time ?? null,
              );
            }).toList() ??
            [];
        serviceProviders = category.service_providers?.map((service_provider) {
              return serviceProviderWidget(
                title: service_provider.name,
                id: service_provider.id,
                averageRating: service_provider.averageRating,
                countRating: service_provider.countRating,
              );
            }).toList() ??
            [];
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Widget _floatingButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.pushNamed(context, '/create_service', arguments: [id, name]);
      },
      label: Icon(
        Icons.add,
        size: 50,
        color: Colors.white,
      ),
      backgroundColor: Colors.orange[900],
    );
  }

  Widget build(BuildContext context) {
    return MainScreenWidget(
      isLoading: isLoading,
      onRefresh: _getTheCategory,
      floatingFunction: _floatingButton(),
      start: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          H1text(text: name),
          SizedBox(
            height: 20,
          ),
          Divider(
            color: Color(0XFFEF5B2C).withOpacity(0.3),
          ),
          SizedBox(
            height: 10,
          ),
          ExpansionTile(
            title: H1text(text: 'تصفية مقدمي الخدمات'),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide.none, // إزالة الخط عند إغلاق العنصر
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide.none, // إزالة الخط عند فتح العنصر
            ),
            children: [
              ...fieldsWidget,
              FieldWidget(
                id: 30,
                name: 'date',
                showName: 'اختر التاريخ',
                type: 'Date',
                onChanged: (value) {
                  date = value;
                },
              ),
              FieldWidget(
                id: 30,
                name: 'date',
                showName: 'اختر التاريخ',
                type: 'Time',
                onChanged: (value) {
                  time = value;
                },
              ),
              InkWell(
                onTap: () {
                  fieldResults['category_id'] = id;
                  print(fieldResults);
                },
                child: Container(
                  alignment: Alignment.topRight,
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0XFFEF5B2C),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: 50,
                    width: 70,
                    child: Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          H1text(text: "مقدمي الخدمات"),
          SizedBox(
            height: 20,
          ),
          Wrap(spacing: 10, runSpacing: 10, children: [
            ...serviceProviders,
            // ...services,
          ]),
        ],
      ),
    );
  }
}
