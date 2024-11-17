import 'package:flutter/material.dart';
import 'package:makfy_new/Models/City.dart';
import 'package:makfy_new/Models/District.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';
import 'package:makfy_new/Widget/H1textWidget.dart';
import 'package:makfy_new/Widget/H2Text.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';

class MyDistrictsPage extends StatefulWidget {
  MyDistrictsPage({Key? key}) : super(key: key);

  @override
  State<MyDistrictsPage> createState() => _MyDistrictsPageState();
}

class _MyDistrictsPageState extends State<MyDistrictsPage> {
  late int id;
  late String name;
  bool isLoading = true;
  List<City> cities = [];
  List<City> filteredCities = [];
  District? selectedDistrict;
  City? selectedCity;
  Future<List<District>>? districtsFuture;
  List<District> filteredDistricts = [];
  List<District> userDistricts = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      fetchUserDistricts();
      getCities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainScreenWidget(
      isLoading: isLoading,
      start: SingleChildScrollView(
        child: DistrictWidget(),
      ),
    );
  }

  Widget DistrictWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        H1text(text: 'الأحياء'),
        H2Text(text: 'إضافة الأحياء التي يمكنك تقديم الخدمات فيها'),
        SizedBox(height: 20),
        Wrap(
          children: [
            GestureDetector(
              onTap: () => _showCityPicker(context),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(selectedCity?.name ?? 'اختر المدينة'),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (selectedCity != null) {
                  _loadDistricts(selectedCity!.id);
                  _showDistrictPicker(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("اختر المدينة أولاً")),
                  );
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                width: double.infinity,
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(selectedDistrict?.name ?? 'اختر الحي'),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        if (selectedCity != null && selectedDistrict != null)
          InkWell(
            onTap: () => _addDistrict(),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Color(0XFFEF5B2C),
              ),
              height: 60,
              width: double.infinity,
              child: H2Text(
                text: "إضافة الحي",
                textColor: Colors.white,
                size: 30,
              ),
            ),
          ),
        SizedBox(height: 20),
        Flexible(
          fit: FlexFit.loose,
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: userDistricts.length,
            itemBuilder: (context, index) {
              final district = userDistricts[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(district.name),
                  subtitle: Text("المدينة: ${district.city?.name ?? ''}"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteDistrict(district.id),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _loadDistricts(int cityId) async {
    setState(() {
      isLoading = true;
    });
    try {
      List<District> districts = await getDistricts(cityId);
      setState(() {
        filteredDistricts = districts;
      });
    } catch (e) {
      print("Error fetching districts: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<District>> getDistricts(int cityId) async {
    try {
      City cityFromApi = await ApiConfig.getDistricts(cityId);
      return cityFromApi.districts ?? [];
    } catch (e) {
      print("Error fetching districts: $e");
      return [];
    }
  }

  Future<void> getCities() async {
    try {
      List<City> citiesFromApi = await ApiConfig.getCities();
      setState(() {
        cities = citiesFromApi;
        filteredCities = citiesFromApi;
      });
    } catch (e) {
      print("Error fetching cities: $e");
    }
  }

  Future<void> fetchUserDistricts() async {
    setState(() {
      isLoading = true;
    });
    try {
      List<District> districts = await ApiConfig.getUserDistricts();
      setState(() {
        userDistricts = districts;
      });
    } catch (e) {
      print("Error fetching user districts: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل في جلب الأحياء")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addDistrict() async {
    if (selectedDistrict != null) {
      setState(() {
        isLoading = true;
      });

      bool success = await ApiConfig.addDistrict(selectedDistrict!.id);

      setState(() {
        isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("تمت إضافة الحي بنجاح")),
        );
        selectedDistrict = null;
        selectedCity = null;
        fetchUserDistricts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("فشل في إضافة الحي")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("يرجى اختيار حي لإضافته")),
      );
    }
  }

  Future<void> _deleteDistrict(int districtId) async {
    bool success = await ApiConfig.deleteUserDistrict(districtId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تم حذف الحي بنجاح")),
      );
      fetchUserDistricts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل في حذف الحي")),
      );
    }
  }

  Future<void> _showCityPicker(BuildContext context) async {
    filteredCities = cities;
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height / 2,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'ابحث عن مدينة',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredCities = cities
                              .where((city) => city.name.contains(value))
                              .toList();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredCities.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(filteredCities[index].name),
                          onTap: () {
                            setState(() {
                              selectedCity = filteredCities[index];
                              selectedDistrict = null;
                              _loadDistricts(selectedCity!.id);
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showDistrictPicker(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height / 2,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'ابحث عن حي',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredDistricts = filteredDistricts
                              .where(
                                  (district) => district.name.contains(value))
                              .toList();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredDistricts.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(filteredDistricts[index].name),
                          onTap: () {
                            setState(() {
                              selectedDistrict = filteredDistricts[index];
                            });
                            Navigator.pop(context);
                            Future.delayed(Duration(milliseconds: 100), () {
                              setState(
                                  () {}); // تأكيد التحديث بعد إغلاق القائمة
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
