import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is int) {
      id = arguments;
    }
    if (arguments is List) {
      id = arguments[0];
      name = arguments[1];
    }
    getCities();
  }

  @override
  Widget build(BuildContext context) {
    return MainScreenWidget(isLoading: isLoading, start: DistrictWidget());
  }

  Widget DistrictWidget() {
    return Column(
      children: [
        H1text(text: 'الاحياء'),
        H2Text(
          text: ' اضافة الاحياء التي يمكنك تقديم الخدمات فيها',
        ),
        SizedBox(height: 40),
        Wrap(
          children: [
            GestureDetector(
              onTap: () => _showCityPicker(context),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(selectedCity?.name ?? 'اختر المدينة'),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                if (selectedCity != null) {
                  _showDistrictPicker(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("اختر المدينة أولاً")),
                  );
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(selectedDistrict?.name ?? 'اختر الحي'),
              ),
            ),
          ],
        ),
        if (selectedCity != null && selectedDistrict != null)
          SizedBox(
            height: 20,
          ),
        Container(
          height: 70,
          width: double.infinity,
          color: Color(0XFFEF5B2C),
          child: H2Text(
            text: "اضافة الحي",
            textColor: Colors.white,
            size: 30,
          ),
        ),
      ],
    );
  }

  Future<void> _showCityPicker(BuildContext context) async {
    filteredCities = cities; // ابدأ بفلترة المدن كلها عند فتح القائمة
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 400,
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
                              print(selectedCity?.id);
                              selectedDistrict = null;
                              districtsFuture = getDistricts(selectedCity!.id);
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
    filteredDistricts = await districtsFuture ?? [];
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 400,
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
                          filteredDistricts =
                              (districtsFuture as Future<List<District>>)
                                  .asStream()
                                  .first
                                  .then((districts) => districts
                                      .where((district) =>
                                          district.name.contains(value))
                                      .toList()) as List<District>;
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

  Future<void> getCities() async {
    try {
      List<City> citiesFromApi = await ApiConfig.getCities();
      setState(() {
        cities = citiesFromApi;
        filteredCities = citiesFromApi;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching cities: $e");
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
}
