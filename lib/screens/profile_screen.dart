import 'package:flutter/material.dart';
import 'package:piscine_laghetto/providers/auth_status.dart';
import 'package:piscine_laghetto/screens/admin_management_screen.dart';
import 'package:piscine_laghetto/screens/group_management_screen.dart';
import 'package:piscine_laghetto/screens/login_screen.dart';
import 'package:piscine_laghetto/screens/user_management_screen.dart';
import 'package:piscine_laghetto/widgets/support_dialog.dart';
import 'package:provider/provider.dart';
import '../global_class.dart' as Globals;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  static const routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    var userInfo = Provider.of<AuthStatus>(context).userInfo;
    var username = userInfo['username'];
    var name = userInfo['name'];
    var surname = userInfo['surname'];
    var isAdmin = Globals.isAdmin;
    return Stack(children: [
      Container(
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
      Scaffold(
        appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
            title: Text(
              'Profilo',
              style: Theme.of(context).textTheme.headline1,
            )),
        backgroundColor: Colors.transparent,
        body: Container(
            margin: EdgeInsets.only(top: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(45), topRight: Radius.circular(45)),
              child: Card(
                margin: EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(45),
                        topRight: Radius.circular(45))),
                elevation: 0.0,
                color: Colors.grey.shade100,
                child: ListView(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 25, bottom: 15, left: 25),
                      color: Colors.white,
                      child: Text(
                        'INFORMAZIONI PROFILO',
                        style: Theme.of(context)
                            .textTheme
                            .headline2
                      ),
                    ),
                    Container(
                      color: Color(0xFF4dd2ff),
                      width: double.infinity,
                      height: 3,
                    ),
                    InfoBox(
                      title: 'USERNAME',
                      content: username.toString(),
                    ),
                    Divider(
                      height: 0,
                      color: Colors.grey,
                    ),
                    InfoBox(
                      title: 'NAME',
                      content: name.toString(),
                    ),
                    Divider(
                      height: 0,
                      color: Colors.grey,
                    ),
                    InfoBox(
                      title: 'SURNAME',
                      content: surname.toString(),
                    ),
                    Divider(
                      height: 0,
                      color: Colors.grey,
                    ),
                    InkWell(
                      onTap: () {
                        Provider.of<AuthStatus>(context, listen: false)
                            .logout();
                        Navigator.of(context).pop();
                        Navigator.of(context)
                            .pushReplacementNamed(LoginScreen.routeName);
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                            top: 15, bottom: 15, left: 25, right: 25),
                        color: Colors.white,
                        child: Row(
                          children: [
                            Text(
                              'ESCI',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4!
                                  .apply(fontSizeDelta: 2),
                            ),
                            Expanded(
                              child: Container(),
                            ),
                            Icon(
                              Icons.logout,
                              size: 25,
                              color: Colors.red,
                            )
                          ],
                        ),
                      ),
                    ),
                    if (isAdmin) AdminActions(),
                    Container(
                      color: Colors.grey.shade100,
                      width: double.infinity,
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 25, bottom: 15, left: 25),
                      color: Colors.white,
                      child: Text(
                        'HAI BISOGNO DI AIUTO?',
                        style: Theme.of(context)
                            .textTheme
                            .headline2,
                      ),
                    ),
                    Container(
                      color: Color(0xFF4dd2ff),
                      width: double.infinity,
                      height: 3,
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) => SupportDialog());
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                            top: 15, bottom: 15, left: 25, right: 25),
                        child: Row(
                          children: [
                            Text(
                              'CONTATTACI',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4
                            ),
                            Expanded(
                              child: Container(),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 15,
                            )
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      height: 0,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            )),
      ),
    ]);
  }
}

class InfoBox extends StatelessWidget {
  const InfoBox({
    required this.title,
    required this.content,
    Key? key,
  }) : super(key: key);

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 15, bottom: 15, left: 25, right: 25),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headline4!.apply(
                  color: Colors.grey,
                ),
          ),
          Expanded(
            child: Container(),
          ),
          Text(
            content,
            style: Theme.of(context).textTheme.headline4!.apply(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }
}

class AdminActions extends StatelessWidget {
  const AdminActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: [
      Container(
        color: Colors.grey.shade100,
        width: double.infinity,
        height: 10,
      ),
      Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(top: 25, bottom: 15, left: 25),
        color: Colors.white,
        child: Text(
          'SEZIONE ADMIN',
          textAlign: TextAlign.left,
          style:
              Theme.of(context).textTheme.headline2,
        ),
      ),
      Container(
        color: Color(0xFF4dd2ff),
        width: double.infinity,
        height: 3,
      ),
      InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(AdminManagementScreen.routeName);
          },
          child: Container(
            padding: EdgeInsets.only(top: 15, bottom: 15, left: 25, right: 25),
            color: Colors.white,
            child: Row(
              children: [
                Text(
                  'GESTIONE ADMIN',
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                ),
                Expanded(
                  child: Container(),
                ),
                Icon(
                  Icons.lock_outline,
                  size: 25,
                  color: Color(0xff158cf2),
                )
              ],
            ),
          )),
      Divider(
        height: 0,
        color: Colors.grey,
      ),
      InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(GroupManagementScreen.routeName);
          },
          child: Container(
            padding: EdgeInsets.only(top: 15, bottom: 15, left: 25, right: 25),
            color: Colors.white,
            child: Row(
              children: [
                Text(
                  'GESTIONE GRUPPI',
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                ),
                Expanded(
                  child: Container(),
                ),
                Container(
                  width: 0,
                  transform: Matrix4.rotationZ(1.5),
                  child: Icon(
                    Icons.call_split,
                    size: 25,
                    color: Color(0xff158cf2),
                  ),
                )
              ],
            ),
          )),
      Divider(
        height: 0,
        color: Colors.grey,
      ),
      InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(UserManagementScreen.routeName);
          },
          child: Container(
            padding: EdgeInsets.only(top: 15, bottom: 15, left: 25, right: 25),
            color: Colors.white,
            child: Row(
              children: [
                Text(
                  'GESTIONE UTENTI',
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                ),
                Expanded(
                  child: Container(),
                ),
                Icon(
                  Icons.group_outlined,
                  size: 25,
                  color: Color(0xff158cf2),
                )
              ],
            ),
          )),
    ]));
  }
}
