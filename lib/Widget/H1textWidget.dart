import 'package:flutter/material.dart';

class H1text extends StatelessWidget {
  String text;
  Color? textColor;
  H1text({
    super.key,
    required this.text,
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
          fontSize: 25,
          color: textColor ?? Colors.black,
        ),
      ),
    );
  }
}
