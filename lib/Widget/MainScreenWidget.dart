import 'package:flutter/material.dart';
import 'package:redacted/redacted.dart';

import 'package:makfy_new/Widget/appHeadWidget.dart';

class MainScreenWidget extends StatefulWidget {
  late Widget start;
  bool isLoading = true;
  final Future<void> Function()? onRefresh;
  final Widget? floatingFunction;
  final List? bodyData;
  final List? routeArguments;
  MainScreenWidget({
    Key? key,
    required this.start,
    required this.isLoading,
    this.onRefresh,
    this.floatingFunction,
    this.bodyData,
    this.routeArguments,
  }) : super(key: key);

  @override
  State<MainScreenWidget> createState() => _MainScreenWidgetState();
}

class _MainScreenWidgetState extends State<MainScreenWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0XFFEF5B2C),
        floatingActionButton:
            widget.floatingFunction != null ? widget.floatingFunction : null,
        body: SafeArea(
          bottom: false,
          child: (widget.onRefresh != null)
              ? RefreshIndicator(
                  onRefresh: widget.onRefresh!,
                  child: _body(
                    start: widget.start,
                    isLoading: widget.isLoading,
                  ),
                )
              : _body(
                  start: widget.start,
                  isLoading: widget.isLoading,
                  routeArguments: widget.routeArguments,
                ),
        ));
  }
}

class _body extends StatefulWidget {
  Widget start;
  bool isLoading = true;
  List? routeArguments;
  _body({
    Key? key,
    required this.start,
    required this.isLoading,
    this.routeArguments,
  }) : super(key: key);

  @override
  State<_body> createState() => __bodyState();
}

class __bodyState extends State<_body> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 20),
      // margin: const EdgeInsets.only(top: 55),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(40)),
      ),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(
              top: 10,
              left: 15,
              right: 10,
            ),
            child: appHeadWidget(
              routeArguments: widget.routeArguments,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                right: 10,
                left: 10,
                bottom: 20,
              ),
              child: (widget.isLoading ?? true)
                  ? Center(
                      child: Container(
                      height: 100,
                      width: 100,
                      child: CircularProgressIndicator(
                        color: Color(0XFFEF5B2C),
                      ),
                    ))
                  : widget.start,
            ),
          ),
          // here Add your page
        ],
      ),
    );
  }
}
