import 'package:flutter/material.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';
import 'package:makfy_new/Widget/H2Text.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';

class DeleteUserScreen extends StatefulWidget {
  DeleteUserScreen({Key? key}) : super(key: key);

  @override
  State<DeleteUserScreen> createState() => _DeleteUserScreenState();
}

class _DeleteUserScreenState extends State<DeleteUserScreen> {
  bool isLoading = false;
  String? statusMessage;

  // دالة لحذف الحساب وتسجيل الخروج
  Future<void> _deleteAccount() async {
    setState(() {
      isLoading = true;
      statusMessage = "جاري حذف الحساب...";
    });

    try {
      // استدعاء API لحذف الحساب
      final result = await ApiConfig.deleteUser();
      if (result == true) {
        // إذا تم الحذف بنجاح
        await ApiConfig().logout(); // تسجيل خروج المستخدم
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/'); // توجيه للصفحة الرئيسية
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حذف الحساب بنجاح!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          statusMessage = "فشل حذف الحساب. حاول مرة أخرى.";
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = "حدث خطأ أثناء حذف الحساب: $e";
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
          Icon(Icons.warning, color: Colors.red, size: 100),
          SizedBox(height: 20),
          H2Text(
            lines: 3,
            text:
                "تنبيه: سيتم حذف حسابك بشكل دائم، ولا يمكن التراجع عن هذه العملية.",
            textColor: Colors.red,
            size: 20,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            onPressed: _deleteAccount,
            child: Text(
              "حذف الحساب",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          SizedBox(height: 20),
          if (statusMessage != null) ...[
            Text(
              statusMessage!,
              style: TextStyle(fontSize: 16, color: Colors.blueGrey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}
