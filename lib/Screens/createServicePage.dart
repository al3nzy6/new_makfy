import 'package:flutter/material.dart';
import 'package:makfy_new/Models/Category.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';
import 'package:makfy_new/Widget/FieldWidget.dart';
import 'package:makfy_new/Widget/H1textWidget.dart';
import 'package:makfy_new/Widget/H2Text.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';

import 'package:makfy_new/Widget/appHeadWidget.dart';

class createServicePage extends StatefulWidget {
  createServicePage({
    Key? key,
  }) : super(key: key);

  @override
  State<createServicePage> createState() => _createServicePageState();
}

class _createServicePageState extends State<createServicePage> {
  late int id;
  late String name;
  late bool isLoading = true;
  List<Widget> fieldsWidget = [];
  Map<String, dynamic> fieldResults = {};
  final ApiConfig apiConfig = ApiConfig();
  final _formKey = GlobalKey<FormState>();

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

  Future<void> _createFunction(data) async {
    try {
      final createResponse = await apiConfig.createService(data);
      if (createResponse != null && createResponse[0] != null) {
        if (!mounted) return;
        // Step 2: Navigate to `/service_page` with the newly created service ID and other details
        Navigator.pushReplacementNamed(
          context,
          '/service_page',
          arguments: [
            createResponse[0],
            null,
            null
          ], // Arguments for `/service_page`
        );
      } else {
        // Service creation failed, show a SnackBar with the error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('يوجد خلل لم يتم إنشاء الخدمة : ${createResponse[1]}'),
          ),
        );
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> _getTheCategory() async {
    Category category = await ApiConfig.getCategory(id);
    try {
      setState(() {
        fieldsWidget = category.Fields?.map((field) {
              final options =
                  field.options?.map((option) => option.toJson()).toList() ??
                      [];
              return FieldWidget(
                id: field.id,
                name: field.name,
                showName: "${field.showName}:",
                type: field.type,
                required: field.required,
                onChanged: (value) {
                  fieldResults[field.name] = value;
                },
                options: options,
              );
            }).toList() ??
            [];
        isLoading = false;
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Widget build(BuildContext context) {
    return MainScreenWidget(
        onRefresh: _getTheCategory,
        isLoading: isLoading,
        start: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              H1text(text: name),
              SizedBox(
                height: 10,
              ),
              H2Text(
                lines: 3,
                text:
                    "الرجاء التأكد من اختيار القسم المناسب للوصول لعملائك بشكل صحيح, بامكانك العودة واختيار القسم المناسب",
              ),
              SizedBox(
                height: 20,
              ),
              FieldWidget(
                id: 2,
                name: "title",
                showName: "العنوان:",
                type: "String",
                required: true,
                onChanged: (value) {
                  fieldResults['title'] = value;
                },
              ),
              FieldWidget(
                id: 2,
                name: "price",
                showName: "السعر:",
                type: "String",
                required: true,
                onChanged: (value) {
                  fieldResults['price'] = value;
                },
              ),
              FieldWidget(
                id: 2,
                name: "description",
                showName: "وصف مختصر للخدمة:",
                type: "String",
                required: true,
                onChanged: (value) {
                  fieldResults['description'] = value;
                },
              ),
              ...fieldsWidget,
              InkWell(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    fieldResults['service_category_id'] = id;
                    print(fieldResults);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('جاري إنشاء الخدمة')),
                    );
                    _createFunction(fieldResults);
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0XFFEF5B2C),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: 50,
                    width: double.infinity,
                    child: Icon(
                      Icons.add_circle_sharp,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
