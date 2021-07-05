import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../global_class.dart' as Globals;

class NotificationItem {
  final String title;
  final String content;
  final String date;
  final String status;
  final int repositoryIdfk;

  NotificationItem({
    required this.title,
    required this.content,
    required this.date,
    required this.status,
    required this.repositoryIdfk,
  });
}

class NotificationProvider with ChangeNotifier {
  List<NotificationItem> notificationList = [];
  var check = false;

  Future<void> getNotification({int retry = 0}) async {
    var response = await http.post(
      Uri.parse('${Globals.URL}api/v1/get-notifications'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Globals.token}'
      },
      body: jsonEncode({
        'log': {'logid': Globals.logid, 'time': Globals.time}
      }),
    );

    if (response.statusCode == 200) {
      notificationList = [];
      check = false;
      var body = jsonDecode(response.body) as Map<String, dynamic>;

      if (body['notifications'] != null) {
        List<dynamic> repositories = body['notifications'];

        if (repositories.isNotEmpty) {
          repositories.forEach((element) {
            notificationList.add(NotificationItem(
              title: element['title'],
              content: element['content'],
              date: element['date'],
              status: element['status'],
              repositoryIdfk: element['repositoryidfk'],
            ));
          });
          notificationList.forEach((notification) {
            if (int.parse(notification.status) == 1) check = true;
          });
        }
      }
      Globals.updateLog(body['log']['logid'], body['log']['time']);
      print('___LOAD NOTIFICATION SUCCESS');
    } else if (response.statusCode == 401 && retry == 0) {
      await Globals.refreshToken()
          .whenComplete(() => getNotification(retry: 1));
    } else {
      print('___HTTP ERROR LOAD NOTIFICATION');
      throw Exception('___HTTP REQUEST FAILED');
    }
    notifyListeners();
  }

  Future<void> setNotificationStatus({int retry = 0}) async {
    var response = await http.post(
      Uri.parse('${Globals.URL}api/v1/set-notification-status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Globals.token}'
      },
      body: jsonEncode({
        'log': {'logid': Globals.logid, 'time': Globals.time}
      }),
    );

    if (response.statusCode == 200) {
      check = false;
      var body = jsonDecode(response.body) as Map<String, dynamic>;
      Globals.updateLog(body['log']['logid'], body['log']['time']);

      print('___SET NOTIFICATION STATUS SUCCESS');
    } else if (response.statusCode == 401 && retry == 0) {
      await Globals.refreshToken()
          .whenComplete(() => setNotificationStatus(retry: 1));
    } else {
      print('___HTTP ERROR SET NOTIFICATION STATUS');
      throw Exception('___HTTP REQUEST FAILED');
    }
    notifyListeners();
  }
}
