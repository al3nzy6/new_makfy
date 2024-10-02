import 'package:flutter/material.dart';

class appHeadWidget extends StatelessWidget {
  final List? routeArguments;
  appHeadWidget({
    Key? key,
    this.routeArguments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
        color: Colors.black.withOpacity(0.1),
        width: 1,
      ))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Text("${ModalRoute.of(context)?.settings.name}"),
          Image.asset(
            'images/logo.png',
            height: 100,
          ),
          (ModalRoute.of(context)?.settings.name != '/login')
              ? InkWell(
                  onTap: () {
                    if (ModalRoute.of(context)?.settings.name == '/home') {
                      Navigator.pushNamed(context, '/profile');
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: Color(0XFFEF5B2C), shape: BoxShape.circle),
                    child: Center(
                        child: Icon(
                      (ModalRoute.of(context)?.settings.name == '/home')
                          ? Icons.person
                          : Icons.arrow_forward,
                      color: Colors.white,
                      size: 35,
                    )),
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
