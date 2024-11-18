import 'package:flutter/material.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';

class myDuesPage extends StatefulWidget {
  myDuesPage({Key? key}) : super(key: key);

  @override
  State<myDuesPage> createState() => _myDuesPageState();
}

class _myDuesPageState extends State<myDuesPage> {
  bool isLoading = true;
  String? dues;

  @override
  void initState() {
    super.initState();
    _fetchDues();
  }

  Future<void> _fetchDues() async {
    try {
      final fetchedDues = await ApiConfig.getUserDues();
      setState(() {
        dues = fetchedDues;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching dues: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScreenWidget(
      isLoading: isLoading,
      start: Center(
        child: dues != null
            ? Text(
                "مستحقاتك لدى مكفي: $dues ريال",
                maxLines: 10,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )
            : Text(
                "لا يوجد مستحقات حالياً.",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
