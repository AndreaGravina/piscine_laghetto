import 'dart:async';
import 'package:flutter/material.dart';
import 'package:piscine_laghetto/providers/file_provider.dart';
import 'package:piscine_laghetto/providers/group_provider.dart';
import 'package:piscine_laghetto/providers/notification_provider.dart';
import 'package:piscine_laghetto/providers/users_provider.dart';
import 'package:piscine_laghetto/screens/notification_screen.dart';
import 'package:piscine_laghetto/screens/profile_screen.dart';
import 'package:piscine_laghetto/widgets/add_dialog.dart';
import 'package:piscine_laghetto/widgets/file_view.dart';
import 'package:provider/provider.dart';
import '../global_class.dart' as Globals;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();

  static const routeName = '/home';
}

class _HomeScreenState extends State<HomeScreen> {
  var listView = false;
  final _searchController = TextEditingController();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    if (Globals.isAdmin) {
      Provider.of<UsersProvider>(context, listen: false)
          .getAllUsers(UserClass.ROLE_USER);
      Provider.of<GroupProvider>(context, listen: false).getAllGroups();
    }
    Provider.of<FileProvider>(context, listen: false).getFiles();
    Provider.of<NotificationProvider>(context, listen: false).getNotification();
    timer = Timer.periodic(
        Duration(seconds: 15),
        (Timer t) => Provider.of<NotificationProvider>(context, listen: false)
            .getNotification());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    var currentFolder = Provider.of<FileProvider>(context).currentFolder;
    var currentFolderId = Provider.of<FileProvider>(context).currentFolderId;
    var parent = Provider.of<FileProvider>(context).parent;
    var checkNotification = Provider.of<NotificationProvider>(context).check;
    var isAdmin = Globals.isAdmin;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Stack(
        children: [
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
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              toolbarHeight: 0,
              title: Container(),
              elevation: 0.0,
            ),
            backgroundColor: Colors.transparent,
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: isAdmin
                ? Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    height: 70,
                    width: 70,
                    padding: EdgeInsets.all(1),
                    child: FloatingActionButton(
                      backgroundColor: const Color(0xFF0375fe),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => AddDialog());
                      },
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  )
                : null,
            body: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 40,
                            child: GestureDetector(
                              onTap: () => Provider.of<FileProvider>(context,
                                      listen: false)
                                  .getFiles(),
                              child: Image.asset(
                                'images/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(),
                          ),
                          Container(
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                IconButton(
                                    splashRadius: 18,
                                    padding: EdgeInsets.all(0),
                                    iconSize: 30,
                                    color: Colors.white,
                                    onPressed: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      Navigator.of(context).pushNamed(
                                          NotificationScreen.routeName);
                                    },
                                    icon: checkNotification
                                        ? Icon(
                                            Icons.notification_important_sharp,
                                          )
                                        : Icon(Icons.notifications_none)),
                                if (checkNotification)
                                  Container(
                                    margin:
                                        EdgeInsets.only(right: 10, bottom: 10),
                                    child: Icon(
                                      Icons.circle,
                                      color: Colors.red,
                                      size: 11,
                                    ),
                                  )
                              ],
                            ),
                          ),
                          IconButton(
                              splashRadius: 18,
                              padding: EdgeInsets.all(0),
                              iconSize: 30,
                              color: Colors.white,
                              onPressed: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                Navigator.of(context)
                                    .pushNamed(ProfileScreen.routeName);
                              },
                              icon: Icon(Icons.settings_outlined))
                        ],
                      ),
                      SizedBox(
                        height: 27,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 45,
                            width: mediaQuery.width * 0.7,
                            child: TextField(
                                controller: _searchController,
                                onSubmitted: (value) =>
                                    Provider.of<FileProvider>(context,
                                            listen: false)
                                        .getFiles(search: value),
                                cursorColor: Theme.of(context).primaryColor,
                                textAlignVertical: TextAlignVertical.bottom,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3
                                    ?.apply(
                                      color: Colors.black,
                                    ),
                                decoration: new InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 1.5)),
                                  suffixIcon: IconButton(
                                      onPressed: () {
                                        Provider.of<FileProvider>(context,
                                                listen: false)
                                            .getFiles(
                                                search: _searchController.text);
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
                                      icon: Icon(Icons.search,
                                          color: Colors.black)),
                                  border: new OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(10.0),
                                    ),
                                  ),
                                  filled: true,
                                  hintStyle:
                                      TextStyle(color: Color(0xFF979797)),
                                  hintText: "Cerca...",
                                  fillColor: Colors.white,
                                )),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          IconButton(
                              splashRadius: 18,
                              padding: EdgeInsets.all(0),
                              iconSize: 35,
                              color: Colors.white,
                              onPressed: () {
                                setState(() {
                                  listView = !listView;
                                });
                              },
                              icon: listView
                                  ? Icon(
                                      Icons.grid_view,
                                    )
                                  : Icon(
                                      Icons.view_list,
                                    )),
                          SizedBox(
                            width: 5,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _searchController.text = '';
                      if (parent != null)
                        Provider.of<FileProvider>(context, listen: false)
                            .getFiles(folderidfk: parent.repoid);
                      else
                        Provider.of<FileProvider>(context, listen: false)
                            .getFiles();
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.white,
                        Color(0xFFe8f0fe),
                      ], begin: Alignment.topCenter, end: Alignment(0, 1.5)),
                    ),
                    height: 60,
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (currentFolder != null)
                          IconButton(
                              constraints:
                                  BoxConstraints(minWidth: 50, maxWidth: 50),
                              onPressed: () {
                                setState(() {
                                  if (parent != null)
                                    Provider.of<FileProvider>(context,
                                            listen: false)
                                        .getFiles(folderidfk: parent.repoid);
                                  else
                                    Provider.of<FileProvider>(context,
                                            listen: false)
                                        .getFiles();
                                });
                              },
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                              )),
                        SizedBox(
                          width: currentFolder != null ? 0 : 50,
                        ),
                        Text(
                          currentFolder != null ? currentFolder.name : 'HOME',
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 5,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    colors: [
                      Color(0xFF3bbddc),
                      Color(0xFF0375fe),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )),
                ),
                if (listView)
                  Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Container(
                            height: 45,
                            child: Row(
                              children: [
                                Flexible(
                                    fit: FlexFit.tight,
                                    flex: 9,
                                    child: Container(
                                        padding: EdgeInsets.only(left: 15),
                                        child: Text('Nome'))),
                                Flexible(
                                    fit: FlexFit.tight,
                                    flex: 5,
                                    child: Text('Ultima modifica')),
                                Flexible(
                                    fit: FlexFit.tight,
                                    flex: 3,
                                    child: Text('Peso')),
                                Flexible(
                                    fit: FlexFit.tight,
                                    flex: 2,
                                    child: Container()),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Divider(
                            height: 0,
                          )
                        ],
                      )),
                Expanded(
                    child: RefreshIndicator(
                        onRefresh: () async {
                          Provider.of<FileProvider>(context, listen: false)
                              .getFiles(
                                  folderidfk: currentFolderId,
                                  search: _searchController.text);
                          Provider.of<NotificationProvider>(context,
                                  listen: false)
                              .getNotification();
                        },
                        child: Stack(
                          children: [
                            Container(
                              color: Colors.white,
                            ),
                            FileView(
                              listView: listView,
                              stats: false,
                            ),
                          ],
                        ))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
