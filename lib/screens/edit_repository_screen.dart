import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:piscine_laghetto/providers/file_provider.dart';
import 'package:piscine_laghetto/providers/group_provider.dart';
import 'package:piscine_laghetto/providers/tags_provider.dart';
import 'package:piscine_laghetto/providers/users_provider.dart';
import 'package:piscine_laghetto/widgets/custom_dialog.dart';
import 'package:piscine_laghetto/widgets/support_dialog.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../global_class.dart' as Globals;

class EditRepositoryScreen extends StatefulWidget {
  const EditRepositoryScreen({Key? key}) : super(key: key);

  static const routeName = '/edit-repository';

  @override
  _EditRepositoryScreenState createState() => _EditRepositoryScreenState();
}

class _EditRepositoryScreenState extends State<EditRepositoryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  Status status = Status.DEFAULT;
  List<dynamic> groupData = [];
  List<dynamic> userData = [];
  String fileName = '';
  dynamic file;
  Map<String, dynamic> _submitData = {
    'name': null,
    'groups': [],
    'users': [],
    'tags': []
  };
  TextEditingController _searchTextEditingController =
      new TextEditingController();
  String get _searchText => _searchTextEditingController.text.trim();
  List<TagModel> selectedTags = [];
  List<TagModel> suggestedTags = [];
  var init = true;

  @override
  void initState() {
    super.initState();
    Provider.of<UsersProvider>(context, listen: false)
        .getAllUsers(UserClass.ROLE_USER);
    Provider.of<GroupProvider>(context, listen: false).getAllGroups();
    Provider.of<TagProvider>(context, listen: false).getAll();
    _searchTextEditingController.addListener(() => refreshState(() {}));
    init = true;
  }

  @override
  void dispose() {
    _searchTextEditingController.dispose();
    selectedTags = [];
    suggestedTags = [];
    _submitData = {'name': null, 'groups': [], 'users': [], 'tags': []};
    super.dispose();
  }

  Future<void> editFolder(context, int folderId, {int retry = 0}) async {
    setState(() {
      status = Status.LOADING;
    });
    var currentFolderId =
        Provider.of<FileProvider>(context, listen: false).currentFolderId;

    print(_submitData.toString());

    var response = await http.post(
        Uri.parse('${Globals.URL}api/v1/save-repository'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Globals.token}'
        },
        body: jsonEncode({
          'folderidfk': currentFolderId,
          'repoid': folderId,
          'type': 'Folder',
          'name': _submitData['name'],
          'groups': _submitData['groups'],
          'users': _submitData['users'],
          'tags': _submitData['tags'],
          'log': {'logid': Globals.logid, 'time': Globals.time}
        }));

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body) as Map<String, dynamic>;
      bool success = body['success'];
      if (!success) {
        print('___HTTP EDIT FOLDER SUCCESS FALSE');
        String message = body['message'];
        showDialog(
            context: context,
            builder: (context) => CustomDialog(title: 'ERRORE', text: message));
        setState(() {
          status = Status.DEFAULT;
        });
      } else {
        Globals.updateLog(body['log']['logid'], body['log']['time']);
        print('___EDIT FOLDER SUCCESS');
        setState(() {
          status = Status.DONE;
        });
      }
    } else if (response.statusCode == 401 && retry == 0) {
      print('___TRY REFRESH TOKEN');
      await Globals.refreshToken()
          .whenComplete(() => editFolder(context, folderId, retry: 1));
    } else {
      print('___HTTP ERROR EDIT FOLDER');
      showDialog(
          context: context,
          builder: (context) => CustomDialog(
              title: 'ERRORE',
              text: 'Qualcosa è andato storto, riprova più tardi'));
      setState(() {
        status = Status.DEFAULT;
      });
    }
    Provider.of<FileProvider>(context, listen: false)
        .getFiles(folderidfk: currentFolderId);
  }

  Future<void> editFile(context, String type, int folderId, dynamic file,
      {int retry = 0}) async {
    setState(() {
      status = Status.LOADING;
    });
    print(_submitData.toString());
    var currentFolderId =
        Provider.of<FileProvider>(context, listen: false).currentFolderId;

    // string to uri
    var uri = Uri.parse('${Globals.URL}api/v1/save-repository');

    // create multipart request
    var request = new http.MultipartRequest("POST", uri);

    request.headers['Content-Type'] = 'application/json';
    request.headers['Authorization'] = 'Bearer ${Globals.token}';

    if (currentFolderId != null)
      request.fields['folderidfk'] = currentFolderId.toString();
    request.fields['repoid'] = folderId.toString();
    request.fields['type'] = type;
    request.fields['name'] = _submitData['name'];

    for (int i = 0; i < _submitData['groups'].length; i++) {
      request.fields['groups[$i]'] = '${_submitData['groups'][i]}';
    }

    for (int i = 0; i < _submitData['users'].length; i++) {
      request.fields['users[$i]'] = '${_submitData['users'][i]}';
    }

    for (int i = 0; i < _submitData['tags'].length; i++) {
      request.fields['tags[$i]'] = '${_submitData['tags'][i]}';
    }

    request.fields['log[logid]'] = Globals.logid.toString();
    request.fields['log[time]'] = Globals.time.toString();

    if (file != null) {
      var stream = new http.ByteStream(Stream.castFrom(file.openRead()));
      // get file length
      var length = await file.length();
      // multipart that takes file
      var multipartFile = new http.MultipartFile(
          'Repository[path]', stream, length,
          filename: path.basename(file.path));
      // add file to multipart
      request.files.add(multipartFile);
    }

    print('__REQUEST FIELDS: ${request.fields.toString()}');

    // send
    var response = await request.send();

    print(response.statusCode);

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      var body = jsonDecode(respStr) as Map<String, dynamic>;
      bool success = body['success'];
      if (!success) {
        print('___HTTP EDIT FILE SUCCESS = FALSE');
        String message = body['message'];
        showDialog(
            context: context,
            builder: (context) => CustomDialog(title: 'ERRORE', text: message));
        setState(() {
          status = Status.DEFAULT;
        });
      } else {
        print('___EDIT FILE SUCCESS');
        Globals.updateLog(body['log']['logid'], body['log']['time']);
        setState(() {
          status = Status.DONE;
        });
      }
    } else if (response.statusCode == 401 && retry == 0) {
      print('___TRY REFRESH TOKEN');
      await Globals.refreshToken().whenComplete(
          () => editFile(context, type, folderId, file, retry: 1));
    } else {
      print('___HTTP ERROR ___EDIT FILE');
      showDialog(
          context: context,
          builder: (context) => CustomDialog(
              title: 'ERRORE',
              text: 'Qualcosa è andato storto, riprova più tardi'));
      setState(() {
        status = Status.DEFAULT;
      });
    }
    Provider.of<FileProvider>(context, listen: false)
        .getFiles(folderidfk: currentFolderId);
  }

  refreshState(VoidCallback fn) {
    searchTags().whenComplete(() {
      if (mounted) setState(fn);
    });
  }

  Future<void> searchTags() async {
    suggestedTags = [];
    if (_searchText.isEmpty || _searchText.length < 3)
      return;
    else {
      List<TagModel> tempList = [];
      tempList = await Provider.of<TagProvider>(context, listen: false)
          .search(_searchText);
      suggestedTags = [];
      tempList.forEach((searchedTag) {
        if (!_submitData['tags'].contains(searchedTag.id)) {
          suggestedTags.add(searchedTag);
        }
      });
    }
  }

  addTag(TagModel tag) {
    if (!_submitData['tags'].contains(tag.id)) {
      _submitData['tags'].add(tag.id);
      print('___${_submitData['tags']}');
      setState(() {
        selectedTags.add(tag);
        suggestedTags.remove(tag);
      });
    }
  }

  removeTag(TagModel tag) {
    if (_submitData['tags'].contains(tag.id)) {
      _submitData['tags'].remove(tag.id);
      print('___${_submitData['tags']}');
      setState(() {
        refreshState(() {});
        selectedTags.remove(tag);
        //  suggestedTags.add(tag);
      });
    }
  }

  Widget suggestionWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: suggestedTags.isNotEmpty
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (suggestedTags.length != 0)
                Container(
                    margin: EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      'Suggerimenti',
                      style: TextStyle(color: Colors.grey),
                    )),
              Wrap(
                alignment: WrapAlignment.start,
                children: suggestedTags
                    .map((tag) => tagItem(
                          tagModel: tag,
                          onTap: () => addTag(tag),
                          action: 'Add',
                        ))
                    .toList(),
              ),
            ])
          : Container(),
    );
  }

  Widget tagItem({
    tagModel,
    onTap,
    action,
  }) {
    return InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 5.0,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Text(
                  tagModel.name,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              child: CircleAvatar(
                backgroundColor:
                    action == 'Add' ? Colors.blue : Colors.red.shade600,
                radius: 8.0,
                child: Icon(
                  action == 'Add' ? Icons.add : Icons.remove,
                  size: 10.0,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ));
  }

  Widget tagSearchFieldWidget() {
    return Container(
      padding: EdgeInsets.only(
        left: 20.0,
        top: 10.0,
        bottom: 10.0,
      ),
      margin: EdgeInsets.only(
        top: 20.0,
        bottom: 5.0,
      ),
      decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          border: Border.all(color: Colors.transparent, width: 1.5)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              scrollPadding: const EdgeInsets.only(bottom: 100.0),
              controller: _searchTextEditingController,
              decoration: InputDecoration.collapsed(
                hintText: 'Cerca o inserisci tag',
                hintStyle: TextStyle(
                  color: Colors.grey,
                ),
              ),
              style: TextStyle(
                fontSize: 16.0,
              ),
              textInputAction: TextInputAction.search,
            ),
          ),
          _searchText.isNotEmpty
              ? InkWell(
                  child: Icon(
                    Icons.clear,
                    color: Colors.grey.shade700,
                  ),
                  onTap: () => _searchTextEditingController.clear(),
                )
              : Icon(
                  Icons.search,
                  color: Colors.grey.shade700,
                ),
          Container(
            width: 15,
          ),
        ],
      ),
    );
  }

  Widget tagWidget() {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          suggestionWidget(),
          Container(
            margin: EdgeInsets.only(left: 5, top: 15),
            child: Text(
              "Tag",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF979797),
                letterSpacing: 0.2,
              ),
            ),
          ),
          tagSearchFieldWidget(),
          selectedTags.length > 0
              ? Column(children: [
                  SizedBox(
                    height: 15,
                  ),
                  Wrap(
                    alignment: WrapAlignment.start,
                    children: selectedTags
                        .map((tagModel) => tagItem(
                              tagModel: tagModel,
                              onTap: () => removeTag(tagModel),
                              action: 'Remove',
                            ))
                        .toSet()
                        .toList(),
                  ),
                ])
              : Container(
                  margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: Text(
                    'Nessun tag inserito',
                    style: TextStyle(color: Colors.grey),
                  )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    FileItem folder = arguments['repository'];
    String type = folder.type;
    var groupList = Provider.of<GroupProvider>(context).groupList;
    var userList = Provider.of<UsersProvider>(context).usersList;

    if (init) {
      init = false;

      selectedTags = [];

      folder.tagList.forEach((tag) {
        selectedTags.add(tag);
        _submitData['tags'].add(tag.id);
      });

      if (groupList.isNotEmpty) {
        groupData = [];
        groupList.forEach((group) {
          groupData.add({'name': group.name, 'id': group.groupid});
        });
      }

      if (userList.isNotEmpty) {
        userData = [];
        userList.forEach((user) {
          userData.add({'name': user.name, 'id': user.userid});
        });
      }
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Stack(children: [
        Column(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                colors: [
                  Color(0xFF3bbddc),
                  Color(0xFF0375fe),
                ],
                begin: Alignment.topLeft,
                end: Alignment.topRight,
              )),
            ),
            Container(
              height: mediaQuery.height - 200,
              color: Colors.grey.shade100,
            ),
          ],
        ),
        Scaffold(
          appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.white),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              centerTitle: true,
              title: Text(
                type == FileItem.TYPE_FILE
                    ? 'Modifica File'
                    : 'Modifica Cartella',
                style: Theme.of(context).textTheme.headline1,
              )),
          backgroundColor: Colors.transparent,
          body: Container(
            margin: EdgeInsets.only(top: 10),
            child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45)),
                child: Card(
                    margin: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(45),
                            topRight: Radius.circular(45))),
                    elevation: 0.0,
                    color: Colors.grey.shade100,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 50,
                              ),
                              Container(
                                width: 300,
                                child: Text(
                                  'COMPILARE I CAMPI\nCHE SI VOGLIONO MODIFICARE',
                                  style: TextStyle(
                                      fontSize: 19,
                                      color: Colors.grey.shade800),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                                width: double.infinity,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 50),
                                child: Container(
                                  width: 150,
                                  height: 3,
                                  color: Colors.blue.shade400,
                                ),
                              ),
                              SizedBox(
                                height: 35,
                              ),
                              if (type == FileItem.TYPE_FILE)
                                Container(
                                  height: 60,
                                  child: Row(
                                    children: [
                                      Flexible(
                                        flex: 6,
                                        fit: FlexFit.tight,
                                        child: TextFormField(
                                          key: Key('$fileName 2'),
                                          autocorrect: false,
                                          cursorColor:
                                              Theme.of(context).primaryColor,
                                          textCapitalization:
                                              TextCapitalization.none,
                                          initialValue: fileName,
                                          decoration: InputDecoration(
                                              disabledBorder:
                                                  OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(10),
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      10)),
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .transparent,
                                                          width: 1.5)),
                                              filled: true,
                                              enabled: false,
                                              hintStyle: TextStyle(
                                                  color: Color(0xFF979797)),
                                              hintText: 'Scegli il file*'),
                                          style: TextStyle(
                                              color: Color(0xFF979797)),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 4,
                                        fit: FlexFit.tight,
                                        child: Container(
                                          height: double.infinity,
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topRight: Radius
                                                                .circular(10),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10))),
                                                primary: Colors.blue,
                                              ),
                                              onPressed: () async {
                                                FilePickerResult? result =
                                                    await FilePicker.platform
                                                        .pickFiles();
                                                if (result != null) {
                                                  file = File(result
                                                      .files.single.path!);
                                                  print(
                                                      '___FILE PATH: ${file.path}');
                                                  print(
                                                      '___FILE NAME: ${result.files.single.name}');
                                                  setState(() {
                                                    fileName = result
                                                        .files.single.name;
                                                  });
                                                } else {
                                                  file = null;
                                                  fileName = '';
                                                }
                                              },
                                              child: Text('Seleziona')),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              if (type == FileItem.TYPE_FILE)
                                SizedBox(
                                  height: 15,
                                ),
                              TextFormField(
                                key: Key('${folder.name}1'),
                                autocorrect: false,
                                cursorColor: Theme.of(context).primaryColor,
                                textCapitalization: TextCapitalization.none,
                                initialValue: folder.name,
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
                                    hintText: 'Nome'),
                                onSaved: (value) {
                                  _submitData['name'] = value!;
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Scrivi qualcosa';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              MultiSelectFormField(
                                autovalidate: false,
                                checkBoxCheckColor:
                                    Theme.of(context).primaryColor,
                                dialogShapeBorder: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                title: Text(
                                  "Gruppi",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF979797),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                dataSource: groupData,
                                textField: 'name',
                                valueField: 'id',
                                okButtonLabel: 'OK',
                                cancelButtonLabel: 'ANNULLA',
                                hintWidget: Text(
                                  'Inserisci gruppi',
                                  style: TextStyle(
                                    color: Color(0xFF979797),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                initialValue: folder.groupsId,
                                onSaved: (groups) {
                                  _submitData['groups'] = [];
                                  groups.forEach((element) {
                                    _submitData['groups'].add(element);
                                  });
                                  print(_submitData['groups'].toString());
                                },
                                border: InputBorder.none,
                                fillColor: Colors.grey.shade200,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              MultiSelectFormField(
                                autovalidate: false,
                                checkBoxCheckColor:
                                    Theme.of(context).primaryColor,
                                dialogShapeBorder: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                title: Text(
                                  "Utenti",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF979797),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                dataSource: userData,
                                textField: 'name',
                                valueField: 'id',
                                okButtonLabel: 'OK',
                                cancelButtonLabel: 'ANNULLA',
                                hintWidget: Text(
                                  'Inserisci utenti',
                                  style: TextStyle(
                                    color: Color(0xFF979797),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                initialValue: folder.usersId,
                                onSaved: (groups) {
                                  _submitData['users'] = [];
                                  groups.forEach((element) {
                                    _submitData['users'].add(element);
                                  });
                                  print(_submitData['users'].toString());
                                },
                                border: InputBorder.none,
                                fillColor: Colors.grey.shade200,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    border: Border.all(
                                        color: Colors.transparent, width: 1.5)),
                                child: Row(
                                  children: [
                                    tagWidget(),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 45,
                              ),
                              if (status == Status.LOADING)
                                Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF0375fe),
                                  ),
                                ),
                              if (status == Status.DEFAULT)
                                Container(
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                        elevation: MaterialStateProperty.all(3),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                          Colors.blue,
                                        )),
                                    onPressed: () {
                                      var isValid =
                                          _formKey.currentState!.validate();
                                      FocusScope.of(context).unfocus();
                                      if (isValid) {
                                        _formKey.currentState!.save();
                                        if (type == FileItem.TYPE_FOLDER)
                                          editFolder(
                                            context,
                                            folder.repoid,
                                          );
                                        else
                                          editFile(context, type, folder.repoid,
                                              file);
                                      }
                                    },
                                    child: Center(
                                        child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          (Icons.add_circle_outline),
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'SALVA',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    )),
                                  ),
                                ),
                              if (status == Status.DONE)
                                Container(
                                  height: 50,
                                  color: Colors.green,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.done,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'FATTO',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              SizedBox(
                                height: 50,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ))),
          ),
        ),
      ]),
    );
  }
}
