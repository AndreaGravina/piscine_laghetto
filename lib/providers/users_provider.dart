import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../global_class.dart' as Globals;

class UserClass {
  final int userid;
  final dynamic roleidfk;
  final String name;
  final String surname;
  final String email;
  final String username;
  final dynamic businessName;
  final dynamic vatNumber;
  final int status;
  final int countLogin;
  final String groups;
  final List<dynamic> groupsId;
  final String creationDate;
  final String lastAccess;

  static const int ROLE_ADMIN = 2;
  static const int ROLE_USER = 4;

  UserClass({
    required this.userid,
    required this.roleidfk,
    required this.name,
    required this.surname,
    required this.email,
    required this.username,
    required this.businessName,
    required this.vatNumber,
    required this.status,
    required this.countLogin,
    required this.groups,
    required this.groupsId,
    this.creationDate = '',
    this.lastAccess = '',
  });
}


class UsersProvider with ChangeNotifier {
  List<UserClass> usersList = [];
  List<UserClass> adminsList = [];
  int total = 0;
  int offset = 0;
  var searchString = '';

  Future<void> getUsers(int type, {String search = '', int retry = 0}) async {
    searchString = search.toString();

    var response = await http.post(Uri.parse('${Globals.URL}api/v1/get-users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Globals.token}'
        },
        body: jsonEncode({
          'type': type,
          'search': searchString,
          'limit': 10,
          'offset': 0,
          'log': {'logid': Globals.logid, 'time': Globals.time}
        }));

    if (response.statusCode == 200) {
      if (type == UserClass.ROLE_USER) usersList = [];
      if (type == UserClass.ROLE_ADMIN) adminsList = [];
      offset = 0;
      var body = jsonDecode(response.body) as Map<String, dynamic>;
      total = body['total'];
      List<dynamic> users = body['users'];
      if (type == 4) {
        users.forEach((element) {
          usersList.add(UserClass(
              userid: element['userid'],
              roleidfk: element['roleidfk'],
              name: element['name'],
              surname: element['surname'],
              email: element['email'],
              username: element['username'],
              businessName: element['business_name'],
              vatNumber: element['vat_number'],
              status: element['status'],
              countLogin: element['count_login'],
              groups: element['groups'],
              groupsId: element['ids_groups']));
        });
      } else {
        users.forEach((element) {
          adminsList.add(UserClass(
              userid: element['userid'],
              roleidfk: element['roleidfk'],
              name: element['name'],
              surname: element['surname'],
              email: element['email'],
              username: element['username'],
              businessName: element['business_name'],
              vatNumber: element['vat_number'],
              status: element['status'],
              countLogin: element['count_login'],
              groups: element['groups'],
              groupsId: element['ids_groups']));
        });
      }
      Globals.updateLog(body['log']['logid'], body['log']['time']);
      print('___LOAD USERS SUCCESS');
    } else if (response.statusCode == 401 && retry == 0) {
      await Globals.refreshToken()
          .whenComplete(() => getUsers(type, search: search, retry: 1));
    } else {
      print('___HTTP ERROR LOAD USERS');
      throw Exception('___HTTP REQUEST FAILED');
    }
    notifyListeners();
  }

  Future<void> getMoreUsers(int type, {int retry = 0}) async {
    if (total < offset + 10) {
      print('___USER FINITI');
      return;
    }
    offset += 10;

    var response = await http.post(Uri.parse('${Globals.URL}api/v1/get-users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Globals.token}'
        },
        body: jsonEncode({
          'type': type,
          'search': searchString,
          'limit': 10,
          'offset': offset,
          'log': {'logid': Globals.logid, 'time': Globals.time}
        }));
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body) as Map<String, dynamic>;
      List<dynamic> users = body['users'];
      if (type == 4) {
        users.forEach((element) {
          usersList.add(UserClass(
              userid: element['userid'],
              roleidfk: element['roleidfk'],
              name: element['name'],
              surname: element['surname'],
              email: element['email'],
              username: element['username'],
              businessName: element['business_name'],
              vatNumber: element['vat_number'],
              status: element['status'],
              countLogin: element['count_login'],
              groups: element['groups'],
              groupsId: element['ids_groups']));
        });
      } else {
        users.forEach((element) {
          adminsList.add(UserClass(
              userid: element['userid'],
              roleidfk: element['roleidfk'],
              name: element['name'],
              surname: element['surname'],
              email: element['email'],
              username: element['username'],
              businessName: element['business_name'],
              vatNumber: element['vat_number'],
              status: element['status'],
              countLogin: element['count_login'],
              groups: element['groups'],
              groupsId: element['ids_groups']));
        });
      }
      Globals.updateLog(body['log']['logid'], body['log']['time']);
      print('___LOAD MORE USERS SUCCESS');
    } else if (response.statusCode == 401 && retry == 0) {
      await Globals.refreshToken()
          .whenComplete(() => getMoreUsers(type, retry: 1));
    } else {
      print('___HTTP ERROR LOAD MORE USERS');
      throw Exception('___HTTP REQUEST FAILED');
    }
    notifyListeners();
  }

  Future<void> getAllUsers(int type,
      {String search = '', int retry = 0}) async {
    searchString = search.toString();

    var response = await http.post(Uri.parse('${Globals.URL}api/v1/get-users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Globals.token}'
        },
        body: jsonEncode({
          'type': type,
          'search': searchString,
          'log': {'logid': Globals.logid, 'time': Globals.time}
        }));

    if (response.statusCode == 200) {
      if (type == UserClass.ROLE_USER) usersList = [];
      if (type == UserClass.ROLE_ADMIN) adminsList = [];
      offset = 0;
      var body = jsonDecode(response.body) as Map<String, dynamic>;
      total = body['total'];
      List<dynamic> users = body['users'];
      if (type == 4) {
        users.forEach((element) {
          usersList.add(UserClass(
              userid: element['userid'],
              roleidfk: element['roleidfk'],
              name: element['name'],
              surname: element['surname'],
              email: element['email'],
              username: element['username'],
              businessName: element['business_name'],
              vatNumber: element['vat_number'],
              status: element['status'],
              countLogin: element['count_login'],
              groups: element['groups'],
              groupsId: element['ids_groups']));
        });
      } else {
        users.forEach((element) {
          adminsList.add(UserClass(
              userid: element['userid'],
              roleidfk: element['roleidfk'],
              name: element['name'],
              surname: element['surname'],
              email: element['email'],
              username: element['username'],
              businessName: element['business_name'],
              vatNumber: element['vat_number'],
              status: element['status'],
              countLogin: element['count_login'],
              groups: element['groups'],
              groupsId: element['ids_groups']));
        });
      }
      Globals.updateLog(body['log']['logid'], body['log']['time']);
      print('___LOAD ALL USERS SUCCESS');
    } else if (response.statusCode == 401 && retry == 0) {
      await Globals.refreshToken()
          .whenComplete(() => getUsers(type, search: search, retry: 1));
    } else {
      print('___HTTP ERROR ALL LOAD USERS');
      throw Exception('___HTTP REQUEST FAILED');
    }
    notifyListeners();
  }
}
