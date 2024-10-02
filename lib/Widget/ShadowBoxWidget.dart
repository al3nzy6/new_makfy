import 'package:flutter/material.dart';

class ShadowBoxWidget extends StatelessWidget {
  double? height;
  double? width;
  Widget child;
  ShadowBoxWidget({
    Key? key,
    this.height,
    this.width,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(0),
      child: Container(
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
        height: height ?? 130,
        child: child,
      ),
    );
  }
}
