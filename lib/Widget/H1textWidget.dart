import 'package:flutter/material.dart';

class H1text extends StatelessWidget {
  String text;
  Color? textColor;
  double? size;
  int? maxWords;
  int? maxLines = 1;
  H1text(
      {super.key,
      required this.text,
      this.size,
      this.textColor,
      this.maxLines,
      this.maxWords});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        (maxWords != null) ? limitWords(text, maxWords ?? 1) : text,
        maxLines: maxLines,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: (size != null) ? size : 25,
          color: textColor ?? Colors.black,
        ),
      ),
    );
  }

  String limitWords(String text, int maxWords) {
    List<String> words = text.split(' ');
    if (words.length > maxWords) {
      return words.sublist(0, maxWords).join(' ') + '...';
    }
    return text;
  }
}
