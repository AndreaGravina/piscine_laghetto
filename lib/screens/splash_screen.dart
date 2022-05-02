import 'dart:async';

import 'package:flutter/material.dart';
import 'package:piscine_laghetto/providers/auth_status.dart';
import 'package:piscine_laghetto/screens/home_screen.dart';
import 'package:piscine_laghetto/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../global_class.dart' as Globals;

class SpashScreen extends StatefulWidget {
  const SpashScreen({Key? key}) : super(key: key);
  @override
  _SpashScreenState createState() => _SpashScreenState();
}

class _SpashScreenState extends State<SpashScreen> {
  Future check() async {
    var localStorage = await SharedPreferences.getInstance();
    dynamic localUsername = localStorage.getString('username');
    dynamic localPassword = localStorage.getString('password');
    dynamic localLogId = localStorage.getInt('logid');
    dynamic localTime = localStorage.getInt('time');
    if (localLogId != null) Globals.updateLog(localLogId, localTime);

    var logged = await Provider.of<AuthStatus>(context, listen: false)
        .login(localUsername, localPassword);
    if (logged) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 1), () {
      check();
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
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
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: deviceSize.height * 0.2),
            child: Column(children: [
              Container(
                width: deviceSize.width * 0.5,
                margin: EdgeInsets.only(bottom: 30),
                child: Image.asset(
                  'images/ssw.png',
                  fit: BoxFit.contain,
                ),
              ),
              Container(
                height: 250,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              )
            ]),
          )
        ]));
  }
}
