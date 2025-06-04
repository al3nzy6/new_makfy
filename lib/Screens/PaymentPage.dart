import 'package:flutter/material.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';
import 'package:moyasar/moyasar.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late int cart_id;
  late double price;
  bool isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is List && arguments.length >= 2) {
        cart_id = arguments[0];
        price = arguments[1];
      } else {
        print("Invalid arguments passed to PaymentPage.");
      }
      isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale: const Locale('en'),
      child: PaymentWidget(cart_id: cart_id, price: price),
    );
  }
}

class PaymentWidget extends StatefulWidget {
  final int cart_id;
  final double price;

  const PaymentWidget({
    Key? key,
    required this.cart_id,
    required this.price,
  }) : super(key: key);

  @override
  State<PaymentWidget> createState() => _PaymentWidgetState();
}

class _PaymentWidgetState extends State<PaymentWidget> {
  Future<PaymentConfig>? paymentConfigFuture;
  final GlobalKey applePayKey = GlobalKey();
  final GlobalKey creditCardKey = GlobalKey();
  bool isApplePayVisible = false;
  bool isCreditCardVisible = false;

  @override
  void initState() {
    super.initState();
    paymentConfigFuture = initializePaymentConfig();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showPaymentOptions();
    });
  }

  void showPaymentOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("اختر وسيلة الدفع لمبلغ ${widget.price} ريال سعودي"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone_iphone),
              title: const Text("Apple Pay"),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  isApplePayVisible = true;
                  isCreditCardVisible = false;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text("بطاقة ائتمان"),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  isCreditCardVisible = true;
                  isApplePayVisible = false;
                });
              },
            ),
            ListTile(
              leading: Image.asset('images/Tabby.png', width: 40),
              title: const Text("تابي"),
              onTap: () {
                Navigator.of(context).pop();
                initiateTabbyPayment();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> initiateTabbyPayment() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final String name = prefs.getString('user_name') ?? 'اسم غير معروف';
    final String email = prefs.getString('user_email') ?? 'test@example.com';
    final String phone = prefs.getString('user_phone') ?? '500000001';
    final String registeredAt = prefs.getString('user_registered_at') ?? '2020-01-01T00:00:00Z';
    final payment = Payment(
      amount: widget.price.toStringAsFixed(2),
      currency: Currency.sar,
      buyer: Buyer(
        email: email,
        phone: phone,
        name: name,
      ),
      buyerHistory: BuyerHistory(
        loyaltyLevel: 1,
        registeredSince: registeredAt,
        wishlistCount: 0,
      ),
      shippingAddress: const ShippingAddress(
        city: 'Riyadh',
        address: 'King Fahd Road',
        zip: '12345',
      ),
      order: Order(
        referenceId: 'order_${widget.cart_id}',
        items: [
          OrderItem(
            title: 'طلب #${widget.cart_id}',
            description: 'خدمة من مكفي',
            quantity: 1,
            unitPrice: widget.price.toStringAsFixed(2),
            referenceId: 'item_${widget.cart_id}',
            productUrl: 'https://makfy.sa/item/${widget.cart_id}',
            category: 'services',
          )
        ],
      ),
      orderHistory: [],
    );

    final session = await TabbySDK().createSession(
      TabbyCheckoutPayload(
        merchantCode: 'MKSAU',
        lang: Lang.ar,
        payment: payment,
      ),
    );

    if (session.status == SessionStatus.rejected) {
      final rejectionText = Lang.ar == Lang.ar
          ? TabbySDK.rejectionTextAr
          : TabbySDK.rejectionTextEn;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(rejectionText),
        ),
      );
      return;
    }
final webUrl = session.availableProducts.installments?.webUrl;
final paymentUUID = session.paymentId;
if (webUrl == null) {
  showToast(context, "لا يوجد رابط دفع متاح من Tabby.");
  return;
}
await Future.delayed(Duration(milliseconds: 200)); // delay بسيط

