import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:makfy_new/Widget/RateUserModal.dart';

class RatingWidget extends StatelessWidget {
  final int stars;
  final String ratingCount;
  final int userId;
  final bool? isRatingPage;

  RatingWidget({
    required this.stars,
    required this.ratingCount,
    required this.userId,
    this.isRatingPage,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> starIcons = List.generate(5, (i) {
      return Icon(
        i < stars ? Icons.star : Icons.star_border,
        size: 21,
        color: Color(0XFFEF5B2C),
      );
    });

    return InkWell(
      child: Row(
        children: [
          ...starIcons,
          SizedBox(width: 4),
          Text(
            "(${ratingCount})",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
