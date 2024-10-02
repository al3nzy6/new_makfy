import 'package:flutter/material.dart';

class H2Text extends StatelessWidget {
  final String text;
  final Color? textColor;
  final double? size;
  final int? lines;

  H2Text({required this.text, this.textColor, this.size, this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, right: 10, left: 10),
      child: Text(
        text,
        maxLines: (lines != null) ? lines : 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textColor ?? Colors.black,
          fontSize: size ?? 15,
          fontWeight: FontWeight.w200,
        ),
      ),
    );
  }
}
