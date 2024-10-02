import 'package:flutter/material.dart';
import 'package:makfy_new/Widget/H2Text.dart';
import 'package:makfy_new/Widget/RatingWidget.dart';
import 'dart:math' as math; // Import math for the min function

class Myorderservice extends StatelessWidget {
  final String title;
  final String date;
  final String time;
  final List<String>? fields;
  final String serviceProvider;
  final double price;
  final int type;
  final int order_number;
  final int id;
  Myorderservice({
    required this.title,
    required this.date,
    required this.time,
    this.fields,
    required this.serviceProvider,
    required this.price,
    required this.type,
    required this.order_number,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 7,
            offset: Offset(0, 3),
          )
        ],
      ),
      height: math.max(130, screenWidth * 0.13),
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
                Row(
                  children: [
                    if (fields != null)
                      Padding(
                        padding: EdgeInsets.only(top: 8, left: 10, right: 10),
                        child: Text(
                          fields!.join(' '),
                          style: TextStyle(
                            color: Color(0XFFEF5B2C),
                          ),
                        ),
                      ),
                    Text(date),
                    SizedBox(
                      width: 20,
                    ),
                    Text(time),
                  ],
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
                    if (type != 3)
                      Container(
                        margin: EdgeInsets.only(top: 3, right: 6, left: 6),
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: H2Text(
                          text: "تواصل",
                          textColor: Colors.white,
                          size: 13,
                        ),
                      ),
                    Container(
                      margin: EdgeInsets.only(top: 2, right: 2, left: 2),
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: (type == 1)
                            ? Colors.blue
                            : (type == 2)
                                ? Colors.green
                                : Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: H2Text(
                        text: (type == 1)
                            ? "رمز بداية الخدمة"
                            : (type == 2)
                                ? "قيد التنفيذ"
                                : "قيم الخدمة",
                        textColor: Colors.white,
                        size: 15,
                      ),
                    ),
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
                  // color: Colors.black,
                  height: math.min(110, screenHeight * 0.13),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        '$price SAR',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0XFFEF5B2C),
                        ),
                      ),
                      Text(
                        '#$order_number',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0XFFEF5B2C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
