import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../global_class.dart' as Globals;

class TagModel {
  int id;
  String name;

  TagModel({
    required this.id,
    required this.name,
  });
}

class TagProvider with ChangeNotifier {
  List<TagModel> tagList = [];

  Future<void> getAll({String search = '', int retry = 0}) async {
    var response = await http.post(Uri.parse('${Globals.URL}api/v1/get-gut'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Globals.token}'
        },
        body: jsonEncode({
          'type': 'tags',
          'search': search,
          'log': {'logid': Globals.logid, 'time': Globals.time}
        }));

    if (response.statusCode == 200) {
      tagList = [];
      var body = jsonDecode(response.body) as Map<String, dynamic>;
      List<dynamic> tags = body['tags'];

      tags.forEach((element) {
        tagList.add(TagModel(
          id: element['tagid'],
          name: element['text'],
        ));
      });

      Globals.updateLog(body['log']['logid'], body['log']['time']);
      print('___LOAD TAGS SUCCESS');
    } else if (response.statusCode == 401 && retry == 0) {
      await Globals.refreshToken()
          .whenComplete(() => getAll(search: search, retry: 1));
    } else {
      print('___HTTP ERROR LOAD TAGS');
      throw Exception('___HTTP REQUEST FAILED');
    }
    notifyListeners();
  }

  Future<List<TagModel>> search(String search, {int retry = 0}) async {
    var response = await http.post(Uri.parse('${Globals.URL}api/v1/get-gut'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Globals.token}'
        },
        body: jsonEncode({
          'type': 'tags',
          'search': search,
          'log': {'logid': Globals.logid, 'time': Globals.time}
        }));

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body) as Map<String, dynamic>;
      List<dynamic> tags = body['tags'];

      List<TagModel> result = [];

      tags.forEach((element) {
        result.add(TagModel(
          id: element['tagid'],
          name: element['text'],
        ));
      });

      Globals.updateLog(body['log']['logid'], body['log']['time']);
      print('SEARCH TAGS SUCCESS');
      return result;
    } else if (response.statusCode == 401 && retry == 0) {
      await Globals.refreshToken()
          .whenComplete(() => getAll(search: search, retry: 1));
      throw Exception('___HTTP REQUEST FAILED');
    } else {
      print('___HTTP ERROR SEARCH TAGS');
      throw Exception('___HTTP REQUEST FAILED');
    }
  }
}
