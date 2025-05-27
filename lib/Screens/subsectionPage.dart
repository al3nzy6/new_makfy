import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:makfy_new/Models/Category.dart';
import 'package:makfy_new/Models/City.dart';
import 'package:makfy_new/Models/District.dart';
import 'package:makfy_new/Models/fieldSection.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';
import 'package:makfy_new/Widget/FieldWidget.dart';
import 'package:makfy_new/Widget/H2Text.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';
import 'package:makfy_new/Widget/serviceProviderWidget.dart';
import 'package:makfy_new/Widget/H1textWidget.dart';
import 'package:makfy_new/Widget/ServiceAddedWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Subsectionpage extends StatefulWidget {
  Subsectionpage({super.key});

  @override
  State<Subsectionpage> createState() => _SubsectionpageState();
}

class _SubsectionpageState extends State<Subsectionpage> {
  late int id;
  late String name;
  late String selectedDate;
  late String selectedTime;
  late List Choices;
  String? date;
  String? time;
  List<Widget> services = [];
  List<Widget> serviceProviders = [];
  bool isLoading = true;
  List<fieldSection>? fields = [];
  List<Widget> fieldsWidget = [];
  bool _isInitialized = false;
  // List<Map<String, dynamic>>? cities;
  List<Map<String, dynamic>>? districts;
  String? SelectedCity;
  String? SelectedDistrict;
  List<City> cities = [];
  List<City> filteredCities = [];
  District? selectedDistrict;
  City? selectedCity;
  Future<List<District>>? districtsFuture;
  List<District> filteredDistricts = [];
  List<District> userDistricts = [];
  Position? position;
  String? DistrictFromLocation;

