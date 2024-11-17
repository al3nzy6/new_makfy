// login_page.dart
import 'package:flutter/material.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final ApiConfig apiService = ApiConfig();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String errorMessage = '';

  Future<void> _login() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Replace this print statement with actual login logic
    // print('Email: $email, Password: $password');

    // Example login call
    final success = await apiService.login(email, password);

    setState(() {
      isLoading = false;
    });

    if (success[0]) {
      // Navigate to home page if login is successful
      Navigator.pushReplacementNamed(context, '/');
    } else {
      // Show error message if login fails
      setState(() {
        errorMessage = success[1];
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
                labelText: 'البريد الالكتروني',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text('تسجيل الدخول'),
                  ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text("تسجيل عضوية"),
            ),
          ],
        ),
        isLoading: false);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
