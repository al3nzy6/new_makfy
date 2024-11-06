import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingWidget extends StatelessWidget {
  final int stars;
  final String ratingCount;
  final int userId;

  RatingWidget({
    required this.stars,
    required this.ratingCount,
    required this.userId,
  });

  void _openRatingModal(BuildContext context) {
    // تحقق من إذا كان المستخدم في صفحة "cartShow"
    if (ModalRoute.of(context)?.settings.name == 'cartShow') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return RateUserModal(userId: userId);
        },
      );
    } else {
      // لا تقم بأي شيء أو أظهر رسالة فارغة
      // يمكنك فقط تجاهل النقرات في الصفحات الأخرى.
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isCartShowPage = ModalRoute.of(context)?.settings.name == 'cartShow';

    List<Widget> starIcons = [];
    for (int i = 0; i < 5; i++) {
      starIcons.add(
        Icon(
          i < stars ? Icons.star : Icons.star_border,
          size: 21,
          color: Color(0XFFEF5B2C),
        ),
      );
    }

    return InkWell(
      onTap: isCartShowPage ? () => _openRatingModal(context) : null,
      child: Row(
        children: [
          ...starIcons,
          SizedBox(width: 4),
          Text(
            "(${ratingCount})",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          if (isCartShowPage)
            Icon(
              Icons.edit,
              size: 18,
              color: Colors.grey,
            ), // يظهر القلم فقط في صفحة cartShow
        ],
      ),
    );
  }
}

class RateUserModal extends StatefulWidget {
  final int userId;
  RateUserModal({required this.userId});

  @override
  _RateUserModalState createState() => _RateUserModalState();
}

class _RateUserModalState extends State<RateUserModal> {
  double _currentRating = 0.0;

  Future<void> _submitRating(BuildContext context) async {
    try {
      await RatingService.rateUser(widget.userId, _currentRating);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Rating submitted successfully")),
      );
      Navigator.pop(context); // إغلاق المودال بعد الإرسال
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit rating")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Rate this user", style: TextStyle(fontSize: 24)),
          RatingBar.builder(
            initialRating: _currentRating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _currentRating = rating;
              });
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _submitRating(context),
            child: Text("Submit Rating"),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              textStyle: TextStyle(fontSize: 16),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class RatingService {
  static Future<void> rateUser(int userId, double rating) async {
    // Simulate an API call
    await Future.delayed(Duration(seconds: 1));
  }
}
