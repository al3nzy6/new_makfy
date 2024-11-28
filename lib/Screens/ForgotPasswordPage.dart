// forgot_password_page.dart
import 'package:flutter/material.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final ApiConfig apiService = ApiConfig();
  final TextEditingController emailController = TextEditingController();

  bool isLoading = false;
  String message = '';
  String errorMessage = '';

  Future<void> _sendResetPasswordEmail() async {
    setState(() {
      isLoading = true;
      message = '';
      errorMessage = '';
    });

    final email = emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        errorMessage = 'يرجى إدخال البريد الإلكتروني.';
        isLoading = false;
      });
      return;
    }

    // استدعاء وظيفة استعادة كلمة المرور
    final success = await ApiConfig.sendResetPasswordEmail(email);

    setState(() {
      isLoading = false;
    });

    if (success) {
      setState(() {
        message = 'تم إرسال رابط استعادة كلمة المرور إلى بريدك الإلكتروني.';
      });
    } else {
      setState(() {
        errorMessage = 'فشل في إرسال رابط استعادة كلمة المرور. حاول مرة أخرى.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScreenWidget(
      start: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'images/logo.png', // Ensure default image exists in assets
            height: 200,
          ),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'البريد الإلكتروني',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          if (message.isNotEmpty)
            Text(
              message,
              style: const TextStyle(color: Colors.green),
            ),
          if (errorMessage.isNotEmpty)
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          const SizedBox(height: 20),
          isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _sendResetPasswordEmail,
                  child: const Text('استعادة كلمة المرور'),
                ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () {
              Navigator.pop(context); // العودة إلى شاشة تسجيل الدخول
            },
            child: const Text("رجوع إلى تسجيل الدخول"),
          ),
        ],
      ),
      isLoading: isLoading,
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
