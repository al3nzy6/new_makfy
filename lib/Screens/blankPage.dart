import 'package:flutter/material.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';

import 'package:makfy_new/Widget/appHeadWidget.dart';

class Blankpage extends StatefulWidget {
  Widget page;
  Blankpage({
    Key? key,
    required this.page,
  }) : super(key: key);

  @override
  State<Blankpage> createState() => _BlankpageState();
}

class _BlankpageState extends State<Blankpage> {
  late int id;
  late String name;
  late bool isLoading = false;
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
  }

  Widget build(BuildContext context) {
    return MainScreenWidget(isLoading: isLoading, start: Text('${name}'));
  }
}
