import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:makfy_new/Models/Cart.dart';
import 'package:makfy_new/Models/Category.dart';
import 'package:makfy_new/Models/Option.dart';
import 'package:makfy_new/Models/Service.dart';
import 'package:makfy_new/Models/User.dart';
import 'package:makfy_new/Models/fieldSection.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';
import 'package:makfy_new/Widget/FieldWidget.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';
import 'package:makfy_new/Widget/RateUserModal.dart';
import 'package:makfy_new/Widget/RatingWidget.dart';
import 'package:makfy_new/Widget/shimmerLoadingWidget.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:makfy_new/Widget/H1textWidget.dart';
import 'package:makfy_new/Widget/H2Text.dart';
import 'package:makfy_new/Widget/ServiceAddedWidget.dart';
import 'package:makfy_new/Widget/appHeadWidget.dart';
import 'package:makfy_new/Widget/boxWidget.dart';

class userServicesPage extends StatefulWidget {
  userServicesPage({super.key});

  @override
  State<userServicesPage> createState() => _userServicesPageState();
}

class _userServicesPageState extends State<userServicesPage> {
  late int id;
  late String name;
  late Cart? cart;
  late String? date;
  late String? time;
  List<Widget> services = [];
  Map<int, dynamic> finalresults = {};
  User? user;
  int? current_user;
  bool isLoading = true;
  bool? isPaid;
  bool? isServiceProvider;
  String? resultOfOtp;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // استلام البيانات الممررة من خلال ModalRoute
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map<String, dynamic>) {
      // التعامل مع `arguments` كـ `Map`
      id = arguments["id"];
      name = arguments["title"];
      cart = arguments["cart"];
      date = arguments["date"];
      time = arguments["time"];

      // استخدام البيانات المستخرجة حسب الحاجة
    } else if (arguments is List) {
      // التعامل مع `arguments` كـ `List`
      id = arguments[0];
      name = arguments[1];
      cart = null;
      date = null;
      time = null;
    }
    _getUserServices();
  }

  Future<void> _getUserServices() async {
    user = await ApiConfig.getUserProfile(id);
    current_user = await ApiConfig.getUserId();
    try {
      if (!mounted) return; // تأكد من أن الـ widget ما زالت موجودة
      setState(() {
        finalresults[0] = id;
        isPaid = (cart != null && cart?.status != 1) ? true : false;
        isServiceProvider =
            (cart != null && cart?.service_provider.id == current_user)
                ? true
                : false;
        services = (cart != null)
            ? cart?.services?.map((service) {
                  finalresults[service.id] = service.quantity;
                  return ServiceAddedWidget(
                    title: service.title,
                    fields: service.insertedValues?.split(','),
                    serviceProvider: service.user.name,
                    price: service.price,
                    id: service.id,
                    isPaid: isPaid,
                    currentUserIsTheProvider:
                        (user?.id == current_user) ? true : false,
                    onChanged: (value) {
                      finalresults[service.id] = value;
                    },
                    count: (finalresults.containsKey(service.id))
                        ? finalresults[service.id]
                        : 0,
                  );
                }).toList() ??
                []
            : user?.services?.map((service) {
                  return ServiceAddedWidget(
                    title: service.title,
                    fields: service.insertedValues?.split(','),
                    serviceProvider: service.user.name,
                    price: service.price,
                    id: service.id,
                    currentUserIsTheProvider:
                        (user?.id == current_user) ? true : false,
                    onChanged: (value) {
                      finalresults[service.id] = value;
                    },
                    count: (finalresults.containsKey(service.id))
                        ? finalresults[service.id]
                        : 0,
                  );
                }).toList() ??
                [];
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Widget build(BuildContext context) {
    return MainScreenWidget(
      isLoading: isLoading,
      onRefresh: _getUserServices,
      start: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              H1text(text: name),
              if (isServiceProvider != true) ...[
                RatingWidget(
                  stars: user?.averageRating ?? 0,
                  ratingCount: "${user?.countRating ?? 0}",
                  userId: user?.id ?? 0,
                  isRatingPage: (isPaid == true) ? true : false,
                ),
              ]
            ],
          ),
          if (cart != null && isPaid != true) ...[
            SizedBox(
              height: 30,
            ),
            H1text(text: "عزيزي العميل يرجى مراجعة السلة قبل عملية الدفع")
          ],
          // H2Text(text: "${services.length} خدمة"),
          if (isPaid != null && isPaid == true) ...[
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                if (isServiceProvider != true) ...[
                  InkWell(
                    onTap:
                        isPaid == true ? () => _openRatingModal(context) : null,
                    child: boxWidget(
                      // width: double.infinity,
                      icon: Icons.star,
                      title: "تقيم الخدمة",
                    ),
                  ),
                ],
                boxWidget(
                  // height: 90,
                  // width: double.infinity,
                  TextAsLogo: "رقم الطلب #",
                  TextAsLogoSize: 20,
                  title: "${cart!.id}",
                ),
                boxWidget(
                  // width: 210,
                  title: (isServiceProvider == true)
                      ? "${cart!.customer.phone}"
                      : "${cart!.service_provider.phone}",
                  icon: Icons.phone,
                ),
                boxWidget(
                  TextAsLogo: "اجمالي مبلغ الفاتورة",
                  TextAsLogoSize: 20,
                  title: "${cart!.total}",
                ),
                boxWidget(
                  width: double.infinity,
                  title: "حالة الخدمة",
                  TextAsLogo: (cart!.status == 2)
                      ? "قيد التنفيذ"
                      : (cart!.status == 3)
                          ? "قيد التنفيذ"
                          : (cart!.status == 4)
                              ? "مكتملة"
                              : "لم تكتمل",
                  TextAsLogoSize: 30,
                ),
                if (isServiceProvider != true && cart!.otp != null) ...[
                  boxWidget(
                    height: 160,
                    width: double.infinity,
                    title:
                        "رجاء اعطي هذا الكود لمقدم الخدمة عند وصول الطلب او إتمام الخدمة",
                    TextAsLogo: "${cart!.otp}",
                  ),
                ],
                if (isServiceProvider == true) ...[
                  if (cart!.status == 2) ...[
                    InkWell(
                      onTap:
                          isPaid == true ? () => _addOtpNumber(context) : null,
                      child: boxWidget(
                        height: 180,
                        width: double.infinity,
                        icon: Icons.settings,
                        title:
                            "لحفظ مستحقاتكم الماليه، رجاءً اطلب من العميل تزويدكم بالكود المرسل اليه وادخاله هنا عند وصول الخدمة او الطلب للعميل",
                      ),
                    ),
                  ],
                  if (cart!.status == 3) ...[
                    InkWell(
                      onTap:
                          isPaid == true ? () => _completeCart(cart!.id) : null,
                      child: boxWidget(
                        width: 210,
                        icon: Icons.done,
                        title: "اكمال الخدمة",
                      ),
                    ),
                  ],
                ]
              ],
            )
          ],
          SizedBox(
            height: 40,
          ),
          Wrap(spacing: 10, runSpacing: 10, children: [
            ...services,
            if (current_user != user?.id && (isPaid != true)) ...[
              InkWell(
                onTap: () => _saveAndPayCart(true),
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 240, 190, 174),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 70,
                      width: double.infinity,
                      child: H2Text(
                        text: "حفظ بالسلة",
                        aligment: 'center',
                        size: 25,
                        textColor: Colors.black,
                      )),
                ),
              ),
              InkWell(
                onTap: () => _saveAndPayCart(false),
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Color(0XFFEF5B2C),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 70,
                      width: double.infinity,
                      child: H2Text(
                        text: "المتابعة للدفع",
                        aligment: 'center',
                        size: 25,
                        textColor: Colors.white,
                      )),
                ),
              ),
            ],
            H2Text(
                aligment: 'center',
                lines: 3,
                text:
                    "عزيزي العميل في حال واجهة اي اشكالية يرجى التواصل مع خدمة العملاء")
          ]),
        ],
      ),
    );
  }

  Future<void> _saveAndPayCart(bool? OnlySaveAsCart) async {
    // print(finalresults);
    Map<String, dynamic> result =
        await ApiConfig.updateCart(finalresults, cart);
    try {
      print(double.tryParse(result['data']['total']));
      if (OnlySaveAsCart == false) {
        Navigator.pushNamed(context, '/payment_page', arguments: [
          result['data']['id'],
          double.tryParse(result['data']['total']) ?? 0.0
        ]);
      } else {
        Cart cart = Cart.fromJson(result['data']);
        Navigator.pushReplacementNamed(context, '/user_page', arguments: {
          "id": cart.service_provider.id,
          "title": cart.service_provider.name,
          "cart": cart,
        });
      }
    } catch (e) {}
  }

  void _openRatingModal(BuildContext context) {
    if (isPaid == true) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return RateUserModal(cart: cart!.id);
        },
      );
    }
  }

  void _addOtpNumber(BuildContext context) {
    final TextEditingController otpController = TextEditingController();
    bool modalClosed = false; // متغير لتتبع حالة الـ modal
    String? localResultOfOtp;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        String convertArabicToEnglishNumbers(String input) {
          const arabicToEnglishMap = {
            '٠': '0',
            '١': '1',
            '٢': '2',
            '٣': '3',
            '٤': '4',
            '٥': '5',
            '٦': '6',
            '٧': '7',
            '٨': '8',
            '٩': '9',
          };

          return input
              .split('')
              .map((char) => arabicToEnglishMap[char] ?? char)
              .join('');
        }

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return WillPopScope(
              onWillPop: () async {
                modalClosed = true; // تعيين modalClosed عند إغلاق الـ modal
                return true;
              },
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.1),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "إدخال الكود المرسل للعميل",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "أدخل كود الخدمة",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    if (localResultOfOtp != null)
                      Text(
                        localResultOfOtp!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ElevatedButton(
                      onPressed: () async {
                        if (otpController.text.isNotEmpty) {
                          final otpNumber = int.parse(
                              convertArabicToEnglishNumbers(
                                  otpController.text));
                          final cartId = cart!.id;

                          try {
                            if (!modalClosed) {
                              setModalState(() {
                                localResultOfOtp = "جاري معالجة الطلب...";
                              });
                            }

                            final response = await ApiConfig.makeCartOnProgress(
                                cartId, otpNumber);

                            if (response['data']['message'] == 'success') {
                              if (!modalClosed) {
                                Navigator.pop(context); // إغلاق الـ modal
                              }

                              // تحديث الشاشة بعد الإغلاق
                              if (mounted) {
                                setState(() {
                                  isLoading = true;
                                });
                                cart = await ApiConfig.getCart(cartId);
                                print(cart!.status);
                                Navigator.pushReplacementNamed(
                                    context, '/user_page',
                                    arguments: {
                                      "id": cart!.service_provider.id,
                                      "title": cart!.customer.name,
                                      "cart": cart,
                                    });

                                setState(() {
                                  isLoading = false;
                                });
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'تم تحويل الطلب إلى حالة قيد التنفيذ بنجاح'),
                                ),
                              );
                            } else {
                              if (!modalClosed) {
                                setModalState(() {
                                  localResultOfOtp =
                                      "الكود غير صحيح، الرجاء التحقق من موفر الخدمة";
                                });
                              }
                            }
                          } catch (e) {
                            if (!modalClosed) {
                              setModalState(() {
                                localResultOfOtp = "حدث خطأ أثناء العملية: $e";
                              });
                            }
                          }
                        } else {
                          if (!modalClosed) {
                            setModalState(() {
                              localResultOfOtp = "يرجى إدخال كود الخدمة";
                            });
                          }
                        }
                      },
                      child: Text("إرسال"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      modalClosed = true; // تعيين modalClosed عند إغلاق الـ modal
    });
  }

  Future<void> _completeCart(cartID) async {
    try {
      final response = await ApiConfig.makeCartComplete(cartID);
      if (response['data']['message'] == 'success') {
        ScaffoldMessenger.of(Navigator.of(context).overlay!.context)
            .showSnackBar(
          SnackBar(content: Text('تم تحويل الطلب إلى مكتملة')),
        );

        // استخدام setState لتحديث الصفحة
        setState(() {
          isLoading = true; // إعادة تحميل البيانات
        });
        await _getUserServices(); // استدعاء الدالة لجلب البيانات من جديد
        setState(() {
          isLoading = false; // إنهاء التحميل بعد جلب البيانات
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }
}
