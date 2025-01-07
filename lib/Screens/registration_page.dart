import 'package:flutter/material.dart';
import 'package:makfy_new/Models/User.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';
import 'package:makfy_new/Widget/H1textWidget.dart';
import 'package:makfy_new/Widget/H2Text.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';
import 'package:makfy_new/Widget/boxWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final TextEditingController orderLimitPerDayController =
      TextEditingController();
  String? bankController;
  bool agreeToTerms = false;

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
  bool? isEdit;
  User? user;
  bool isLoading = true;
  Map<String, dynamic>? errorMessage;
  @override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _openTermsAndConditions() async {
    // const url = 'http://makfy.test/terms'; // استبدل الرابط برابط الشروط
    const url = 'https://makfy.sa/terms'; // استبدل الرابط برابط الشروط
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'لا يمكن فتح الرابط: $url';
    }
  }

  Future<void> _initUser() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final user_id =
          (prefs.getInt('user_id') != null) ? prefs.getInt('user_id') : 0;
      if (user_id != null && user_id != 0) {
        user = await ApiConfig.getUserProfile(user_id!);
        setState(() {
          isEdit = true;
          isServiceProvider =
              (prefs.getInt('isServiceProvider') == 1) ? true : false;

          // تعيين القيم الافتراضية في الحقول في حال كان isEdit == true
          nameController.text = user?.name ?? '';
          phoneController.text = user?.phone ?? '';
          emailController.text = user?.email ?? '';
          nationality = user?.nationality;
          bankController = user?.bank;
          ibanController.text = user?.iban ?? '';
          orderLimitPerDayController.text = user?.order_limit_per_day ?? "";

          // إذا كان المستخدم مزود خدمات، يتم جلب رقم الهوية
          if (isServiceProvider == true) {
            idnumberController.text = user?.id_number.toString() ?? '';
          }

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          isEdit = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isEdit = false;
      });
      print("Error loading user data: $e");
    }
  }

  Future<void> _update() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        errorMessage;
      });

      final name = nameController.text.trim();
      final phone = phoneController.text.trim();
      final email = emailController.text.trim();

      final idnumber = idnumberController.text.trim();
      final iban = ibanController.text.trim();
      final orderLimitPerDay = orderLimitPerDayController.text.trim();
      final success = await apiService.updateProfile(
          name,
          phone,
          email,
          isServiceProvider,
          idnumber,
          nationality,
          bankController,
          iban,
          orderLimitPerDay);

      setState(() {
        isLoading = false;
      });

      if (success[0]) {
        // عرض رسالة نجاح أو الانتقال إلى صفحة أخرى
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم التعديل بنجاح!')),
        );
        // يمكن الانتقال إلى صفحة أخرى إذا لزم الأمر
        Navigator.pushReplacementNamed(context, '/');
      } else {
        // عرض رسالة خطأ إذا فشل التعديل
        setState(() {
          errorMessage = Map<String, dynamic>.from(success[1]);
        });
      }
    }
  }

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
      final orderLimitPerDay = orderLimitPerDayController.text.trim();
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
          iban,
          orderLimitPerDay);

      setState(() {
        isLoading = false;
      });

      if (success[0]) {
        // عرض رسالة نجاح أو الانتقال إلى صفحة أخرى
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم التسجيل بنجاح!')),
        );
        // يمكن الانتقال إلى صفحة أخرى إذا لزم الأمر
        (isServiceProvider == 1)
            ? Navigator.pushReplacementNamed(context, '/update_location')
            : Navigator.pushReplacementNamed(context, '/');
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
      orderLimitPerDayController.dispose();
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
                if (isEdit == false && isServiceProvider == null) ...[
                  Column(
                    children: [
                      H1text(text: "الرجاء اختيار نوع العضوية"),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      H2Text(
                          lines: 5,
                          text:
                              "باكمالك التسجيل تفيد بموافقتك على الشروط والسياسات وتتعهد بالتزامك بها")
                    ],
                  )
                ],
                if (isServiceProvider != null) ...[
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال الاسم  ';
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
                  if (isEdit == false) ...[
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
                  ],
                  const SizedBox(height: 20),
                  if (isServiceProvider == true) ...[
                    TextFormField(
                      controller: idnumberController,
                      readOnly:
                          (isEdit != null && isEdit == true) ? true : false,
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
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: orderLimitPerDayController,
                      decoration: const InputDecoration(
                        labelText: 'حد استقبال الطلبات باليوم',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى ادخال الحد';
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
                  SizedBox(height: 20),
                  CheckboxListTile(
                    title: Column(
                      children: [
                        const Text("الموافقة على الشروط والأحكام"),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: _openTermsAndConditions,
                          child: const Text(
                            "للاطلاع اضغط هنا",
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    value: agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        agreeToTerms = value!;
                      });
                    },
                  ),
                  if (isEdit == true && isServiceProvider == true)
                    H2Text(text: "لتعديل رقم الهوية الرجاء مراجعة الدعم الفني"),
                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: agreeToTerms
                              ? (isEdit == false)
                                  ? _register
                                  : _update
                              : null,
                          child:
                              (isEdit == false) ? Text('تسجيل') : Text('تعديل'),
                        ),
                ],
              ],
            ),
          ),
        ),
        isLoading: false);
  }
}
