import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_status.dart';
import '../screens/home_screen.dart';
import './custom_dialog.dart';
import '../global_class.dart' as Globals;

enum Mode { LOGIN, FORGOT, FIRSTLOG }

class LoginBox extends StatefulWidget {
  @override
  _LoginBoxState createState() => _LoginBoxState();
}

class _LoginBoxState extends State<LoginBox>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  Mode mode = Mode.LOGIN;
  bool _isLoading = false;
  Map<String, String> _authData = {
    'username': '',
    'password': '',
  };
  final _passwordController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _opacityAnimation = Tween(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<void> _submit() async {
    print('sonoQUI');
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      print('sonoQUA');
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      if (mode == Mode.LOGIN) {
        print('___LOGIN');
        Provider.of<AuthStatus>(context, listen: false)
            .login(_authData['username']!, _authData['password']!)
            .then((value) {
          setState(() {
            _isLoading = false;
          });
          if (value) {
            if (Provider.of<AuthStatus>(context, listen: false).isFirstLog()) {
              setState(() {
                mode = Mode.FIRSTLOG;
              });
              return;
            } else
              Navigator.of(context).popAndPushNamed(HomeScreen.routeName);
          } else
            showDialog(
                context: context,
                builder: (context) => CustomDialog(
                    title: 'Errore di autenticazione',
                    text: 'controlla che i dati siano inseriti correttamente'));
        });
      } else if (mode == Mode.FIRSTLOG) {
        print('___FIRST LOG');
        Provider.of<AuthStatus>(context, listen: false)
            .resetPasswordFirstLog(_authData['password']!)
            .then((value) {
          setState(() {
            _isLoading = false;
          });
          if (value) {
            Navigator.of(context).popAndPushNamed(HomeScreen.routeName);
          } else
            showDialog(
                context: context,
                builder: (context) => CustomDialog(
                    title: 'Errore',
                    text: 'Si è verificato un problema durante il reset'));
        });
      } else {
        print('___RESET');
        Provider.of<AuthStatus>(context, listen: false)
            .resetPassword(_authData['username']!)
            .then((value) {
          setState(() {
            _isLoading = false;
          });
          if (value) {
            showDialog(
                context: context,
                builder: (context) => CustomDialog(
                    icon: Icon(
                      Icons.done_outline,
                      color: const Color(0xFF0375fe),
                      size: 40,
                    ),
                    title: 'Fatto',
                    text:
                        'Ti abbiamo inviato una mail per resettare la password del tuo account'));
          } else
            showDialog(
                context: context,
                builder: (context) => CustomDialog(
                    title: 'Errore',
                    text: 'Si è verificato un problema durante il reset'));
        });
      }
    }
  }

  void _switchAuthMode() {
    if (mode == Mode.LOGIN) {
      setState(() {
        mode = Mode.FORGOT;
      });
      _controller.forward();
    } else {
      setState(() {
        mode = Mode.LOGIN;
      });
      _controller.reverse();
    }
  }

  void _switchToFirst() {
    if (mode == Mode.LOGIN) {
      setState(() {
        mode = Mode.FIRSTLOG;
      });
    } else {
      setState(() {
        mode = Mode.LOGIN;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(top: deviceSize.height * 0.2),
        child: Column(
          children: [
            Container(
              width: deviceSize.width * 0.5,
              margin: EdgeInsets.only(bottom: 30),
              child: Image.asset(
                'images/logo.png',
                fit: BoxFit.contain,
              ),
            ),
            Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                elevation: 8.0,
                child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.fastOutSlowIn,
                    constraints: BoxConstraints(
                        minHeight: mode == Mode.LOGIN || mode == Mode.FIRSTLOG
                            ? 330
                            : 270,
                        maxHeight: mode == Mode.LOGIN || mode == Mode.FIRSTLOG
                            ? 450
                            : 350),
                    width: deviceSize.width * 0.75,
                    padding: EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: [
                                Text(
                                  mode == Mode.LOGIN
                                      ? 'Area riservata'
                                      : mode == Mode.FORGOT
                                          ? 'Dimenticato la password'
                                          : 'Reset password',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              key: Key('{$mode.toString()} 1'),
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide: BorderSide(
                                          color: Colors.transparent,
                                          width: 1.5)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide: BorderSide(
                                          color: Colors.transparent,
                                          width: 1.5)),
                                  filled: true,
                                  hintStyle:
                                      TextStyle(color: Color(0xFF979797)),
                                  fillColor: Color(0xFFe8f0fe),
                                  errorMaxLines: 5,
                                  hintText:
                                      '${mode == Mode.LOGIN || mode == Mode.FORGOT ? 'Username' : 'Nuova Password'}'),
                              obscureText: mode == Mode.FIRSTLOG,
                              controller: mode == Mode.FIRSTLOG
                                  ? _passwordController
                                  : null,
                              validator: (value) {
                                if (value!.isEmpty && mode != Mode.FIRSTLOG) {
                                  return 'username non valido';
                                } else if ((!Globals.validatePassword(value)) &&
                                    mode == Mode.FIRSTLOG)
                                  return 'La password deve contenere almeno : Un carattere in maiuscolo Un carattere speciale Un carattere numerico 8 caratteri';
                                return null;
                              },
                              onSaved: (value) {
                                if (mode == Mode.LOGIN || mode == Mode.FORGOT)
                                  _authData['username'] = value.toString();
                                else
                                  _authData['password'] = value.toString();
                              },
                            ),
                            SizedBox(
                              height:
                                  mode == Mode.LOGIN || mode == Mode.FIRSTLOG
                                      ? 15
                                      : 0,
                            ),
                            AnimatedContainer(
                              constraints: BoxConstraints(
                                  minHeight: mode == Mode.LOGIN ||
                                          mode == Mode.FIRSTLOG
                                      ? 60
                                      : 0,
                                  maxHeight: mode == Mode.LOGIN ||
                                          mode == Mode.FIRSTLOG
                                      ? 120
                                      : 0),
                              duration: Duration(
                                  milliseconds: mode == Mode.LOGIN ||
                                          mode == Mode.FIRSTLOG
                                      ? 500
                                      : 350),
                              child: FadeTransition(
                                opacity: _opacityAnimation,
                                child: TextFormField(
                                  key: Key('{$mode.toString()} 2'),
                                  enabled: mode == Mode.LOGIN ||
                                      mode == Mode.FIRSTLOG,
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
                                          borderSide: BorderSide(
                                              color: Colors.transparent,
                                              width: 1.5)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
                                          borderSide: BorderSide(
                                              color: Colors.transparent,
                                              width: 1.5)),
                                      filled: true,
                                      errorMaxLines: 5,
                                      hintStyle:
                                          TextStyle(color: Color(0xFF979797)),
                                      fillColor: Color(0xFFe8f0fe),
                                      hintText: mode == Mode.LOGIN
                                          ? 'Password'
                                          : 'Conferma password'),
                                  obscureText: true,
                                  validator: mode == Mode.FIRSTLOG
                                      ? (value) {
                                          if (value !=
                                              _passwordController.text) {
                                            return 'Le Password non corrispondono';
                                          }
                                          return null;
                                        }
                                      : mode == Mode.LOGIN
                                          ? (value) {
                                              if (!Globals.validatePassword(
                                                  value!))
                                                return 'La password deve contenere almeno : Un carattere in maiuscolo Un carattere speciale Un carattere numerico 8 caratteri';
                                              else
                                                return null;
                                            }
                                          : null,
                                  onSaved: (value) {
                                    if (mode == Mode.LOGIN)
                                      _authData['password'] = value.toString();
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            if (_isLoading)
                              Container(
                                  margin: EdgeInsets.only(top: 10),
                                  child: CircularProgressIndicator()),
                            if (!_isLoading)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                child: ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.all(0)),
                                  child: Ink(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF3bbddc),
                                          Color(0xFF0375fe),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(80.0)),
                                    ),
                                    child: Container(
                                      constraints: const BoxConstraints(
                                          minWidth: 88.0, minHeight: 43.0),
                                      alignment: Alignment.center,
                                      child: Text(
                                        mode == Mode.LOGIN ||
                                                mode == Mode.FIRSTLOG
                                            ? 'ACCEDI'
                                            : 'RESET',
                                        style: TextStyle(color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (!_isLoading)
                              TextButton(
                                  child: Text(
                                    mode == Mode.LOGIN ? 'Hai dimenticato la password?' : 'Torna indietro',
                                    style: TextStyle(
                                      color: Color(0xFF4dd2ff),
                                    ),
                                  ),
                                  onPressed:
                                      mode == Mode.LOGIN || mode == Mode.FORGOT
                                          ? _switchAuthMode
                                          : _switchToFirst,
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 4),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  )),
                          ],
                        ),
                      ),
                    ))),
          ],
        ),
      ),
    );
  }
}
