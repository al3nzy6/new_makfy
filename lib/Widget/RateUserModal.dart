import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';

class RateUserModal extends StatefulWidget {
  final int cart;
  RateUserModal({required this.cart});

  @override
  _RateUserModalState createState() => _RateUserModalState();
}

class _RateUserModalState extends State<RateUserModal> {
  double _currentRating = 0.0;

  Future<void> _submitRating(BuildContext context) async {
    if (_currentRating > 0) {
      try {
        await RatingService.rateUser(widget.cart, _currentRating);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("تم إرسال التقييم")),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("تعذر ارسال التقيم")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("الرجاء اضافة التقيم قبل الارسال")),
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
          Text("قيم موفر الخدمة", style: TextStyle(fontSize: 24)),
          Divider(),
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
            child: Text("إرسال التقيم"),
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
  static Future<void> rateUser(int cart, double rating) async {
    // Simulate an API call
    Map<String, dynamic> data = await ApiConfig.rate(cart, rating);
    // await Future.delayed(Duration(seconds: 1));
  }
}