TabbyWebView.showWebView(
  context: context,
  webUrl: webUrl,
  onResult: (WebViewResult resultCode) {
    switch (resultCode) {
      case WebViewResult.authorized:
        showToast(context, "تمت الموافقة على العملية");
        checkPayment(paymentUUID);
        break;
      case WebViewResult.close:
        showToast(context, "تم إغلاق نافذة الدفع");
        break;
      case WebViewResult.expired:
        showToast(context, "انتهت صلاحية الجلسة");
        break;
      case WebViewResult.rejected:
        showToast(context, "تم رفض العملية من Tabby");
        break;
    }
  },
);
  } catch (e) {
    print("خطأ أثناء بدء جلسة Tabby: $e");
    showToast(context, "تعذر بدء عملية الدفع عبر تابي.");
  }
}


  Future<PaymentConfig> initializePaymentConfig() async {
    if (widget.price <= 0) {
      throw Exception("Price must be greater than 0.");
    }
    return PaymentConfig(
      // publishableApiKey: 'pk_test_sJyfiRuo4P9VDRqoMcB9TEwm5tBcg6GjWL1PrqWw',
      publishableApiKey: 'pk_live_rxvsa8sxcFa6ujt7Ghqv8NnyMwgB4kd2E83eUVco',
      amount: (widget.price * 100).round(),
      description: 'order #${widget.cart_id}',
      metadata: {
        'cart_id': widget.cart_id,
        'time_zone': 3,
      },
      creditCard: CreditCardConfig(saveCard: false, manual: false),
      applePay: ApplePayConfig(
        merchantId: 'merchant.sa.makfy',
        label: 'Payment for Makfy A-Z',
        manual: false,
      ),
    );
  }

  void onPaymentResult(result) {
    if (result is PaymentResponse) {
      switch (result.status) {
        case PaymentStatus.paid:
          showToast(context, "حالة الفاتورة: تم الدفع");
          print("Payment successful. ID: ${result.id}");
          checkPayment(result.id);
          break;
        case PaymentStatus.failed:
          showToast(context, "فشلت عملية الدفع");
          break;
        case PaymentStatus.authorized:
          showToast(context, "تم تفويض الدفع، بانتظار التأكيد");
          break;
        default:
          showToast(context, "حالة دفع غير معروفة");
      }
      return;
    }

    if (result is ApiError) {
      showToast(context, "API Error occurred.");
    } else if (result is AuthError) {
      showToast(context, "Authorization error.");
    } else if (result is ValidationError) {
      showToast(context, "Validation error.");
    } else if (result is PaymentCanceledError) {
      showToast(context, "تم إلغاء الدفع");
    } else if (result is UnprocessableTokenError) {
      showToast(context, "Token error occurred.");
    } else if (result is TimeoutError) {
      showToast(context, "انتهت المهلة");
    } else if (result is NetworkError) {
      showToast(context, "خطأ في الاتصال");
    } else if (result is UnspecifiedError) {
      showToast(context, "حدث خطأ غير محدد");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PaymentConfig>(
      future: paymentConfigFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text("فشل تحميل إعدادات الدفع"));
        }

        final paymentConfig = snapshot.data!;

        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true,
          body: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: ListView(
                children: [
                  Image.asset(
                    'images/logo.png',
                    height: 170,
                  ),
                  if (isApplePayVisible)
                    ApplePay(
                      key: applePayKey,
                      config: paymentConfig,
                      onPaymentResult: onPaymentResult,
                    ),
                  const SizedBox(height: 10),
                  if (isCreditCardVisible)
                    CreditCard(
                      key: creditCardKey,
                      locale: const Localization.en(),
                      config: paymentConfig,
                      onPaymentResult: onPaymentResult,
                    ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context); // يرجع للصفحة السابقة
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0XFFEF5B2C),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 50,
                      child: const Text(
                        "إلغاء عملية الدفع",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> checkPayment(String uuid) async {
    try {
      Map<String, dynamic> result = await ApiConfig.checkPaymentID(uuid);
      if (result['data']['message'] == 'success') {
        Navigator.pushReplacementNamed(context, '/my_orders');
      }
    } catch (e) {
      print("Error in payment verification: $e");
      showToast(context, "خطأ أثناء التحقق من الدفع");
    }
  }
}

void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 18),
      ),
    ),
  );
}
