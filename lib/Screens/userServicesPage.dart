import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:makfy_new/Models/Category.dart';
import 'package:makfy_new/Models/Option.dart';
import 'package:makfy_new/Models/Service.dart';
import 'package:makfy_new/Models/User.dart';
import 'package:makfy_new/Models/fieldSection.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';
import 'package:makfy_new/Widget/FieldWidget.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';
import 'package:makfy_new/Widget/RatingWidget.dart';
import 'package:makfy_new/Widget/shimmerLoadingWidget.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:makfy_new/Widget/H1textWidget.dart';
import 'package:makfy_new/Widget/H2Text.dart';
import 'package:makfy_new/Widget/ServiceAddedWidget.dart';
import 'package:makfy_new/Widget/appHeadWidget.dart';
import 'package:makfy_new/Widget/boxWidget.dart';

class userServicesPage extends StatefulWidget {
  userServicesPage({super.key});

  @override
  State<userServicesPage> createState() => _userServicesPageState();
}

class _userServicesPageState extends State<userServicesPage> {
  late int id;
  late String name;
  List<Widget> services = [];
  bool isLoading = true;

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
    _getUserServices();
  }

  Future<void> _getUserServices() async {
    User user = await ApiConfig.getUserProfile(id);
    try {
      if (!mounted) return; // تأكد من أن الـ widget ما زالت موجودة
      setState(() {
        services = user.services?.map((service) {
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

  Widget build(BuildContext context) {
    return MainScreenWidget(
      isLoading: isLoading,
      onRefresh: _getUserServices,
      start: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              H1text(text: name),
              RatingWidget(stars: 3, ratingCount: "3K"),
            ],
          ),
          H2Text(text: "${services.length} خدمة"),
          SizedBox(
            height: 40,
          ),
          Wrap(spacing: 10, runSpacing: 10, children: [
            ...services,
          ]),
        ],
      ),
    );
  }
}
