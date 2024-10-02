import 'package:flutter/material.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';

import 'package:makfy_new/Widget/appHeadWidget.dart';

class CustomerOrdersPage extends StatefulWidget {
  CustomerOrdersPage({Key? key});

  @override
  State<CustomerOrdersPage> createState() => _CustomerOrdersPageState();
}

class _CustomerOrdersPageState extends State<CustomerOrdersPage> {
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
        isLoading: isLoading, start: Text("Customer Order Page"));
  }
}
