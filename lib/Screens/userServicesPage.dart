import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:makfy_new/Models/Cart.dart';
import 'package:makfy_new/Models/User.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';
import 'package:makfy_new/Widget/FieldWidget.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';
import 'package:makfy_new/Widget/RateUserModal.dart';
import 'package:makfy_new/Widget/RatingWidget.dart';
import 'package:makfy_new/Widget/H1textWidget.dart';
import 'package:makfy_new/Widget/H2Text.dart';
import 'package:makfy_new/Widget/ServiceAddedWidget.dart';
import 'package:makfy_new/Widget/boxWidget.dart';
import 'package:url_launcher/url_launcher.dart';

class userServicesPage extends StatefulWidget {
  userServicesPage({super.key});

  @override
  State<userServicesPage> createState() => _userServicesPageState();
}

class _userServicesPageState extends State<userServicesPage> {
  late int id;
  late String name;
  late Cart? cart;
  late String? submitType;
  late String? date = DateTime.now().toLocal().toString().split(' ')[0];
  late String? time = TimeOfDay.now().format(context).toString();
  List<Widget> services = [];
  Map<int, dynamic> finalresults = {};
  User? user;
  bool hasDelivery = true; // لتخزين حالة الاختيار
  int? current_user;
  bool isLoading = true;
  bool? isPaid;
  bool? isServiceProvider;
  String? resultOfOtp;
  bool? timeIsAvailable = false;
  bool? checkTimePressed = false;
  String? dateTimeStamp;
  String? choosenDate;
  String? choosenTime;
  String? timeisNotAvailableText;
  bool _hasBeenLoaded = false;

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
      submitType = arguments['submitType'];
      if (_hasBeenLoaded == false) {
        if (arguments['date'] != null) {
          choosenDate = arguments['date'];
          date = choosenDate;
        }
        if (arguments['time'] != null) {
          choosenTime = arguments['time'];
          time = choosenTime;
        }
      }

