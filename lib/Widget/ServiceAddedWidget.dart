import 'package:flutter/material.dart';
import 'package:makfy_new/Models/User.dart';
import 'package:makfy_new/Widget/H2Text.dart';
import 'package:makfy_new/Widget/ShadowBoxWidget.dart';

class ServiceAddedWidget extends StatefulWidget {
  final String title;
  final List<String>? fields;
  final String serviceProvider;
  final String price;
  final int id;
  final String? date;
  final String? time;
  final bool? currentUserIsTheProvider;
  int? count;
  bool? isPaid;
  final Function(dynamic)? onChanged;

  ServiceAddedWidget(
      {required this.title,
      this.fields,
      required this.serviceProvider,
      required this.price,
      required this.id,
      this.date,
      this.time,
      this.isPaid,
      this.count = 0, // تأكيد أن count يبدأ بـ 0
      this.onChanged,
      this.currentUserIsTheProvider});

  @override
  State<ServiceAddedWidget> createState() => _ServiceAddedWidgetState();
}

class _ServiceAddedWidgetState extends State<ServiceAddedWidget> {
  @override
  Widget build(BuildContext context) {
    return ShadowBoxWidget(
      height: (widget.currentUserIsTheProvider != null &&
              widget.currentUserIsTheProvider == false)
          ? 140
          : (widget.isPaid != null && widget.isPaid == true)
              ? 140
              : 90,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/service_page', arguments: [
                widget.id,
                widget.date ?? null,
                widget.time ?? null
              ]);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    // width: double.infinity ,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // استخدام FittedBox لضبط النص داخل الشاشة وتجنب الخروج
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1, // يمنع النص من التوسع لأكثر من سطر
                        ),
                        if (widget.fields != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Text(
                              widget.fields!.join(' '),
                              style: TextStyle(
                                color: Color(0XFFEF5B2C),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${widget.price}',
                    style: const TextStyle(
                      fontSize: 19,
                      color: Color(0XFFEF5B2C),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.currentUserIsTheProvider != true ||
              widget.isPaid == true) ...[
            const Divider(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (widget.isPaid == null || widget.isPaid == false) ...[
                  InkWell(
                    onTap: () {
                      setState(() {
                        (widget.count != null)
                            ? widget.count = widget.count! + 1
                            : widget.count = 1;
                        widget.onChanged?.call(widget.count);
                      });
                    },
                    child: Icon(
                      Icons.add,
                      size: 40,
                      color: Color(0XFFEF5B2C),
                    ),
                  ),
                ],
                Container(
                  width: 100,
                  color: Color(0XFFEF5B2C),
                  child: Center(
                    child: Text(
                      "${widget.count}", // عرض قيمة count
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (widget.isPaid == null || widget.isPaid == false) ...[
                  InkWell(
                    onTap: () {
                      setState(() {
                        (widget.count != null && widget.count != 0)
                            ? widget.count = widget.count! - 1
                            : widget.count = 0;
                        widget.onChanged?.call(widget.count);
                      });
                    },
                    child: Icon(
                      Icons.remove,
                      size: 40,
                      color: Color(0XFFEF5B2C),
                    ),
                  ),
                ],
              ],
            )
          ],
        ],
      ),
    );
  }
}