  // القائمة الخاصة بالعناصر
  Map<String, dynamic> fieldResults = {};
  bool isServiceProvider = false;

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
    if (_isInitialized == false) {
      _getTheCategory();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  // Future<void> getCities() async {
  //   try {
  //     List<City> citiesFromApi = await ApiConfig.getCities();
  //     setState(() {
  //       cities = citiesFromApi;
  //       filteredCities = citiesFromApi;
  //     });
  //   } catch (e) {
  //     print("Error fetching cities: $e");
  //   }
  // }

  // Future<List<District>> getDistricts(int cityId) async {
  //   try {
  //     City cityFromApi = await ApiConfig.getDistricts(cityId);
  //     return cityFromApi.districts ?? [];
  //   } catch (e) {
  //     print("Error fetching districts: $e");
  //     return [];
  //   }
  // }

  // Future<void> _loadDistricts(int cityId) async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   try {
  //     List<District> districts = await getDistricts(cityId);
  //     setState(() {
  //       filteredDistricts = districts;
  //     });
  //   } catch (e) {
  //     print("Error fetching districts: $e");
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  // Future<void> _showCityPicker(BuildContext context) async {
  //   filteredCities = cities;
  //   await showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setState) {
  //           return Container(
  //             height: MediaQuery.of(context).size.height / 2,
  //             child: Column(
  //               children: [
  //                 Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: TextField(
  //                     decoration: InputDecoration(
  //                       labelText: 'ابحث عن مدينة',
  //                       prefixIcon: Icon(Icons.search),
  //                     ),
  //                     onChanged: (value) {
  //                       setState(() {
  //                         filteredCities = cities
  //                             .where((city) => city.name.contains(value))
  //                             .toList();
  //                       });
  //                     },
  //                   ),
  //                 ),
  //                 Expanded(
  //                   child: ListView.builder(
  //                     itemCount: filteredCities.length,
  //                     itemBuilder: (context, index) {
  //                       return ListTile(
  //                         title: Text(filteredCities[index].name),
  //                         onTap: () {
  //                           setState(() {
  //                             selectedCity = filteredCities[index];
  //                             selectedDistrict = null;
  //                             _loadDistricts(selectedCity!.id);
  //                           });
  //                           Navigator.pop(context);
  //                         },
  //                       );
  //                     },
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  // Future<void> _showDistrictPicker(BuildContext context) async {
  //   await showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setState) {
  //           return Container(
  //             height: MediaQuery.of(context).size.height / 2,
  //             child: Column(
  //               children: [
  //                 Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: TextField(
  //                     decoration: InputDecoration(
  //                       labelText: 'ابحث عن حي',
  //                       prefixIcon: Icon(Icons.search),
  //                     ),
  //                     onChanged: (value) {
  //                       setState(() {
  //                         filteredDistricts = filteredDistricts
  //                             .where(
  //                                 (district) => district.name.contains(value))
  //                             .toList();
  //                       });
  //                     },
  //                   ),
  //                 ),
  //                 Expanded(
  //                   child: ListView.builder(
  //                     itemCount: filteredDistricts.length,
  //                     itemBuilder: (context, index) {
  //                       return ListTile(
  //                         title: Text(filteredDistricts[index].name),
  //                         onTap: () {
  //                           setState(() {
  //                             selectedDistrict = filteredDistricts[index];
  //                           });
  //                           Navigator.pop(context);
  //                           Future.delayed(Duration(milliseconds: 100), () {
  //                             setState(
  //                                 () {}); // تأكيد التحديث بعد إغلاق القائمة
  //                           });
  //                         },
  //                       );
  //                     },
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
  Future<void> _requestLocation(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // فتح الإعدادات إذا تم رفض الإذن نهائيًا
      await Geolocator.openAppSettings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("تم رفض الإذن نهائيًا، قم بتفعيله من الإعدادات")),
      );
    } else if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      // setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم منح إذن الموقع بنجاح!")),
      );
    }
  }

  Future<void> _searchServices() async {
    final getPosition = await ApiConfig().getCurrentLocation();
    final latitude = getPosition.latitude;
    final longitude = getPosition.longitude;
    try {
      setState(() {
        isLoading = true;
      });

      final filters = {
        'category_id': id, // التصنيف المحدد
        'date': date ?? null,
        'time': time ?? null,
        ...fieldResults, // البيانات المجمعة من الحقول
      };

      final category = await ApiConfig.searchServices(
          filters, latitude ?? null, longitude ?? null);

      setState(() {
        fieldsWidget = category.Fields?.where((field) =>
                    field.type != 'File') // تصفية الحقول التي نوعها ليس 'File'
                .map((field) {
              final options =
                  field.options?.map((option) => option.toJson()).toList() ??
                      [];
              return FieldWidget(
                id: field.id,
                name: field.name,
                showName: field.showName,
                type: field.type,
                initialValue: fieldResults[field.name] ?? null,
                onChanged: (value) {
                  fieldResults[field.name] = value;
                },
                options: options,
              );
            }).toList() ??
            [];
        // services = category.services?.map((service) {
        //       print("${date} tttt");
        //       return ServiceAddedWidget(
        //         title: service.title,
        //         fields: service.insertedValues?.split(','),
        //         serviceProvider: service.user.name,
        //         price: service.price,
        //         id: service.id,
        //         count: 0,
        //         date: date ?? null,
        //         time: time ?? null,
        //       );
        //     }).toList() ??
        //     [];
        serviceProviders = category.service_providers?.map((service_provider) {
              return serviceProviderWidget(
                // title: "ssss",
                title: service_provider.name,
                id: service_provider.id,
                date: date ?? null,
                time: time ?? null,
                categoryId: id,
                profileImage: service_provider.profileImageUrl,
                averageRating: service_provider.averageRating,
                countRating: service_provider.countRating,
              );
            }).toList() ??
            [];
        isLoading = false;
      });
    } catch (e) {
      print("Error while searching services: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Future<void> _getDistrict(int district) async {
  //   List<Map<String, dynamic>> getDistrictOption =
  //       (await ApiConfig.getDistricts(district!))
  //           .districts!
  //           .map((district) => {'id': district.id, 'name': district.name})
  //           .toList();
  //   try {
  //     if (mounted) {
  //       setState(() {
  //         isLoading = true;
  //         districts = getDistrictOption;
  //         isLoading = false;
  //       });
  //     }
  //   } catch (e) {}
  // }

  void getAreaFromCoordinates(double latitude, double longitude) async {
    try {
      District? district = await ApiConfig.findArea(latitude, longitude);

      if (district != null) {
        if (mounted) {
          setState(() {
            DistrictFromLocation =
                "${district.city?.name}  -  ${district.name}";
          });
        }
        print("District Found: ${district.name}");
      } else {
        print("No district found for the provided coordinates.");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _getTheCategory() async {
    final prefs = await SharedPreferences.getInstance();
    final getPosition = await ApiConfig().getCurrentLocation();
    final latitude = getPosition.latitude;
    final longitude = getPosition.longitude;
    position = getPosition;
    Category category = await ApiConfig.getCategory(id, latitude, longitude);
    // List<Map<String, dynamic>> getCityOptions = (await ApiConfig.getCities())
    //     .map((city) => {'id': city.id, 'name': city.name})
    //     .toList();
    isServiceProvider = (prefs.getInt('isServiceProvider') == 1) ? true : false;
    try {
      // getCities();
      // getAreaFromCoordinates(latitude, longitude);
      setState(() {
        // cities = getCityOptions;
        fieldsWidget = category.Fields?.where((field) =>
                    field.type != 'File') // تصفية الحقول التي نوعها ليس 'File'
                .map((field) {
              final options =
                  field.options?.map((option) => option.toJson()).toList() ??
                      [];
              return FieldWidget(
                id: field.id,
                name: field.name,
                showName: field.showName,
                type: field.type,
                onChanged: (value) {
                  fieldResults[field.name] = value;
                },
                options: options,
              );
            }).toList() ??
            [];
        // services = category.services?.map((service) {
        //       print(date);
        //       return ServiceAddedWidget(
        //         title: service.title,
        //         fields: service.insertedValues?.split(','),
        //         serviceProvider: service.user.name,
        //         price: service.price,
        //         id: service.id,
        //         count: 0,
        //         date: date ?? null,
        //         time: time ?? null,
        //       );
        //     }).toList() ??
        //     [];
        serviceProviders = category.service_providers?.map((service_provider) {
          print(service_provider.profileImageUrl);
              return serviceProviderWidget(
                title: service_provider.name,
                // title: "qq",
                id: service_provider.id,
                date: date ?? null,
                time: time ?? null,
                categoryId: id,
                profileImage: service_provider.profileImageUrl,
                averageRating: service_provider.averageRating,
                countRating: service_provider.countRating,
              );
            }).toList() ??
            [];
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Widget _floatingButton() {
  return FloatingActionButton.extended(
    onPressed: () async {
      final isActive = await ApiConfig.checkMembershipStatus();
      if (!isActive) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('تنبيه'),
              content: Text('عضويتك غير مفعّلة حتى الآن.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('حسناً'),
                ),
              ],
            );
          },
        );
        return;
      }

      Navigator.pushNamed(
        context,
        '/create_service',
        arguments: [id, name],
      );
    },
    label: H1text(
      text: 'اضافة خدمة +',
      textColor: Colors.white,
    ),
    backgroundColor: Colors.orange[900],
  );
}


  Widget build(BuildContext context) {
    return MainScreenWidget(
      isLoading: isLoading,
      onRefresh: _getTheCategory,
      floatingFunction: (isServiceProvider == true) ? _floatingButton() : null,
      start: Column(
        children: [
          const SizedBox(
            height: 5,
          ),
          H1text(text: name),
          const SizedBox(
            height: 5,
          ),
          Divider(
            color: Color(0XFFEF5B2C).withOpacity(0.3),
          ),
          const SizedBox(
            height: 5,
          ),
          ...fieldsWidget,
          if (isServiceProvider == false) ...[
            FieldWidget(
              id: 30,
              name: '1',
              showName: 'اختر التاريخ',
              type: 'Date',
              initialValue: date ?? null,
              onChanged: (value) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    date = value;
                  });
                });
              },
            ),
            FieldWidget(
              id: 30,
              name: 'time',
              showName: 'اختر الوقت',
              initialValue: time ?? null,
              type: 'Time',
              onChanged: (value) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    time = value;
                  });
                });
              },
            ),
            SizedBox(
              height: 5,
            ),
          ],
          // Wrap(
          //   children: [
          //     if (DistrictFromLocation == null) ...[
          //       Container(
          //         width: MediaQuery.of(context).size.width * 0.4,
          //         child: GestureDetector(
          //           onTap: () => _showCityPicker(context),
          //           child: Container(
          //             width: double.infinity,
          //             padding:
          //                 EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          //             margin: EdgeInsets.all(8),
          //             decoration: BoxDecoration(
          //               border: Border.all(color: Colors.grey),
          //               borderRadius: BorderRadius.circular(8),
          //             ),
          //             child: Text(selectedCity?.name ?? 'اختر المدينة'),
          //           ),
          //         ),
          //       ),
          //       GestureDetector(
          //         onTap: () {
          //           if (selectedCity != null) {
          //             _loadDistricts(selectedCity!.id);
          //             _showDistrictPicker(context);
          //           } else {
          //             ScaffoldMessenger.of(context).showSnackBar(
          //               SnackBar(content: Text("اختر المدينة أولاً")),
          //             );
          //           }
          //         },
          //         child: Container(
          //           padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          //           width: MediaQuery.of(context).size.width * 0.5,
          //           margin: EdgeInsets.all(8),
          //           decoration: BoxDecoration(
          //             border: Border.all(color: Colors.grey),
          //             borderRadius: BorderRadius.circular(8),
          //           ),
          //           child: Text(selectedDistrict?.name ?? 'اختر الحي'),
          //         ),
          //       ),
          //     ],
          //     if (DistrictFromLocation != null)
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceAround,
          //         children: [
          //           H2Text(text: DistrictFromLocation ?? ""),
          //           InkWell(
          //             onTap: () {
          //               if (mounted) {
          //                 setState(() {
          //                   DistrictFromLocation = null;
          //                 });
          //               }
          //             },
          //             child: Container(
          //               alignment: Alignment.topRight,
          //               padding: EdgeInsets.only(top: 10, bottom: 10),
          //               child: Container(
          //                 decoration: BoxDecoration(
          //                   color: Color(0XFFEF5B2C),
          //                   borderRadius: BorderRadius.circular(10),
          //                 ),
          //                 height: 40,
          //                 width: 90,
          //                 child: H2Text(
          //                   text: "تغير",
          //                   textColor: Colors.white,
          //                   size: 18,
          //                   aligment: 'center',
          //                 ),
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
          //   ],
          // ),
          // FieldWidget(
          //   id: 30,
          //   name: 'city',
          //   options: cities,
          //   showName: 'اختر المدينة',
          //   initialValue: SelectedCity ?? null,
          //   type: 'Select',
          //   onChanged: (value) {
          //     SelectedCity = value;
          //     SelectedDistrict = null;
          //     districts = null;
          //     _getDistrict(int.tryParse(value)!);
          //   },
          // ),
          // if (districts != null)
          //   FieldWidget(
          //     id: 30,
          //     name: 'district',
          //     options: districts,
          //     showName: 'اختر الحي',
          //     initialValue: SelectedDistrict ?? null,
          //     type: 'Select',
          //     onChanged: (value) {
          //       SelectedDistrict = value;
          //     },
          //   ),
          if (isServiceProvider != true)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 40,
              children: [
                InkWell(
                  onTap: () {
                    fieldResults['category_id'] = id;
                    _searchServices();
                  },
                  child: Container(
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0XFFEF5B2C),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 40,
                      width: 150,
                      child: H2Text(
                        text: "بحث",
                        textColor: Colors.white,
                        size: 18,
                        aligment: 'center',
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        fieldResults = {};
                        fieldResults['category_id'] = id;
                        date = null;
                        time = null;
                        districts = null;
                        SelectedCity = null;
                        SelectedDistrict = null;
                      });
                      _searchServices();
                    }
                  },
                  child: Container(
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0XFFEF5B2C),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 40,
                      width: 150,
                      child: H2Text(
                        text: "مسح الفلاتر",
                        textColor: Colors.white,
                        size: 18,
                        aligment: 'center',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(
            height: 5,
          ),
          H1text(text: "موفري الخدمات"),
          const SizedBox(
            height: 10,
          ),
          Wrap(spacing: 10, runSpacing: 10, children: [
            if (serviceProviders.length == 0)
              Container(
                margin: EdgeInsets.all(30),
                child: Center(
                  child: getErrorMessage(),
                ),
              ),
            ...serviceProviders,
            // ...services,
          ]),
        ],
      ),
    );
  }

  Widget getErrorMessage() {
    if (position != null &&
        position!.latitude != 0.0 &&
        position!.longitude != 0.0) {
      return const Text("لا يوجد موفري خدمات بالقرب منك");
    } else {
      return Column(
        children: [
          const Text(
            'يجب تمكين خدمات الموقع للوصول لموفري الخدمات بمنطقتك',
            style: TextStyle(color: Colors.red),
          ),
          ElevatedButton(
            onPressed: () => _requestLocation(context),
            child: const Text("طلب إذن الموقع"),
          ),
          const Text(
            'بعد السماح يرجى تحديث الصفحه بسحبها للاسفل',
            style: TextStyle(color: Colors.red),
          ),
        ],
      );
    }
  }
}
