import 'package:flutter/material.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

class TabbyPaymentWebViewPage extends StatelessWidget {
  final String webUrl;
  final String paymentUUID;

  const TabbyPaymentWebViewPage({
    Key? key,
    required this.webUrl,
    required this.paymentUUID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("دفع تابي")),
      body: Builder(
        builder: (context) {
          TabbyWebView.showWebView(
            context: context,
            webUrl: webUrl,
            onResult: (result) {
              Navigator.pop(context); // يرجع للصفحة السابقة
              switch (result) {
                case WebViewResult.authorized:
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("تمت الموافقة على العملية")),
                  );
                  break;
                case WebViewResult.close:
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("تم إغلاق نافذة الدفع")),
                  );
                  break;
                case WebViewResult.expired:
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("انتهت صلاحية الجلسة")),
                  );
                  break;
                case WebViewResult.rejected:
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("تم رفض العملية من Tabby")),
                  );
                  break;
              }
            },
          );
          return const SizedBox(); // ضروري لعدم كسر البناء
        },
      ),
    );
  }
}
