import 'package:flutter/material.dart';

class H1text extends StatelessWidget {
  String text;
  H1text({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 25,
        ),
      ),
    );
  }
}
