import 'package:flutter/material.dart';
import 'package:makfy_new/Widget/H1textWidget.dart';
import 'package:makfy_new/Widget/H2Text.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';
import 'package:makfy_new/Widget/appHeadWidget.dart';
import 'package:makfy_new/Widget/myorderService.dart';
import 'package:makfy_new/Widget/shimmerLoadingWidget.dart';

class Myorderspage extends StatefulWidget {
  Myorderspage({super.key});

  @override
  State<Myorderspage> createState() => _MyorderspageState();
}

class _MyorderspageState extends State<Myorderspage> {
  late int id;
  late String name;
  bool isLoading = false;
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
    isLoading = false;
  }

  Widget build(BuildContext context) {
    return MainScreenWidget(
        isLoading: isLoading,
        start: Container(
          // padding: EdgeInsets.all(10),
          child: Column(
            children: [
              H1text(text: 'طلباتي'),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.blue,
                    ),
                    child: H2Text(
                      text: "جديد",
                      textColor: Colors.white,
                      size: 20,
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.green,
                    ),
                    child: H2Text(
                      text: "قيد التنفيذ",
                      textColor: Colors.white,
                      size: 20,
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.red,
                    ),
                    child: H2Text(
                      text: "منتهية",
                      textColor: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Myorderservice(
                  title: "تجربة",
                  serviceProvider: "حمدان",
                  date: "2024-01-01",
                  time: "04:00pm",
                  type: 2,
                  price: 203.00,
                  order_number: 332,
                  fields: ['okkk'],
                  id: 30),
              SizedBox(
                height: 15,
              ),
              Myorderservice(
                  title: "تجربة",
                  serviceProvider: "حمدان",
                  date: "2024-01-01",
                  time: "04:00pm",
                  type: 1,
                  fields: ['okk'],
                  price: 203.00,
                  order_number: 332,
                  id: 30),
              SizedBox(
                height: 15,
              ),
              Myorderservice(
                  title: "تجربة",
                  serviceProvider: "حمدان",
                  date: "2024-01-01",
                  time: "04:00pm",
                  type: 2,
                  fields: ['okk'],
                  price: 203.00,
                  order_number: 332,
                  id: 30),
              SizedBox(
                height: 15,
              ),
              Myorderservice(
                  title: "تجربة",
                  serviceProvider: "حمدان",
                  date: "2024-01-01",
                  time: "04:00pm",
                  type: 3,
                  fields: ['okk'],
                  price: 203.00,
                  order_number: 332,
                  id: 30),
              SizedBox(
                height: 30,
              ),
            ],
          ),
        ));
  }
}

void _showDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('This is a Dialog'),
        content: Container(
          height: 200,
          width: 300,
          // decoration: BoxDecoration(color: Colors.black),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // إغلاق الـ dialog
            },
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              _showDialog(context); // عرض الـ dialog عند الضغط على الزر
              // Navigator.pushNamed(context, '/'); // إغلاق الـ dialog
            },
            child: Text('Remove'),
          ),
        ],
      );
    },
  );
}
