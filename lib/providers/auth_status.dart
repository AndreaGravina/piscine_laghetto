import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../global_class.dart' as Globals;

class AuthStatus with ChangeNotifier {
  Map<String, dynamic> userInfo = {
    'userid': null,
    'roleidfk': null,
    'name': null,
    'surname': null,
    'email': null,
    'username': null,
    'passwd': null,
    'status': null,
    'count_login': null,
    'change_passwd': null,
  };

  Future<bool> login(
    dynamic username,
    dynamic password,
  ) async {
    var deviceState = await OneSignal.shared.getDeviceState();
    var playerId = deviceState!.userId;

    var response = await http.post(Uri.parse('${Globals.URL}oauth2/token'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'grant_type': 'password',
          'username': username,
          'password': password,
          'client_id': 'piscine',
          'client_secret': 'Sfd34i76kawdDRY',
          'appid': playerId
        }));

    if (response.statusCode == 200) {
      print('___LOGIN SUCCESS');
      var body = jsonDecode(response.body) as Map<String, dynamic>;
      Globals.token = body['access_token'];
      var info = body['info'] as Map<String, dynamic>;
      userInfo['userid'] = info['userid'];
      userInfo['roleidfk'] = info['roleidfk'];
      userInfo['name'] = info['name'];
      userInfo['surname'] = info['surname'];
      userInfo['email'] = info['email'];
      userInfo['username'] = info['username'];
      userInfo['passwd'] = info['passwd'];
      userInfo['status'] = info['status'];
      userInfo['count_login'] = info['count_login'];
      userInfo['change_passwd'] = info['change_passwd'];
      Globals.username = username;
      Globals.password = password;

      if (info['roleidfk'] == 4)
        Globals.isAdmin = false;
      else
        Globals.isAdmin = true;
      if (userInfo['change_passwd'] == 1) return true;
      var localStorage = await SharedPreferences.getInstance();
      localStorage.setString('username', username);
      localStorage.setString('password', password);
      Globals.logged = true;
    } else {
      print('___HTTP ERROR LOGIN');
      Globals.logged = false;
    }
    notifyListeners();
    return Globals.logged;
  }

  bool isFirstLog() {
    if (userInfo['change_passwd'] == 1)
      return true;
    else
      return false;
  }

  void logout() async {
    Globals.logged = false;
    Globals.token = '';
    userInfo['userid'] = null;
    userInfo['roleidfk'] = null;
    userInfo['name'] = null;
    userInfo['surname'] = null;
    userInfo['email'] = null;
    userInfo['username'] = null;
    userInfo['passwd'] = null;
    userInfo['status'] = null;
    userInfo['count_login'] = null;
    userInfo['change_passwd'] = null;
    var localStorage = await SharedPreferences.getInstance();
    localStorage.clear();
  }

  Future<bool> resetPassword(
    String username,
  ) async {
    print('___START RESET PASSWORD USER: $username');

    var response =
        await http.post(Uri.parse('${Globals.URL}util/v1/reset-password'),
            headers: {'Authorization': 'Basic ${Globals.BASICTOKEN}'},
            body: jsonEncode({
              'username': username,
            }));

    if (response.statusCode == 200) {
      print('___RESET PASSWORD SUCCESS');
      Globals.logged = true;
    } else {
      print('___HTTP ERROR RESET PASSWORD');
      Globals.logged = false;
    }
    notifyListeners();
    return Globals.logged;
  }

  Future<bool> resetPasswordFirstLog(String password, {int retry = 0}) async {
    var response = await http.post(
        Uri.parse('${Globals.URL}api/v1/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Globals.token}'
        },
        body: jsonEncode({'passwd': password}));

    if (response.statusCode == 200) {
      print('___RESET PASSWORD SUCCESS FIRST LOG');
      var localStorage = await SharedPreferences.getInstance();
      localStorage.clear();
      localStorage.setString('username', userInfo['username']);
      localStorage.setString('password', password);
      Globals.logged = true;
    } else if (response.statusCode == 401 && retry == 0) {
      await Globals.refreshToken()
          .whenComplete(() => resetPasswordFirstLog(password, retry: 1));
    } else {
      print('___HTTP ERROR RESET PASSWORD FIRST LOG');
      Globals.logged = false;
    }
    notifyListeners();
    return Globals.logged;
  }

  
}
