import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

const URL = 'https://piscinelaghetto.dieffetech.it/';
bool logged = false;
String token = '';
const BASICTOKEN = 'ZGllZmZldGVjaDowMGQ1ZTJlODk2OTE2MTRlODMxMzkwOGJl';
String username = '';
String password = '';
bool isAdmin = false;
dynamic logid;
int time = 0;

void updateLog(dynamic newLogId, dynamic newTime) async {
  logid = newLogId;
  time = newTime;
  var localStorage = await SharedPreferences.getInstance();
  localStorage.setInt('logid', newLogId);
  localStorage.setInt('time', time);
  //print('___LOG ID: $logid');
  //print('___TIME: $time');
}

Future<void> refreshToken() async {
  var response = await http.post(Uri.parse('${URL}oauth2/token'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'grant_type': 'password',
        'username': username,
        'password': password,
        'client_id': 'piscine',
        'client_secret': 'Sfd34i76kawdDRY',
      }));

  if (response.statusCode == 200) {
    print('___REFRESH TOKEN');
    var body = jsonDecode(response.body) as Map<String, dynamic>;
    token = body['access_token'];
  } else {
    print('___HTTP ERROR REFRESH TOKEN');
  }
}

bool validatePassword(String value) {
  String pattern =
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
  RegExp regExp = new RegExp(pattern);
  return regExp.hasMatch(value);
}
