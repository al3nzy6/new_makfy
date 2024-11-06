import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:makfy_new/Models/Cart.dart';
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
  late Cart? cart;
  late String? date;
  late String? time;
  List<Widget> services = [];
  Map<int, dynamic> finalresults = {};
  User? user;
  int? current_user;
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // استلام البيانات الممررة من خلال ModalRoute
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map<String, dynamic>) {
      // التعامل مع `arguments` كـ `Map`
      id = arguments["id"];
      name = arguments["title"];
      cart = arguments["cart"];
      date = arguments["date"];
      time = arguments["time"];

      // استخدام البيانات المستخرجة حسب الحاجة
    } else if (arguments is List) {
      // التعامل مع `arguments` كـ `List`
      id = arguments[0];
      name = arguments[1];
      cart = null;
      date = null;
      time = null;
    }
    _getUserServices();
  }

  Future<void> _getUserServices() async {
    user = await ApiConfig.getUserProfile(id);
    current_user = await ApiConfig.getUserId();
    try {
      if (!mounted) return; // تأكد من أن الـ widget ما زالت موجودة
      setState(() {
        finalresults[0] = id;
        services = (cart != null)
            ? cart?.services?.map((service) {
                  finalresults[service.id] = service.quantity;
                  return ServiceAddedWidget(
                    title: service.title,
                    fields: service.insertedValues?.split(','),
                    serviceProvider: service.user.name,
                    price: service.price,
                    id: service.id,
                    currentUserIsTheProvider:
                        (user?.id == current_user) ? true : false,
                    onChanged: (value) {
                      finalresults[service.id] = value;
                    },
                    count: (finalresults.containsKey(service.id))
                        ? finalresults[service.id]
                        : 0,
                  );
                }).toList() ??
                []
            : user?.services?.map((service) {
                  return ServiceAddedWidget(
                    title: service.title,
                    fields: service.insertedValues?.split(','),
                    serviceProvider: service.user.name,
                    price: service.price,
                    id: service.id,
                    currentUserIsTheProvider:
                        (user?.id == current_user) ? true : false,
                    onChanged: (value) {
                      finalresults[service.id] = value;
                    },
                    count: (finalresults.containsKey(service.id))
                        ? finalresults[service.id]
                        : 0,
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
              RatingWidget(
                stars: user?.averageRating ?? 0,
                ratingCount: "${user?.countRating ?? 0}",
                userId: user?.id ?? 0,
              ),
            ],
          ),
          H2Text(text: "${services.length} خدمة"),
          SizedBox(
            height: 40,
          ),
          Wrap(spacing: 10, runSpacing: 10, children: [
            ...services,
            if (current_user != user?.id) ...[
              InkWell(
                onTap: () => _saveAndPayCart(true),
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 240, 190, 174),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 70,
                      width: double.infinity,
                      child: H2Text(
                        text: "حفظ بالسلة",
                        aligment: 'center',
                        size: 25,
                        textColor: Colors.black,
                      )),
                ),
              ),
              InkWell(
                onTap: () => _saveAndPayCart(false),
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Color(0XFFEF5B2C),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 70,
                      width: double.infinity,
                      child: H2Text(
                        text: "المتابعة للدفع",
                        aligment: 'center',
                        size: 25,
                        textColor: Colors.white,
                      )),
                ),
              ),
            ],
          ]),
        ],
      ),
    );
  }

  Future<void> _saveAndPayCart(bool? OnlySaveAsCart) async {
    // print(finalresults);
    Map<String, dynamic> result =
        await ApiConfig.updateCart(finalresults, cart);
    try {
      print(result['data']['total']);
      if (OnlySaveAsCart == false) {
        Navigator.pushNamed(context, '/payment_page', arguments: [
          result['data']['id'],
          double.tryParse(result['data']['total']) ?? 0.0
        ]);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "تم حفظه بالسلة",
              style: const TextStyle(fontSize: 20),
            ),
          ),
        );
      }
    } catch (e) {}
  }
}
