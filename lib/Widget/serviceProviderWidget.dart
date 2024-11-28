import 'package:flutter/material.dart';
import 'package:makfy_new/Models/Cart.dart';
import 'package:makfy_new/Models/Service.dart';
import 'package:makfy_new/Widget/H1textWidget.dart';
import 'package:makfy_new/Widget/H2Text.dart';
import 'package:makfy_new/Widget/RatingWidget.dart';
import 'package:makfy_new/Widget/ShadowBoxWidget.dart';

class serviceProviderWidget extends StatelessWidget {
  final String title;
  final int id;
  final String? date;
  final int? averageRating;
  final String? countRating;
  final double? total;
  final int? servicesCount;
  final String? time;
  final Cart? cart;

  serviceProviderWidget({
    required this.title,
    required this.id,
    this.averageRating = 0,
    this.countRating = "0",
    this.date,
    this.time,
    this.total,
    this.servicesCount,
    this.cart,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {
        Navigator.pushNamed(context, '/user_page', arguments: {
          "id": id,
          "title": title,
          "cart": cart ?? null,
          "date": date ?? null,
          "time": time ?? null
        })
      },
      child: ShadowBoxWidget(
        height: (total == null) ? 45 : 120,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: H1text(
                    text: title,
                    size: 20,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: RatingWidget(
                    stars: averageRating ?? 0,
                    ratingCount: countRating ?? "0",
                    userId: id,
                  ),
                ),
              ],
            ),
            if (total != null)
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Column(
                  children: [
                    H2Text(text: 'الخدمات'),
                    Text("${servicesCount ?? 0}"),
                  ],
                ),
                Column(
                  children: [
                    H2Text(text: 'اجمالي القيمة'),
                    Text("${total ?? 0} SAR"),
                  ],
                )
              ])
          ],
        ),
      ),
    );
  }
}
