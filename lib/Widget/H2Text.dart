import 'package:flutter/material.dart';

class H2Text extends StatelessWidget {
  final String text;
  final Color? textColor;
  final double? size;
  final int? lines;
  final String? aligment;

  H2Text(
      {required this.text,
      this.textColor,
      this.size,
      this.lines,
      this.aligment});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: (aligment == "center") ? Alignment.center : null,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(top: 2, right: 2, left: 2),
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
