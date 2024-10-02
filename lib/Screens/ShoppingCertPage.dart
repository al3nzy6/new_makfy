import 'package:flutter/material.dart';
import 'package:makfy_new/Widget/H1textWidget.dart';
import 'package:makfy_new/Widget/H2Text.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';
import 'package:makfy_new/Widget/ShadowBoxWidget.dart';

import 'package:makfy_new/Widget/appHeadWidget.dart';

class ShoppingCertPage extends StatefulWidget {
  ShoppingCertPage({Key? key});

  @override
  State<ShoppingCertPage> createState() => _ShoppingCertPageState();
}

class _ShoppingCertPageState extends State<ShoppingCertPage> {
  late int id;
  late String name;
  bool isLoading = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // استلام البيانات الممررة من خلال ModalRoute
    final arguments = ModalRoute.of(context)?.settings.arguments;
    isLoading = false;
  }

  Widget build(BuildContext context) {
    return MainScreenWidget(
        isLoading: isLoading,
        start: Wrap(
          spacing: 10,
          runSpacing: 15,
          children: [
            H1text(text: "سلة الخدمات"),
            SizedBox(
              height: 50,
            ),
            _serviceProviders()
          ],
        ));
  }

  Widget _serviceProviders() {
    return Wrap(
      spacing: 10,
      runSpacing: 15,
      children: [
        ShadowBoxWidget(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              H2Text(text: 'sdf'),
              H2Text(text: 'sdf'),
            ],
          ),
        ),
        ShadowBoxWidget(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              H2Text(text: 'sdf'),
              H2Text(text: 'sdf'),
            ],
          ),
        ),
        ShadowBoxWidget(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              H2Text(text: 'sdf'),
              H2Text(text: 'sdf'),
            ],
          ),
        ),
        ShadowBoxWidget(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              H2Text(text: 'sdf'),
              H2Text(text: 'sdf'),
            ],
          ),
        ),
        ShadowBoxWidget(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              H2Text(text: 'مرحبا'),
              H2Text(text: 'مرحبا'),
            ],
          ),
        ),
        ShadowBoxWidget(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              H2Text(text: 'sdf'),
              H2Text(text: 'sdf'),
            ],
          ),
        ),
      ],
    );
  }
}
