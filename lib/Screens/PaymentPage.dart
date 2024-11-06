import 'package:flutter/material.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';
import 'package:moyasar/moyasar.dart';

import 'package:makfy_new/Widget/MainScreenWidget.dart';

class PaymentPage extends StatefulWidget {
  PaymentPage({
    Key? key,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late int cart_id;
  late double price;
  bool isLoading = false;
  bool isInitialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is List) {
        cart_id = arguments[0];
        price = arguments[1];
      }
      isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale:
          const Locale('en', 'US'), // تحديد اللغة الإنجليزية فقط لهذه الصفحة
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

  @override
  void initState() {
    super.initState();
    paymentConfigFuture = initializePaymentConfig();
  }

  Future<PaymentConfig> initializePaymentConfig() async {
    try {
      return PaymentConfig(
        publishableApiKey: 'pk_test_awoFqrQ77zViZGzvo1NiH7cjiGffpVN7Dx4TfzMQ',
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
    } catch (e) {
      print("Error initializing PaymentConfig: $e");
      throw Exception("Failed to initialize payment config: $e");
    }
  }

  void onPaymentResult(result) {
    if (result is PaymentResponse) {
      showToast(context, result.status.name);
      switch (result.status) {
        case PaymentStatus.paid:
          print(result.id);
          checkPayment(result.id);
          break;
        case PaymentStatus.failed:
          // handle failure.
          break;
        case PaymentStatus.authorized:
          // handle authorized.
          break;
        default:
      }
      return;
    }

    // handle failures.
    if (result is ApiError) {}
    if (result is AuthError) {}
    if (result is ValidationError) {}
    if (result is PaymentCanceledError) {}
    if (result is UnprocessableTokenError) {}
    if (result is TimeoutError) {}
    if (result is NetworkError) {}
    if (result is UnspecifiedError) {}
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PaymentConfig>(
      future: paymentConfigFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
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
                  ApplePay(
                    config: paymentConfig,
                    onPaymentResult: onPaymentResult,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Divider(
                    height: 10,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CreditCard(
                    config: paymentConfig,
                    onPaymentResult: onPaymentResult,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0XFFEF5B2C),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 50,
                        width: double.infinity,
                        child: Text(
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

  Future<void> checkPayment(uuid) async {
    Map<String, dynamic> result = await ApiConfig.checkPaymentID(uuid);
    try {
      if (result['data']['message'] == 'success') {
        print('invoice Has been paid');
        Navigator.pushReplacementNamed(context, '/my_orders');
      }
    } catch (e) {
      print("Error in payment verification: $e");
    }
  }
}

void showToast(BuildContext context, String status) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        "حالة الفاتورة: تم دفعها",
        style: const TextStyle(fontSize: 20),
      ),
    ),
  );
}
