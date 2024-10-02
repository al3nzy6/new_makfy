import 'package:flutter/material.dart';
import 'package:makfy_new/Widget/H2Text.dart';
import 'package:makfy_new/Widget/RatingWidget.dart';
import 'package:makfy_new/Widget/ShadowBoxWidget.dart';

class ServiceAddedWidget extends StatelessWidget {
  final String title;
  final List<String>? fields;
  final String serviceProvider;
  final String price;
  final int id;
  final String? date;
  final String? time;

  ServiceAddedWidget({
    required this.title,
    this.fields,
    required this.serviceProvider,
    required this.price,
    required this.id,
    this.date,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {
        Navigator.pushNamed(context, '/service_page',
            arguments: [id, date ?? null, time ?? null])
      },
      child: ShadowBoxWidget(
        height: 130,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: 320,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  H2Text(text: title, size: 20),
                  if (fields != null)
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 8, left: 10, right: 10),
                      child: Text(
                        fields!.join(' '),
                        style: TextStyle(
                          color: Color(0XFFEF5B2C),
                        ),
                      ),
                    ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 3, right: 6, left: 6),
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Color(0XFF65558F),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: H2Text(
                          text: serviceProvider,
                          textColor: Colors.white,
                          size: 17,
                        ),
                      ),
                      RatingWidget(stars: 2, ratingCount: "3K"),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
                    child: Text(
                      '$price',
                      style: const TextStyle(
                        fontSize: 19,
                        color: Color(0XFFEF5B2C),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 60,
                    color: Color(0XFFEF5B2C),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
