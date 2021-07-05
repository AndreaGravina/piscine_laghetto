import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:piscine_laghetto/providers/file_provider.dart';
import 'package:piscine_laghetto/widgets/custom_dialog.dart';
import '../global_class.dart' as Globals;
import 'package:piscine_laghetto/providers/users_provider.dart';
import 'package:piscine_laghetto/widgets/user_info_view.dart';
import 'package:piscine_laghetto/widgets/user_stats_view.dart';

class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({Key? key}) : super(key: key);

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();

  static const routeName = '/user-detail';
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  List<FileItem> fileList = [];
  bool init = true;

  var user = UserClass(
      userid: 0,
      roleidfk: null,
      name: '',
      surname: '',
      email: '',
      username: '',
      businessName: '',
      vatNumber: '',
      status: 0,
      countLogin: 0,
      groups: '',
      groupsId: []);

  Future<void> loadUserDetail(int userId, {int retry = 0}) async {

    var response = await http.post(
        Uri.parse('${Globals.URL}api/v1/detail-user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Globals.token}'
        },
        body: jsonEncode({
          'user_id': userId,
          'log': {'logid': Globals.logid, 'time': Globals.time}
        }));

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body) as Map<String, dynamic>;
      Map<String, dynamic> userData = body['user'];
      bool success = body['success'];

      if (!success) {
        print('___HTTP USER DETAIL FALSE');
        String message = body['message'];
        showDialog(
            context: context,
            builder: (context) => CustomDialog(title: 'ERRORE', text: message));
      } else {
          Globals.updateLog(body['log']['logid'], body['log']['time']);

        user = UserClass(
            userid: userData['userid'],
            roleidfk: userData['roleidfk'],
            name: userData['name'],
            surname: userData['surname'],
            email: userData['email'],
            username: userData['username'],
            businessName: userData['business_name'],
            vatNumber: userData['vat_number'],
            status: userData['status'],
            countLogin: userData['count_login'],
            groups: userData['groups'],
            groupsId: userData['ids_groups'],
            creationDate: userData['creation_date'],
            lastAccess: userData['last_access']);

        List<dynamic> fileData = body['files'];
        fileList = [];

        fileData.forEach((element) {
          fileList.add(FileItem(
            repoid: int.parse(element['logid']),
            folderidfk: element['folderidfk'],
            type: 'File',
            open: 0,
            name: element['filename'],
            extension: element['extension'],
            size: element['size'],
            path: element['path'],
            updateDate: element['creation_date'],
            //tagsId: element['id_tags']
          ));
        });

        print('___LOAD USER DETAIL SUCCESS');
      }
    } else if (response.statusCode == 401 && retry == 0) {
      await Globals.refreshToken()
          .whenComplete(() => loadUserDetail(userId, retry: 1));
    } else {
      print('___HTTP ERROR USER DETAIL');
      throw Exception('___HTTP REQUEST FAILED');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final userId = ModalRoute.of(context)!.settings.arguments as int;

    if (init)
      loadUserDetail(userId).whenComplete(() {
        setState(() {
          init = !init;
        });
      });

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(
              'Dettagli Utente',
              style: Theme.of(context).textTheme.headline1,
            ),
            centerTitle: true,
            bottom: TabBar(tabs: [
              Tab(
                icon: Icon(Icons.info),
                text: 'Informazioni',
              ),
              Tab(
                icon: Icon(Icons.query_stats),
                text: 'Statistiche',
              )
            ]),
          ),
          backgroundColor: Colors.white,
          body: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: TabBarView(children: [
              UserInfoView(
                user: user,
              ),
              UserStatsView(
                user: user,
                fileList: fileList,
              )
            ]),
          ),
        ),
      ),
    );
  }
}
