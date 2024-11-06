import 'package:flutter/material.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';
import 'package:makfy_new/Widget/H1textWidget.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';
import 'package:makfy_new/Widget/boxWidget.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmationController =
      TextEditingController();

  final TextEditingController idnumberController = TextEditingController();
  String? nationality;
  final TextEditingController ibanController = TextEditingController();
  String? bankController;
  final List<String> banks = [
    "بنك الراجحي",
    "البنك الأهلي",
    "بنك الرياض",
    "بنك الإنماء",
    "بنك البلاد"
  ];
  final List<String> nationalities = [
    "سعودي",
    "مصري",
    "سوداني",
    "يمني",
    "سوري",
    "هندي",
    "باكستاني",
    "بنقلاديشي",
  ];
  final ApiConfig apiService = ApiConfig();
  bool? isServiceProvider;

  bool isLoading = false;
  Map<String, dynamic>? errorMessage;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        errorMessage;
      });

      final name = nameController.text.trim();
      final phone = phoneController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final passwordConfirmation = passwordConfirmationController.text.trim();

      final idnumber = idnumberController.text.trim();
      final iban = ibanController.text.trim();
      final success = await apiService.register(
          name,
          phone,
          email,
          password,
          passwordConfirmation,
          isServiceProvider,
          idnumber,
          nationality,
          bankController,
          iban);

      setState(() {
        isLoading = false;
      });

      if (success[0]) {
        // عرض رسالة نجاح أو الانتقال إلى صفحة أخرى
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم التسجيل بنجاح!')),
        );
        // يمكن الانتقال إلى صفحة أخرى إذا لزم الأمر
        Navigator.pushReplacementNamed(context, '/');
      } else {
        // عرض رسالة خطأ إذا فشل التسجيل
        setState(() {
          errorMessage = Map<String, dynamic>.from(success[1]);
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    if (isServiceProvider == true) {
      idnumberController.dispose();
      ibanController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainScreenWidget(
        start: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/logo.png', // Ensure default image exists in assets
                  height: 200,
                ),
                if (isServiceProvider == null) ...[
                  Column(
                    children: [
                      H1text(text: "الرجاء اختيار نوع العضوية"),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () => setState(() {
                              isServiceProvider = true;
                            }),
                            child: boxWidget(
                                title: "موفر خدمات",
                                icon: Icons.engineering_rounded),
                          ),
                          InkWell(
                            onTap: () => setState(() {
                              isServiceProvider = false;
                            }),
                            child: boxWidget(title: "عميل", icon: Icons.person),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
                if (isServiceProvider != null) ...[
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم المستخدم',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال اسم المستخدم';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال رقم الهاتف';
                      } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'يرجى إدخال رقم هاتف صالح';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال البريد الإلكتروني';
                      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                          .hasMatch(value)) {
                        return 'يرجى إدخال بريد إلكتروني صالح';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'كلمة المرور',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال كلمة المرور';
                      } else if (value.length < 6) {
                        return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: passwordConfirmationController,
                    decoration: const InputDecoration(
                      labelText: 'تاكيد كلمة المرور',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال كلمة المرور';
                      } else if (value.length < 6) {
                        return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  if (isServiceProvider == true) ...[
                    TextFormField(
                      controller: idnumberController,
                      decoration: const InputDecoration(
                        labelText: 'رقم الهوية/الاقامة',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال رقم الهوية/الاقامة ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'الجنسية',
                        border: OutlineInputBorder(),
                      ),
                      value: nationality,
                      items: nationalities.map((String nationality) {
                        return DropdownMenuItem<String>(
                          value: nationality,
                          child: Text(nationality),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          nationality = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء اختيار البنك';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'البنك',
                        border: OutlineInputBorder(),
                      ),
                      value: bankController,
                      items: banks.map((String bank) {
                        return DropdownMenuItem<String>(
                          value: bank,
                          child: Text(bank),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          bankController = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء اختيار البنك';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: ibanController,
                      decoration: const InputDecoration(
                        labelText: 'IBAN ايبان',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال IBAN الايبان ';
                        }
                        return null;
                      },
                    ),
                  ],
                  if (errorMessage != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: errorMessage!.entries.map((entry) {
                        // استخراج الحقل والرسائل المرتبطة به
                        String fieldName = entry.key;
                        List<String> fieldErrors =
                            List<String>.from(entry.value);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...fieldErrors.map((error) => Text(
                                  error,
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 16),
                                )),
                            SizedBox(height: 10),
                          ],
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 20),
                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _register,
                          child: const Text('تسجيل'),
                        ),
                ]
              ],
            ),
          ),
        ),
        isLoading: false);
  }
}
