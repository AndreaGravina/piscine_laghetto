import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../global_class.dart' as Globals;

class GroupItem {
  final int groupid;
  final String name;
  final int status;
  final String creationDate;

  GroupItem({
    required this.groupid,
    required this.name,
    required this.status,
    required this.creationDate,
  });
}

class GroupProvider with ChangeNotifier {
  List<GroupItem> groupList = [];
  int total = 0;
  int offset = 0;
  var searchString = '';

  Future<void> getGroups({String search = '', int retry = 0}) async {
    searchString = search.toString();

    var response = await http.post(
        Uri.parse('${Globals.URL}api/v1/get-groups'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Globals.token}'
        },
        body: jsonEncode({
          'search': search,
          'limit': 10,
          'offset': 0,
          'log': {'logid': Globals.logid, 'time': Globals.time}
        }));

    if (response.statusCode == 200) {
      groupList = [];
      offset = 0;
      var body = jsonDecode(response.body) as Map<String, dynamic>;
      total = body['total'];
      List<dynamic> users = body['groups'];

      users.forEach((element) {
        groupList.add(GroupItem(
          groupid: element['groupid'],
          name: element['name'],
          status: element['status'],
          creationDate: element['creation_date'],
        ));
      });

      Globals.updateLog(body['log']['logid'], body['log']['time']);
      print('___LOAD GROUPS SUCCESS');
      
    } else if (response.statusCode == 401 && retry == 0) {
      await Globals.refreshToken()
          .whenComplete(() => getGroups(search: search, retry: 1));
    } else {
      print('___HTTP ERROR LOAD GROUPS');
      throw Exception('___HTTP REQUEST FAILED');
    }
    notifyListeners();
  }

  Future<void> getMoreGroups({int retry = 0}) async {
    if (total < offset + 10) {
      print('___GROUPS FINITI');
      return;
    }
    offset += 10;

    var response = await http.post(
        Uri.parse('${Globals.URL}api/v1/get-users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Globals.token}'
        },
        body: jsonEncode({
          'search': searchString,
          'limit': 10,
          'offset': offset,
          'log': {'logid': Globals.logid, 'time': Globals.time}
        }));
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body) as Map<String, dynamic>;
      List<dynamic> users = body['users'];

      users.forEach((element) {
        groupList.add(GroupItem(
          groupid: element['groupid'],
          name: element['name'],
          status: element['status'],
          creationDate: element['creation_date'],
        ));
      });

      Globals.updateLog(body['log']['logid'], body['log']['time']);
      print('___LOAD MORE GROUPS SUCCESS');
    } else if (response.statusCode == 401 && retry == 0) {
      await Globals.refreshToken().whenComplete(() => getMoreGroups( retry: 1));
    } else {
      print('___HTTP ERROR LOAD MORE GROUPS');
      throw Exception('___HTTP REQUEST FAILED');
    }
    notifyListeners();
  }

   Future<void> getAllGroups({String search = '', int retry = 0}) async {
    searchString = search.toString();

    var response = await http.post(
        Uri.parse('${Globals.URL}api/v1/get-groups'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Globals.token}'
        },
        body: jsonEncode({
          'search': search,
          'log': {'logid': Globals.logid, 'time': Globals.time}
        }));

    if (response.statusCode == 200) {
      groupList = [];
      offset = 0;
      var body = jsonDecode(response.body) as Map<String, dynamic>;
      total = body['total'];
      List<dynamic> users = body['groups'];

      users.forEach((element) {
        groupList.add(GroupItem(
          groupid: element['groupid'],
          name: element['name'],
          status: element['status'],
          creationDate: element['creation_date'],
        ));
      });

      Globals.updateLog(body['log']['logid'], body['log']['time']);
      print('___LOAD GROUPS SUCCESS');
      
    } else if (response.statusCode == 401 && retry == 0) {
      await Globals.refreshToken()
          .whenComplete(() => getGroups(search: search, retry: 1));
    } else {
      print('___HTTP ERROR LOAD GROUPS');
      throw Exception('___HTTP REQUEST FAILED');
    }
    notifyListeners();
  }

}
