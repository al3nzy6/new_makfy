import 'package:fan_carousel_image_slider/fan_carousel_image_slider.dart';
import 'package:flutter/material.dart';
import 'package:makfy_new/Models/Service.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';
import 'package:makfy_new/Widget/FieldWidget.dart';
import 'package:makfy_new/Widget/H1textWidget.dart';
import 'package:makfy_new/Widget/H2Text.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';
import 'package:makfy_new/Widget/RatingWidget.dart';
import 'package:makfy_new/Widget/appHeadWidget.dart';

class ServicePage extends StatefulWidget {
  ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  late int id;
  String? date;
  String? time;
  int numbers = 0;
  Service? serviceData;
  bool isLoading = true;
  int? user_id;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // استلام البيانات الممررة من خلال ModalRoute
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is List) {
      id = arguments[0]; // تعيين الـ id
      date = arguments[1] ??
          "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
      time = arguments[2] ?? TimeOfDay.now().toString(); // تعيين الـ id
    }
    _getService();
  }

  Future _getService() async {
    Service service = await ApiConfig.getService(id);
    int? user_idFromApi = await ApiConfig.getUserId();
    try {
      if (!mounted) return; // تأكد من أن الـ widget ما زالت موجودة
      setState(() {
        serviceData = service;
        isLoading = false;
        user_id = user_idFromApi;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      throw Exception(e);
    }
  }

  Widget build(BuildContext context) {
    return MainScreenWidget(
      isLoading: isLoading,
      routeArguments: [serviceData?.category?.id, serviceData?.category?.name],
      onRefresh: _getService,
      start: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              H1text(text: serviceData?.category?.name ?? 'error'),
              Flexible(
                child: H1text(
                  text: serviceData?.title ?? 'يوجد خلل',
                ),
              ),
              H1text(
                text: serviceData?.price ?? 'يوجد خلل',
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () => Navigator.pushNamed(context, '/user_page',
                arguments: [serviceData?.user.id, serviceData?.user.name]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                H2Text(text: serviceData?.user.name ?? 'non'),
                RatingWidget(stars: 4, ratingCount: '3'),
              ],
            ),
          ),
          (serviceData?.imageUrls != null && serviceData!.imageUrls!.isNotEmpty)
              ? FanCarouselImageSlider.sliderType2(
                  imagesLink: serviceData?.imageUrls ?? [],
                  initalPageIndex: (serviceData?.imageUrls != null &&
                          serviceData!.imageUrls!.isNotEmpty)
                      ? 0
                      : 1,
                  isAssets: false,
                  autoPlay: true,
                  sliderHeight: 300,
                  currentItemShadow: [],
                  sliderDuration: const Duration(milliseconds: 200),
                  imageRadius: 0,
                  slideViewportFraction: 1.2,
                )
              : SizedBox(
                  height: 10,
                ),
          H2Text(
            text: serviceData?.description ?? 'non',
            textColor: Colors.grey,
            size: 25,
          ),
          SizedBox(
            height: 50,
          ),
          H2Text(
            text: 'تفاصيل الخدمة',
            size: 22,
          ),
          H2Text(
            text: 'الرجاء اختيار الوقت والتاريخ للتحقق من توفر الخدمه',
            size: 19,
            lines: 2,
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              H2Text(
                text: 'نسبة التوفر  للاسبوع ',
                // size: 22,
              ),
              H2Text(
                text: '10%',
                // size: 19,
                lines: 1,
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          FieldWidget(id: 11, name: "date", showName: "التاريخ", type: 'Date'),
          Divider(),
          FieldWidget(id: 11, name: "time", showName: "الوقت", type: 'Time'),
          Divider(),
          (serviceData != null &&
                  serviceData!.customFields != null &&
                  serviceData!.customFields!.isNotEmpty)
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: serviceData!.customFields!.map((field) {
                    return Column(
                      children: (field?.type != 'File')
                          ? [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  H2Text(
                                    text: field.showName ?? "error",
                                    size: 22,
                                  ),
                                  H2Text(
                                    text: field.value ?? "error",
                                    size: 22,
                                  ),
                                ],
                              ),
                              Divider(),
                            ]
                          : [],
                    );
                  }).toList(),
                )
              : Container(child: Text('لا يوجد خيارات')),
          SizedBox(
            height: 60,
          ),
          (serviceData?.user.id != user_id)
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: () => _increaseNumbers(),
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                            color: Color(0XFFEF5B2C), shape: BoxShape.circle),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                    H2Text(
                      text: "${numbers}",
                      size: 30,
                    ),
                    InkWell(
                      onTap: () => _decreaseNumbers(),
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                            color: Color(0XFFEF5B2C), shape: BoxShape.circle),
                        child: Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                  ],
                )
              : InkWell(
                  onTap: () => print('update'),
                  child: Container(
                    alignment: Alignment.center,
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        color: Color(0XFFEF5B2C),
                        borderRadius: BorderRadius.circular(30)),
                    child: Center(
                        child: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 40,
                    )),
                  ),
                ),
          if (numbers > 0)
            Container(
              margin: EdgeInsets.only(top: 60),
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                  color: Color(0XFFEF5B2C),
                  borderRadius: BorderRadius.circular(30)),
              child: Center(
                  child: H2Text(
                text: 'طلب الخدمة',
                textColor: Colors.white,
                size: 30,
              )),
            )
        ],
      ),
    );
  }

  _increaseNumbers() {
    setState(() {
      numbers = numbers + 1;
    });
  }

  _decreaseNumbers() {
    if (numbers > 0) {
      setState(() {
        numbers = numbers - 1;
      });
    }
  }
}
