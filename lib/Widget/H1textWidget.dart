import 'package:flutter/material.dart';

class H1text extends StatelessWidget {
  String text;
  Color? textColor;
  double? size;
  H1text({
    super.key,
    required this.text,
    this.size,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: (size != null) ? size : 25,
          color: textColor ?? Colors.black,
        ),
      ),
    );
  }
}
