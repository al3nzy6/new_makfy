import 'package:flutter/material.dart';
import 'package:makfy_new/Models/Cart.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';
import 'package:makfy_new/Widget/H1textWidget.dart';
import 'package:makfy_new/Widget/H2Text.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';
import 'package:makfy_new/Widget/ShadowBoxWidget.dart';

import 'package:makfy_new/Widget/appHeadWidget.dart';
import 'package:makfy_new/Widget/serviceProviderWidget.dart';

class ShoppingCertPage extends StatefulWidget {
  ShoppingCertPage({Key? key});

  @override
  State<ShoppingCertPage> createState() => _ShoppingCertPageState();
}

class _ShoppingCertPageState extends State<ShoppingCertPage> {
  late int id;
  late String name;
  bool isLoading = true;
  bool isPaidCart = false;
  bool isServiceProviderCart = false;
  List<Widget> cartsWidget = [];
  double totalSum = 0.0; // متغير لتخزين المجموع
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // استلام البيانات الممررة من خلال ModalRoute
    final arguments = ModalRoute.of(context)?.settings.arguments;
    isLoading = false;
    isPaidCart =
        (ModalRoute.of(context)?.settings.name == '/my_orders') ? true : false;
    isServiceProviderCart =
        (ModalRoute.of(context)?.settings.name == '/customer_orders')
            ? true
            : false;
    _getCustomerCarts();
  }

  Future<void> _getCustomerCarts() async {
    List<Cart> carts = (isPaidCart)
        ? await ApiConfig.customerPaidCartList()
        : (isServiceProviderCart)
            ? await ApiConfig.serviceProviderCartList()
            : await ApiConfig.customerCartList();
    try {
      setState(() {
        totalSum = 0.0; // Reset totalSum before calculating
        cartsWidget = carts?.map((cart) {
              // Convert the cart total to double, handle if it's a valid number
              double cartTotal = cart.total;
              totalSum += cartTotal;
              return serviceProviderWidget(
                title: (isServiceProviderCart)
                    ? cart.customer.name
                    : cart.service_provider.name,
                id: cart.service_provider.id,
                averageRating: cart.service_provider.averageRating,
                countRating: cart.service_provider.countRating,
                total: cart.total,
                servicesCount: cart.services?.length,
                cart: cart,
              );
            }).toList() ??
            [];
        isLoading = false;
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Widget build(BuildContext context) {
    return MainScreenWidget(
      isLoading: isLoading,
      start: Wrap(
        spacing: 10,
        runSpacing: 15,
        children: [
          H1text(text: (isPaidCart) ? "الطلبات" : "سلة الخدمات"),
          SizedBox(
            height: 10,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  height: 100,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.blue,
                  ),
                  child: Column(
                    children: [
                      H2Text(
                        text: "لديك",
                        textColor: Colors.white,
                        size: 20,
                      ),
                      H2Text(
                        text: "${cartsWidget.length}",
                        textColor: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  height: 100,
                  width: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.blue,
                  ),
                  child: Column(
                    children: [
                      H2Text(
                        text: "المجموع",
                        textColor: Colors.white,
                        size: 20,
                      ),
                      H2Text(
                        text: "${totalSum.toStringAsFixed(2)} ريال",
                        textColor: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ]),
          ...cartsWidget,
        ],
      ),
    );
  }
}
