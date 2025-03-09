import 'package:flutter/material.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';
import 'package:moyasar/moyasar.dart';

class PaymentPage extends StatefulWidget {
  PaymentPage({Key? key}) : super(key: key);

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
      locale: const Locale('en'), // تحديد اللغة الإنجليزية فقط لهذه الصفحة
      child: PaymentWidget(cart_id: cart_id, price: price),
    );
  }
}

class PaymentWidget extends StatefulWidget {
  final int cart_id;
  final double price;

  PaymentWidget({
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
  bool isApplePayVisible = true;
  bool isCreditCardVisible = true;

  @override
  void initState() {
    super.initState();
    paymentConfigFuture = initializePaymentConfig();
  }

  Future<PaymentConfig> initializePaymentConfig() async {
    try {
      if (widget.price <= 0) {
        throw Exception("Price must be greater than 0.");
      }
      return PaymentConfig(
        publishableApiKey: 'pk_live_rxvsa8sxcFa6ujt7Ghqv8NnyMwgB4kd2E83eUVco',
        amount: (widget.price * 100).toInt(), // تحويل المبلغ إلى هللات
        description: 'order #${widget.cart_id}',
        metadata: {
          'cart_id': widget.cart_id,
          'time_zone': 3,
        },
        creditCard: CreditCardConfig(saveCard: false, manual: false),
        applePay: ApplePayConfig(
          merchantId: 'merchant.sa.edu.njd',
          label: 'Moyaser Payment for Makfy',
          manual: false,
        ),
      );
    } catch (e, stacktrace) {
      print("Error initializing PaymentConfig: $e");
      print("Stacktrace: $stacktrace");
      throw Exception("Failed to initialize payment config: $e");
    }
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
          print("Payment failed.");
          break;
        case PaymentStatus.authorized:
          print("Payment authorized, awaiting capture.");
          break;
        default:
          print("Unknown payment status.");
      }
      return;
    }

    // handle various errors
    if (result is ApiError) {
      print("API Error occurred.");
      showToast(context, "API Error occurred.");
    } else if (result is AuthError) {
      print("Authorization error.");
      showToast(context, "Authorization error.");
    } else if (result is ValidationError) {
      print("Validation error.");
      showToast(context, "Validation error.");
    } else if (result is PaymentCanceledError) {
      print("Payment was canceled.");
      showToast(context, "Payment was canceled.");
    } else if (result is UnprocessableTokenError) {
      print("Token error occurred.");
      showToast(context, "Token error occurred.");
    } else if (result is TimeoutError) {
      print("Timeout error occurred.");
      showToast(context, "Timeout error occurred.");
    } else if (result is NetworkError) {
      print("Network error occurred.");
      showToast(context, "Network error occurred.");
    } else if (result is UnspecifiedError) {
      print("An unspecified error occurred.");
      showToast(context, "An unspecified error occurred.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PaymentConfig>(
      future: paymentConfigFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData) {
          return Center(child: Text("Failed to initialize payment config"));
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
                    'images/logo.png', // تأكد من وجود الصورة في assets
                    height: 300,
                  ),
                  Offstage(
                    offstage: !isApplePayVisible,
                    child: ApplePay(
                      key: applePayKey, // استخدام GlobalKey لمنع إعادة الإنشاء
                      config: paymentConfig,
                      onPaymentResult: onPaymentResult,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 10),
                  const SizedBox(height: 20),
                  Offstage(
                    offstage: !isCreditCardVisible,
                    child: CreditCard(
                      key:
                          creditCardKey, // استخدام GlobalKey لمنع إعادة الإنشاء
                      locale: const Localization.en(),
                      config: paymentConfig,
                      onPaymentResult: onPaymentResult,
                    ),
                  ),
                  const SizedBox(height: 30),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0XFFEF5B2C),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 50,
                        width: double.infinity,
                        child: const Text(
                          "إلغاء عملية الدفع",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 30, color: Colors.white),
                        ),
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
        print('Invoice has been paid');
        Navigator.pushReplacementNamed(context, '/my_orders');
      }
    } catch (e) {
      print("Error in payment verification: $e");
      showToast(context, "Error verifying payment");
    }
  }
}

void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 20),
      ),
    ),
  );
}
