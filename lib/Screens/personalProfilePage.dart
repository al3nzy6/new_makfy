import 'package:flutter/material.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';

import 'package:makfy_new/Widget/appHeadWidget.dart';

class PersonalProfilePage extends StatefulWidget {
  PersonalProfilePage({Key? key});

  @override
  State<PersonalProfilePage> createState() => _PersonalProfilePageState();
}

class _PersonalProfilePageState extends State<PersonalProfilePage> {
  late int id;
  late String name;
  bool isLoading = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // استلام البيانات الممررة من خلال ModalRoute
    final arguments = ModalRoute.of(context)?.settings.arguments;
    isLoading = false;
  }

  Widget build(BuildContext context) {
    return MainScreenWidget(
        isLoading: isLoading, start: Text("Persoanl Profile Page"));
  }
}
