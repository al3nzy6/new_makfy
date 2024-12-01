import 'package:flutter/material.dart';
import 'package:makfy_new/Models/Category.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';
import 'package:makfy_new/Widget/FieldWidget.dart';
import 'package:makfy_new/Widget/H1textWidget.dart';
import 'package:makfy_new/Widget/H2Text.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';

class createServicePage extends StatefulWidget {
  createServicePage({Key? key}) : super(key: key);

  @override
  State<createServicePage> createState() => _createServicePageState();
}

class _createServicePageState extends State<createServicePage> {
  late int id;
  late String name;
  int? serviceId; // لمعرفة ما إذا كنا في وضع التعديل
  bool isLoading = true;
  List<Widget> fieldsWidget = [];
  Map<String, dynamic> fieldResults = {};
  final ApiConfig apiConfig = ApiConfig();
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? serviceData; // تخزين بيانات الخدمة عند التعديل
  bool ButtonIsPressed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is List && arguments.length >= 2) {
      id = arguments[0];
      name = arguments[1];
      serviceId = arguments.length > 2 ? arguments[2] : null;
      if (serviceId != null) {
        _getServiceData(serviceId!); // في حال التعديل
      } else {
        _getTheCategory(); // في حال الإضافة
      }
    }
  }

  Future<void> _submitFunction(data) async {
    try {
      setState(() {
        ButtonIsPressed = true;
      });
      List response;
      if (serviceId != null) {
        response = await apiConfig.updateService(data, serviceId!);
      } else {
        response = await apiConfig.createService(data);
      }

      if (response[0] != null) {
        Navigator.pushReplacementNamed(
          context,
          '/service_page',
          arguments: [response[0], null, null],
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('يوجد خلل: ${response[1]}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
    // Future.delayed(Duration(seconds: 10), () {
    setState(() {
      ButtonIsPressed = false;
    });
    // });
  }

  Future<void> _getServiceData(int serviceId) async {
    try {
      final fetchedServiceData = await ApiConfig.getService(serviceId);
      if (!mounted) return; // تأكد من أن الواجهة لا تزال نشطة
      setState(() {
        serviceData = {
          'title': fetchedServiceData.title,
          'price': fetchedServiceData.priceWithOutCommission,
          'description': fetchedServiceData.description,
        };
        // تخزين القيم الافتراضية في fieldResults
        fieldResults['title'] = serviceData?['title'] ?? '';
        fieldResults['price'] = serviceData?['price'] ?? '';
        fieldResults['description'] = serviceData?['description'] ?? '';
        fieldsWidget = fetchedServiceData.customFields?.map((field) {
              final options =
                  field.options?.map((option) => option.toJson()).toList() ??
                      [];
              return FieldWidget(
                id: field.id,
                name: field.name,
                showName: field.showName,
                type: field.type,
                required: (field.type != 'File') ? field.required : null,
                initialValue:
                    (field.insertedValue != null && field.type == 'Select')
                        ? field.insertedValue
                        : field.value, // تعيين القيمة الأولية
                onChanged: (fieldValue) {
                  fieldResults[field.name] = fieldValue;
                },
                options: options,
              );
            }).toList() ??
            [];
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل بيانات الخدمة: $e')),
      );
    }
  }

  Future<void> _getTheCategory() async {
    Category category = await ApiConfig.getCategory(id, null, null);
    try {
      if (!mounted) return; // تأكد من أن الواجهة لا تزال نشطة
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تحميل البيانات: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScreenWidget(
      onRefresh: serviceId != null
          ? () => _getServiceData(serviceId!)
          : _getTheCategory,
      isLoading: isLoading,
      start: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            H1text(text: serviceId != null ? 'تعديل الخدمة' : 'إنشاء الخدمة'),
            SizedBox(height: 10),
            H2Text(
              lines: 10,
              textColor: Colors.red,
              text:
                  "عزيزي مقدم الخدمه ان لم يكن التوصيل مجانا من قبلكم .. رجاءً اضف قيمة سعر التوصيل لديكم كصنف من اصناف الخدمه المقدمه من قبلكم ليتم دفعها من قبل العميل ويجب ان تكون اول خدمه تقوم باضافتها",
            ),
            SizedBox(height: 20),
            FieldWidget(
              id: 2,
              name: "title",
              showName: "اسم الخدمة:",
              type: "String",
              required: true,
              initialValue: serviceData?['title'], // عرض الاسم عند التعديل
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
              initialValue: serviceData?['price'], // عرض السعر عند التعديل
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
              initialValue:
                  serviceData?['description'], // عرض الوصف عند التعديل
              onChanged: (value) {
                fieldResults['description'] = value;
              },
            ),
            ...fieldsWidget,
            InkWell(
              onTap: (ButtonIsPressed == false)
                  ? () {
                      if (_formKey.currentState!.validate()) {
                        fieldResults['service_category_id'] = id;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(serviceId != null
                                  ? 'جاري تحديث الخدمة'
                                  : 'جاري إنشاء الخدمة')),
                        );
                        _submitFunction(fieldResults);
                      }
                    }
                  : null,
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
                    child: (!ButtonIsPressed)
                        ? H2Text(
                            text: serviceId != null
                                ? "تعديل الخدمة"
                                : "تفعيل الخدمة",
                            aligment: "center",
                            textColor: Colors.white,
                            size: 25,
                          )
                        : H2Text(
                            text: serviceId != null
                                ? "جاري تعديل الخدمة .. الرجاء الانتظار"
                                : "جاري تفعيل الخدمة .. الرجاء الانتظار",
                            aligment: "center",
                            textColor: const Color.fromARGB(255, 214, 213, 213),
                            size: 20,
                          )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