      // استخدام البيانات المستخرجة حسب الحاجة
    } else if (arguments is List) {
      // التعامل مع `arguments` كـ `List`
      id = arguments[0];
      name = arguments[1];
      cart = null;
    }
    if (_hasBeenLoaded == false) {
      print("${id} sssss");
      _getUserServices();
      checkTime(id, date!, time!);
    }
  }

  void _showSaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("تم الحفظ بنجاح"),
          content: Text("تم حفظ وتحديث السلة بنجاح."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق المودال
              },
              child: Text("موافق"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _getUserServices() async {
    user = await ApiConfig.getUserProfile(id);
    current_user = await ApiConfig.getUserId();
    try {
      if (!mounted) return; // تأكد من أن الـ widget ما زالت موجودة
      setState(() {
        _hasBeenLoaded = true;
        if (submitType == 'update') {
          submitType = null;
          _showSaveDialog(context); // إظهار المودال عند نجاح الحفظ
        }
        finalresults[0] = id;
        isPaid = (cart != null && cart?.status != 1) ? true : false;
        if (cart != null) {
          hasDelivery = cart!.delivery_fee! > 0 ? true : false;
          dateTimeStamp = cart!.service_time;
          timeIsAvailable = true;
          date = null;
          time = null;
        }
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
                    service: service,
                    imageUrl: service.imageUrls,
                    isPaid: isPaid,
                    isLogin: (current_user != null) ? true : false,
                    currentUserIsTheProvider:
                        (user?.id == current_user) ? true : false,
                    onChanged: (value) {
                      if (mounted) {
                        setState(() {
                          finalresults[service.id] = value;
                        });
                      }
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
                    service: service,
                    imageUrl: service.imageUrls,
                    isLogin: (current_user != null) ? true : false,
                    currentUserIsTheProvider:
                        (user?.id == current_user) ? true : false,
                    onChanged: (value) {
                      if (mounted) {
                        setState(() {
                          finalresults[service.id] = value;
                        });
                      }
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

  Future<void> checkTime(
      int serviceProviderID, String date, String time) async {
    String response =
        await ApiConfig.checkAvailableTime(serviceProviderID, date, time);
    try {
      if (mounted) {
        setState(() {
          if (response != 'Not Available') {
            timeIsAvailable = true;
            dateTimeStamp = response;
            checkTimePressed = false;
          } else {
            timeIsAvailable = false;
            checkTimePressed = false;
            timeisNotAvailableText = "الوقت الذي اخترته غير متاح";
          }
        });
      }
    } catch (e) {}
  }

  Widget build(BuildContext context) {
    print(cart?.choosenTime);
    return MainScreenWidget(
      isLoading: isLoading,
      onRefresh: _getUserServices,
      start: Column(
        children: [
          if (isPaid == null || isPaid == false && cart != null) ...[
            Align(
              alignment: Alignment.topLeft,
              child: InkWell(
                onTap: () async {
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("تأكيد الحذف"),
                        content: Text("هل أنت متأكد من حذف السلة؟"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, false); // لا تحذف
                            },
                            child: Text("إلغاء"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, true); // تأكيد الحذف
                            },
                            child: Text("حذف",
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldDelete == true) {
                    if (mounted) {
                      setState(() {
                        isLoading = true;
                      });

                      try {
                        // استدعاء دالة حذف السلة
                        bool isDeleted = await ApiConfig.deleteCart(cart!.id);

                        if (isDeleted) {
                          // الرجوع إلى الصفحة السابقة مع رسالة نجاح
                          if (mounted) {
                            Navigator.pop(context, "تم حذف السلة بنجاح");
                          }
                        } else {
                          // عرض رسالة فشل
                          print("Failed to delete the cart.");
                        }
                      } catch (e) {
                        // التعامل مع أي أخطاء
                        print("Error while deleting the cart: $e");
                      } finally {
                        // إيقاف حالة التحميل
                        if (mounted) {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      }
                    }
                  }
                },
                child: boxWidget(
                  title: "حذف السلة",
                  icon: Icons.delete,
                  iconSize: 20,
                  width: 100,
                  height: 80,
                  titleColor: Colors.red,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
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
          SizedBox(
            height: 20,
          ),
          if (user?.id != current_user &&
              (isPaid == false || isPaid == null)) ...[
            const SizedBox(
              height: 20,
            ),
            H2Text(
              lines: 4,
              text: (dateTimeStamp == null)
                  ? 'الرجاء اختيار التاريخ والوقت المطلوب لاستلام الخدمات والتحقق منه عبر الزر اسفل الوقت'
                  : 'وقت الخدمة متاح',
              textColor: (dateTimeStamp == null) ? Colors.red : Colors.blue,
            ),
            const SizedBox(
              height: 10,
            ),
            if ((timeIsAvailable == null || timeIsAvailable == false)) ...[
              FieldWidget(
                id: 1,
                name: "date",
                showName: (cart?.choosenDate == null)
                    ? "اختر التاريخ"
                    : "التاريخ الحالي : اختر ادناه للتغير",
                type: "Date",
                initialValue: cart?.choosenDate ?? choosenDate,
                onChanged: (value) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      date = value;
                      choosenDate = date;
                    });
                  });
                },
              ),
              FieldWidget(
                id: 1,
                name: "time",
                showName: (cart?.choosenTime == null)
                    ? "اختر الوقت"
                    : "الوقت الحالي : اختر الوقت للتغير",
                type: "Time",
                initialValue: cart?.choosenTime ?? choosenTime,
                onChanged: (value) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      time = value;
                      choosenTime = time;
                    });
                  });
                },
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton.icon(
                  label: Text((checkTimePressed == false)
                      ? 'اضغط هنا للتحقق من الوقت والتاريخ'
                      : 'جاري التحقق .. الرجاء الانتظار'),
                  iconAlignment: IconAlignment.start,
                  onPressed: (checkTimePressed == false)
                      ? () {
                          setState(() {
                            checkTimePressed = true;
                          });
                          checkTime(user!.id, date!, time!);
                        }
                      : null,
                  icon: Icon(Icons.search)),
              if (timeisNotAvailableText != null) ...[
                H2Text(
                  text: timeisNotAvailableText ?? '',
                  textColor: Colors.red,
                )
              ],
            ],
          ],
          if ((current_user != user?.id &&
                  timeIsAvailable == true &&
                  timeIsAvailable != null) ||
              isPaid == true) ...[
            // if (isPaid != true) ...[
            //   H2Text(
            //       lines: 3,
            //       textColor: const Color.fromARGB(255, 18, 88, 145),
            //       text:
            //           "الوقت والتاريخ الذي اخترته متوفر لدى موفر الخدمة بامكانك إتمام الطلب"),
            // ],
            Wrap(spacing: 10, children: [
              boxWidget(
                title: "التاريخ",
                height: 90,
                TextAsLogo: (date != null) ? "${date}" : "${cart!.choosenDate}",
                TextAsLogoSize: 20,
              ),
              boxWidget(
                title: "الوقت",
                height: 90,
                TextAsLogo: (time != null) ? "${time}" : "${cart!.choosenTime}",
                TextAsLogoSize: 20,
              ),
            ]),
            SizedBox(
              height: 10,
            ),
            if (isPaid != true && current_user != user?.id) ...[
              ElevatedButton.icon(
                  label: Text('اعادة ضبط الوقت والتاريخ'),
                  iconAlignment: IconAlignment.start,
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        timeIsAvailable = false;
                        dateTimeStamp = null;
                      });
                    }
                  },
                  icon: Icon(Icons.update)),
            ],
          ],
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
                      iconSize: 50,
                      height: 100,
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
                  height: 100,

                  TextAsLogoSize: 20,
                  title: "${cart!.id}",
                ),
                InkWell(
                  onTap: () => {
                    _makePhoneCall(
                      (isServiceProvider == true)
                          ? "${cart!.customer.phone}"
                          : "${cart!.service_provider.phone}",
                    )
                  },
                  child: boxWidget(
                    // width: 210,
                    height: 100,
                    iconSize: 50,
                    title: (isServiceProvider == true)
                        ? "${cart!.customer.phone}"
                        : "${cart!.service_provider.phone}",
                    icon: Icons.call,
                  ),
                ),
                InkWell(
                  onTap: () => {
                    _openWhatsApp(
                      (isServiceProvider == true)
                          ? "${cart!.customer.phone}"
                          : "${cart!.service_provider.phone}",
                    )
                  },
                  child: boxWidget(
                    height: 100,
                    iconSize: 50,
                    // width: 210,
                    title: (isServiceProvider == true)
                        ? "${cart!.customer.phone}"
                        : "${cart!.service_provider.phone}",
                    icon: FontAwesomeIcons.whatsapp,
                  ),
                ),
                boxWidget(
                  height: 100,
                  TextAsLogo: "اجمالي المبلغ ",
                  TextAsLogoSize: 20,
                  title: "${cart!.total} SR",
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
                if (isServiceProvider == true && cart!.status == 2) ...[
                  InkWell(
                    onTap: isPaid == true ? () => _addOtpNumber(context) : null,
                    child: boxWidget(
                      height: 180,
                      width: double.infinity,
                      TextAsLogo: "اضغط هنا",
                      TextAsLogoSize: 30,
                      titleColor: Colors.red,
                      title:
                          "لحفظ مستحقاتكم الماليه، رجاءً اطلب من العميل تزويدكم بالكود المرسل اليه وادخاله هنا عند وصول الخدمة او الطلب للعميل",
                    ),
                  ),
                ],
                boxWidget(
                  height: 100,
                  width: double.infinity,
                  title: "حالة الخدمة",
                  TextAsLogo: (cart!.status == 2)
                      ? "تجهيز الطلب"
                      : (cart!.status == 3)
                          ? "تجهيز الطلب"
                          : (cart!.status == 4)
                              ? "تم إنجاز الخدمة"
                              : "لم تكتمل",
                  TextAsLogoSize: 20,
                ),
                if (isServiceProvider == true) ...[
                  if (cart!.status == 2) ...[
                    boxWidget(
                      TextAsLogo:
                          "الرجاء طلب اللوكيشن من العميل حتى تستطيعون توصيل  الطلب ليه عند تجهيزه",
                      TextAsLogoSize: 20,
                      width: double.infinity,
                      height: 120,
                      title: "لإكمال الخدمة",
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
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ...services,
              if (current_user != user?.id && user!.delivery_fee! > 0.0)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CheckboxListTile(
                    title: Text(
                      "التوصيل",
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "الرسوم: ${user?.delivery_fee} SAR",
                      style: TextStyle(
                          fontSize: 20,
                          color: const Color.fromARGB(255, 255, 254, 254)),
                    ),
                    value: hasDelivery,
                    onChanged: (cart != null && cart?.status != 1)
                        ? null
                        : (bool? newValue) {
                            setState(() {
                              hasDelivery = newValue ?? false;
                            });
                          },
                  ),
                ),
              if (current_user != user?.id && (isPaid != true)) ...[
                InkWell(
                  onTap: (dateTimeStamp != null && finalresults.length > 1)
                      ? () => _saveAndPayCart(true)
                      : null,
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Container(
                        decoration: BoxDecoration(
                          color:
                              (dateTimeStamp != null && finalresults.length > 1)
                                  ? Color.fromARGB(255, 240, 190, 174)
                                  : Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 70,
                        width: double.infinity,
                        child: H2Text(
                          text:
                              (dateTimeStamp != null && finalresults.length > 1)
                                  ? "حفظ بالسلة"
                                  : (dateTimeStamp == null)
                                      ? "للحفظ الرجاء اختيار الوقت"
                                      : "الرجاء اختيار خدمة",
                          aligment: 'center',
                          size: 20,
                          textColor: Colors.black,
                        )),
                  ),
                ),
                (dateTimeStamp != null && finalresults.length > 1)
                    ? InkWell(
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
                      )
                    : SizedBox.shrink()
              ],
              H2Text(
                  aligment: 'center',
                  lines: 3,
                  text:
                      "عزيزي العميل في حال واجهة اي اشكالية يرجى التواصل مع خدمة العملاء"),
              InkWell(
                onTap: () => {_openWhatsApp("966543049002")},
                child: boxWidget(
                  height: 100,
                  width: double.infinity,
                  iconSize: 50,
                  // width: 210,
                  title: "0543049002",
                  icon: FontAwesomeIcons.whatsapp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndPayCart(bool? OnlySaveAsCart) async {
    if (current_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'يجب تسجيل الدخول او التسجيل للاستفادة من كامل خدمات التطبيق')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    }
    Map<String, dynamic> result = await ApiConfig.updateCart(
        finalresults, cart, dateTimeStamp!, hasDelivery);
    try {
      // print(double.tryParse(result['data']['total']));
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
          "submitType": "update"
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

  String convertToInternationalFormat(String localNumber) {
    // إزالة أي مسافات إضافية
    localNumber = localNumber.replaceAll(' ', '');

    // التأكد أن الرقم يبدأ بـ 0
    if (localNumber.startsWith('0')) {
      // استبدال الصفر الأول بمفتاح الدولة (مثال: +966)
      return '+966' + localNumber.substring(1);
    }

    // إذا لم يبدأ الرقم بـ 0، يعاد كما هو
    return localNumber;
  }

  Future<void> _openWhatsApp(String localNumber) async {
    // تحويل الرقم المحلي إلى دولي
    String internationalNumber = convertToInternationalFormat(localNumber);
    final message = (isServiceProvider == true)
        ? "مرحبا انا ${cart!.service_provider.name} اتواصل معك من مكفي"
        : "مرحبا انا ${cart!.customer.name} اتواصل معك من مكفي";
    final Uri whatsappUri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: internationalNumber,
      queryParameters: {'text': message}, // النص الافتراضي
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      print('Could not launch WhatsApp');
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: phoneNumber, // تأكد من تنسيق الرقم
      );
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        print('Could not launch $phoneNumber');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('لا يمكن إجراء المكالمة على الرقم: $phoneNumber')),
        );
      }
    } catch (e) {
      print('Error launching phone call: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء محاولة إجراء المكالمة')),
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
                                // print(cart!.status);
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
                                      'تم تحويل الطلب إلى حالة تم الاكتمال بنجاح'),
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
