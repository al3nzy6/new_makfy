import 'package:flutter/material.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateLocationScreen extends StatefulWidget {
  UpdateLocationScreen({Key? key}) : super(key: key);

  @override
  State<UpdateLocationScreen> createState() => _UpdateLocationScreenState();
}

class _UpdateLocationScreenState extends State<UpdateLocationScreen> {
  bool isLoading = false;
  String? statusMessage;
  String? currentLocationLink;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocationFromDatabase();
  }

  // Fetch the current location from the database
  Future<void> _fetchCurrentLocationFromDatabase() async {
    setState(() {
      isLoading = true;
      statusMessage = "جاري جلب الموقع الحالي...";
    });

    try {
      final locationData = await ApiConfig.getUserLocation();
      if (locationData != null) {
        final latitude = locationData['latitude'];
        final longitude = locationData['longitude'];
        setState(() {
          currentLocationLink =
              "https://www.google.com/maps?q=${latitude},${longitude}";
          statusMessage = "لديك موقع مسجل لدينا";
        });
      } else {
        setState(() {
          statusMessage =
              " لم يتم العثور على موقع مسجل الرجاء تحديث الموقع لإستلام الطلبات.";
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = "حدث خطأ أثناء جلب الموقع: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Update the user's location
  Future<void> _updateLocation() async {
    setState(() {
      isLoading = true;
      statusMessage = "جاري تحديث الموقع...";
    });

    try {
      final success = await ApiConfig.updateUserLocation();
      setState(() {
        statusMessage =
            success ? "تم تحديث الموقع بنجاح!" : "فشل في تحديث الموقع.";
      });
      if (success) {
        _fetchCurrentLocationFromDatabase(); // Refresh the current location

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الموقع بنجاح!')),
        );
        // يمكن الانتقال إلى صفحة أخرى إذا لزم الأمر
        Navigator.pushReplacementNamed(context, '/update_times');
      }
    } catch (e) {
      setState(() {
        statusMessage = "حدث خطأ أثناء تحديث الموقع: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScreenWidget(
      isLoading: isLoading,
      start: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (currentLocationLink != null) ...[
            const Text(
              "الموقع الحالي:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => launchURL(currentLocationLink!),
              child: Text(
                "اضغط هنا لعرض الموقع المسجل على خرائط قوقل",
                style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (statusMessage != null) ...[
            Text(
              statusMessage!,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
          ElevatedButton(
            onPressed: _updateLocation,
            child: const Text("تحديث الموقع"),
          ),
        ],
      ),
    );
  }

  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw "لا يمكن فتح الرابط: $url";
    }
  }
}
