import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final int stars;
  final String ratingCount;

  RatingWidget({required this.stars, required this.ratingCount});

  @override
  Widget build(BuildContext context) {
    List<Widget> starIcons = [];
    for (int i = 0; i < 5; i++) {
      starIcons.add(
        Icon(
          i < stars ? Icons.star : Icons.star_border,
          size: 18,
          color: Color(0XFFEF5B2C),
        ),
      );
    }

    return Row(
      children: [
        ...starIcons,
        Text(ratingCount),
      ],
    );
  }
}
