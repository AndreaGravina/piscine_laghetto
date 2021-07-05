import 'package:flutter/material.dart';
import 'package:piscine_laghetto/widgets/login_box.dart';

class LoginScreen extends StatefulWidget {
   static const routeName = '/login';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
       onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          body: Stack(children: [
            Container(
              decoration: BoxDecoration(
                    gradient: LinearGradient(
                  colors: [
                    Color(0xFF3bbddc),
                    Color(0xFF0375fe),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )),
            ),
            LoginBox()
          ])),
    );
  }
}
