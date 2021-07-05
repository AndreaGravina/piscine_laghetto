import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:piscine_laghetto/providers/tags_provider.dart';
import '../global_class.dart' as Globals;

class FileItem {
  final int repoid;
  final dynamic folderidfk;
  final String type;
  final dynamic open;
  final String name;
  final dynamic extension;
  final dynamic size;
  final dynamic path;
  final String updateDate;
  final List<dynamic> groupsId;
  final List<dynamic> usersId;
  final List<TagModel> tagList;

  static const String TYPE_FILE = 'File';
  static const String TYPE_FOLDER = 'Folder';

  FileItem({
    required this.repoid,
    required this.folderidfk,
    required this.type,
    required this.open,
    required this.name,
    required this.extension,
    required this.size,
    required this.path,
    required this.updateDate,
    this.groupsId = const [],
    this.usersId = const [],
    this.tagList = const [],
  });
}

class FileProvider with ChangeNotifier {
  List<FileItem> fileList = [];
  int total = 0;
  List<FileItem> tree = [];
  dynamic parent;
  dynamic currentFolder;
  dynamic currentFolderId;
  int offset = 0;
  var searchString = '';

  Future<void> getFiles(
      {dynamic folderidfk,
      String search = '',
      dynamic repoid,
      int retry = 0}) async {
    searchString = search.toString();
    if (searchString != '') folderidfk = null;

    var response = await http.post(Uri.parse('${Globals.URL}api/v1/home'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Globals.token}'
        },
        body: jsonEncode({
          'repoid': repoid,
          'folderidfk': folderidfk,
          'search': search,
          'limit': 10,
          'offset': 0,
          'log': {'logid': Globals.logid, 'time': Globals.time}
        }));

    if (response.statusCode == 200) {
      fileList = [];
      tree = [];
      offset = 0;
      var body = jsonDecode(response.body) as Map<String, dynamic>;
      total = body['total'];
      print('___TOTAL: $total');
      if (folderidfk != null) {
        List<dynamic> treeList = body['tree'];
        treeList.forEach((element) {
          tree.add(FileItem(
            repoid: element['repoid'],
            folderidfk: element['folderidfk'],
            type: element['type'],
            open: element['open'],
            name: element['name'],
            extension: element['extension'],
            size: element['size'],
            path: element['path'],
            updateDate: element['update_date'],
          ));
        });
        if (tree.length > 1) {
          currentFolder = tree.elementAt(tree.length - 1);
          currentFolderId = currentFolder.repoid;
          parent = tree.elementAt(tree.length - 2);
        } else {
          currentFolder = tree.elementAt(tree.length - 1);
          currentFolderId = currentFolder.repoid;
          parent = null;
        }
      } else {
        currentFolder = null;
        currentFolderId = null;
        parent = null;
        tree = [];
        // total = 0;
      }
      List<dynamic> repositories = body['repositories'];
      repositories.forEach((element) {

        List<dynamic> tags = element['tags'];
        List<TagModel> tagList = [];
        tags.forEach((element) {
          tagList.add(TagModel(
            id: element['tagid'],
            name: element['text'],
          ));
        });

        fileList.add(FileItem(
            repoid: element['repoid'],
            folderidfk: element['folderidfk'],
            type: element['type'],
            open: element['open'],
            name: element['name'],
            extension: element['extension'],
            size: element['size'],
            path: element['path'],
            updateDate: element['update_date'],
            groupsId: element['id_groups'],
            usersId: element['id_users'],
            tagList: tagList));
      });

      Globals.updateLog(body['log']['logid'], body['log']['time']);

      print('___LOAD FILES SUCCESS');
    } else if (response.statusCode == 401 && retry == 0) {
      await Globals.refreshToken().whenComplete(
          () => getFiles(folderidfk: folderidfk, search: search, retry: 1));
    } else {
      print('___HTTP ERROR LOAD FILE');
      throw Exception('___HTTP REQUEST FAILED');
    }
    notifyListeners();
  }

  Future<void> getMoreFiles({int retry = 0}) async {
    print('___TOTAL: $total');
    print('___OFFSET: $offset');
    if (total < offset + 10) {
      print('___FILE FINITI');
      return;
    }
    offset += 10;

    var folderidfk;

    if (currentFolder == null)
      folderidfk = null;
    else
      folderidfk = currentFolder.repoid;

    if (searchString != '') folderidfk = null;

    var response = await http.post(Uri.parse('${Globals.URL}api/v1/home'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Globals.token}'
        },
        body: jsonEncode({
          'folderidfk': folderidfk,
          'search': searchString,
          'limit': 10,
          'offset': offset,
          'log': {'logid': Globals.logid, 'time': Globals.time}
        }));

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body) as Map<String, dynamic>;
      List<dynamic> repositories = body['repositories'];
      repositories.forEach((element) {

          List<dynamic> tags = element['tags'];
        List<TagModel> tagList = [];
        tags.forEach((element) {
          tagList.add(TagModel(
            id: element['tagid'],
            name: element['text'],
          ));
        });


        fileList.add(FileItem(
            repoid: element['repoid'],
            folderidfk: element['folderidfk'],
            type: element['type'],
            open: element['open'],
            name: element['name'],
            extension: element['extension'],
            size: element['size'],
            path: element['path'],
            updateDate: element['update_date'],
            groupsId: element['id_groups'],
            usersId: element['id_users'],
            tagList: tagList));
      });
      Globals.updateLog(body['log']['logid'], body['log']['time']);
      print('___LOAD MORE FILES SUCCESS');
    } else if (response.statusCode == 401 && retry == 0) {
      await Globals.refreshToken().whenComplete(() => getMoreFiles(retry: 1));
    } else {
      print('___HTTP ERROR LOAD MORE FILE');
      throw Exception('___HTTP REQUEST FAILED');
    }
    notifyListeners();
  }
}
