import 'package:flutter/material.dart';

import 'package:makfy_new/Widget/H2Text.dart';
import 'dart:math' as math; // Import math for the min function

class boxWidget extends StatelessWidget {
  Color? color;
  String title;
  IconData? icon;
  String? image;
  Color? titleColor;
  String? route;
  List<dynamic>? data;
  String? TextAsLogo;
  double? TextAsLogoSize;
  double? width;
  double? height;
  double? iconSize;
  boxWidget({
    Key? key,
    this.color,
    required this.title,
    this.icon,
    this.image,
    this.titleColor,
    this.route,
    this.data,
    this.width,
    this.height,
    this.iconSize,
    this.TextAsLogo,
    this.TextAsLogoSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: (height == null) ? math.min(135, screenHeight * 0.20) : height,
      width: (width == null) ? math.min(190, screenWidth * 0.4) : width,
      decoration: BoxDecoration(
        // color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0XFFEF5B2C).withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: (route != null)
            ? () {
                if (data == null) {
                  Navigator.pushNamed(context, route ?? "");
                } else {
                  Navigator.pushNamed(context, route ?? "", arguments: data);
                }
              }
            : null,
        child: Column(
          children: [
            (icon != null)
                ? Container(
                    margin: EdgeInsets.only(top: 8),
                    child: Icon(
                      icon,
                      size: (iconSize == null) ? screenWidth * 0.15 : iconSize,
                      color: Color(0XFFEF5B2C),
                    ),
                  ) // عرض الأيقونة إذا كانت غير null
                : (image != null)
                    ? Image.asset(
                        image ?? 'images/logo.png',
                        height: screenWidth * 0.20,
                      ) // عرض الصورة إذا كانت غير null
                    : (TextAsLogo != null)
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 10),
                            child: Text(
                              TextAsLogo ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: TextAsLogoSize ?? 50,
                              ),
                            ),
                          )
                        : Image.asset(
                            'images/logo.png',
                            height: screenWidth * 0.20,
                          ),
            H2Text(
              text: title,
              textColor: titleColor,
              lines: 5,
            ),
          ],
        ),
      ),
    );
  }
}
