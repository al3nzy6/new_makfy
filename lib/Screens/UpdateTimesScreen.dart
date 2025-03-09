import 'package:flutter/material.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';
import 'package:makfy_new/Widget/FieldWidget.dart';
import 'package:makfy_new/Widget/H2Text.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';
import 'package:makfy_new/Widget/lib/utils/MyRouteObserver.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateTimesScreen extends StatefulWidget {
  UpdateTimesScreen({Key? key}) : super(key: key);

  @override
  State<UpdateTimesScreen> createState() => _UpdateTimesScreenState();
}

class _UpdateTimesScreenState extends State<UpdateTimesScreen> {
  bool isLoading = false;
  String? statusMessage;
  String? start_time;
  String? end_time;
  @override
  void initState() {
    super.initState();
    _fetchCurrentTimeFromDatabase();
  }

  Future<void> _fetchCurrentTimeFromDatabase() async {
    setState(() {
      isLoading = true;
      statusMessage = "جاري جلب الموقع الحالي...";
    });

    try {
      final TimeWorkData = await ApiConfig.getUserWorkingHours();
      if (TimeWorkData != null) {
        final start = TimeWorkData['start_time'];
        final end = TimeWorkData['end_time'];
        setState(() {
          start_time = start;
          end_time = end;
          statusMessage =
              "الرجاء الضغط على تحديث الوقت بعد اختيار اوقات العمل اليوميه";
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

  // Update the user's Time
  Future<void> _updateTime() async {
    setState(() {
      isLoading = true;
      statusMessage = "جاري تحديث الاوقات";
    });

    try {
      final success = await ApiConfig.updateUserWorkingTime(
          start_time ?? '', end_time ?? '');
      setState(() {
        statusMessage =
            success ? "تم تحديث الاوقات بنجاح!" : "فشل في تحديث الوقت.";
      });
      if (success) {
        // _fetchCurrentTimeFromDatabase(); // Refresh the current Time
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم التعديل بنجاح!')),
        );
        // يمكن الانتقال إلى صفحة أخرى إذا لزم الأمر
        if (routeObserver.lastRoute != null) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            routeObserver.lastRoute!,
            (route) => false, // إزالة جميع الصفحات السابقة
            arguments: routeObserver.lastRouteArguments,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/', // الصفحة الرئيسية
            (route) => false, // إزالة جميع الصفحات السابقة
          );
        }
      }
    } catch (e) {
      setState(() {
        statusMessage = "حدث خطأ أثناء تحديث الوقت: $e";
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
          H2Text(
              lines: 5,
              text:
                  "الرجاء إدخال وقت بداية العمل اليومي ونهايته حيث سيتم تسجيل طلبات العملاء خلال اوقات عملك المسجلة هنا"),
          FieldWidget(
            id: 1,
            name: "start_time",
            showName: "بداية العمل",
            type: 'Time',
            initialValue: start_time,
            onChanged: (value) {
              start_time = value;
            },
          ),
          FieldWidget(
            id: 1,
            name: "end_time",
            showName: "نهاية العمل",
            type: 'Time',
            initialValue: end_time,
            onChanged: (value) {
              end_time = value;
            },
          ),
          if (statusMessage != null) ...[
            Text(
              statusMessage!,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
          ],
          ElevatedButton(
            onPressed: _updateTime,
            child: Text("تحديث الوقت"),
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
