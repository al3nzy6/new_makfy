import 'package:fan_carousel_image_slider/fan_carousel_image_slider.dart';
import 'package:flutter/material.dart';
import 'package:makfy_new/Models/Option.dart';
import 'package:makfy_new/Models/Service.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';
import 'package:makfy_new/Widget/H1textWidget.dart';
import 'package:makfy_new/Widget/H2Text.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';
import 'package:makfy_new/Widget/RatingWidget.dart';

class ServicePage extends StatefulWidget {
  ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  late int id;
  String? date;
  String? time;
  Service? serviceData;
  bool isLoading = true;
  int? user_id;
  List<Map<String, dynamic>> optionsList = [
    Option(id: 1, name: "دقيقة").toJson(),
    Option(id: 2, name: "ساعة").toJson(),
    Option(id: 3, name: "يوم").toJson(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is List) {
      id = arguments[0];
      date = arguments[1] ??
          "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
      time = arguments[2] ?? TimeOfDay.now().toString();
    }
    _getService();
  }

  Future _getService() async {
    try {
      Service service = await ApiConfig.getService(id);
      int? user_idFromApi = await ApiConfig.getUserId();
      if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    return MainScreenWidget(
      isLoading: isLoading,
      routeArguments: [serviceData?.category?.id, serviceData?.category?.name],
      onRefresh: _getService,
      start: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        H1text(text: serviceData?.category?.name ?? 'error'),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: H1text(
                text: serviceData?.title ?? 'يوجد خلل',
              ),
            ),
            H1text(
              text: "${serviceData?.price} SR" ?? 'يوجد خلل',
            ),
          ],
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => Navigator.pushNamed(context, '/user_page',
              arguments: [serviceData?.user.id, serviceData?.user.name]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              H2Text(text: serviceData?.user.name ?? 'non'),
              RatingWidget(
                stars: serviceData?.user.averageRating ?? 0,
                ratingCount: "${serviceData?.user.countRating ?? 0}",
                userId: serviceData?.user.id ?? 0,
              ),
            ],
          ),
        ),
        if (serviceData?.imageUrls != null &&
            serviceData!.imageUrls!.isNotEmpty)
          FanCarouselImageSlider.sliderType2(
            imagesLink: serviceData?.imageUrls ?? [],
            initalPageIndex: serviceData!.imageUrls!.isNotEmpty ? 0 : 1,
            isAssets: false,
            autoPlay: true,
            expandedImageFitMode: BoxFit.contain,
            expandImageHeight: 400,
            sliderHeight: 300,
            currentItemShadow: [],
            sliderDuration: const Duration(milliseconds: 200),
            imageRadius: 0,
            slideViewportFraction: 2,
          )
        else
          const SizedBox(height: 10),
        H2Text(
          lines: 10,
          text: serviceData?.description ?? 'non',
          textColor: Colors.grey,
          size: 25,
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(10),
          ),
          child: H2Text(
            text: 'تفاصيل الخدمة',
            size: 22,
          ),
        ),
        const SizedBox(height: 20),
        if (serviceData?.customFields != null &&
            serviceData!.customFields!.isNotEmpty)
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: serviceData!.customFields!.map((field) {
              return Column(
                children: (field?.type != 'File')
                    ? [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        const Divider(),
                      ]
                    : [],
              );
            }).toList(),
          )
        else
          // Container(child: Text('لا يوجد خيارات')),
          const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: H1text(
                text: 'مدة التنفيذ',
              ),
            ),
            H1text(
              text:
                  "${serviceData?.time_to_beready_value} ${optionsList.firstWhere((option) => option["id"] == serviceData?.time_to_beready_type, orElse: () => {
                        "name": "غير محدد"
                      })["name"]}",
            ),
          ],
        ),
        const SizedBox(height: 50),
        if (user_id != null && user_id == serviceData?.user.id)
          Center(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/create_service',
                      arguments: [
                        serviceData?.category?.id,
                        serviceData?.category?.name,
                        serviceData?.id
                      ],
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text(
                    "تعديل الخدمة",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
      ]),
    );
  }
}
