import 'package:flutter/material.dart';
import 'package:piscine_laghetto/providers/group_provider.dart';
import 'package:piscine_laghetto/providers/users_provider.dart';
import 'package:piscine_laghetto/screens/new_user_screen.dart';
import 'package:piscine_laghetto/widgets/admin_listview.dart';
import 'package:provider/provider.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({Key? key}) : super(key: key);

  @override
  _AdminManagementScreenState createState() => _AdminManagementScreenState();

  static const routeName = '/admin-management';
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<UsersProvider>(context, listen: false).getUsers(UserClass.ROLE_ADMIN);
    Provider.of<GroupProvider>(context, listen: false).getAllGroups();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Color(0xff229dec),
          toolbarHeight: 0,
          title: Container(),
          elevation: 0.0,
        ),
        backgroundColor: Colors.white,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Container(
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          height: 70,
          width: 70,
          padding: EdgeInsets.all(1),
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF0375fe),
            onPressed: () {
              Navigator.of(context).pushNamed(NewUserScreen.routeName, arguments: UserClass.ROLE_ADMIN);
            },
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 5, bottom: 20, left: 5),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                colors: [
                  Color(0xFF3bbddc),
                  Color(0xFF0375fe),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        alignment: Alignment.center,
                        child: Text(
                          'Gestione Admin',
                          style: Theme.of(context).textTheme.headline1,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 27,
                  ),
                  Container(
                    height: 45,
                    width: mediaQuery.width * 0.9,
                    child: TextField(
                        controller: _searchController,
                        onSubmitted: (value) =>
                            Provider.of<UsersProvider>(context, listen: false)
                                .getUsers(2, search: value),
                        cursorColor: Theme.of(context).primaryColor,
                        textAlignVertical: TextAlignVertical.bottom,
                        style: Theme.of(context).textTheme.headline3,
                        decoration: new InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 1.5)),
                          suffixIcon: IconButton(
                              splashRadius: 5,
                              onPressed: () {},
                              icon: Icon(Icons.search, color: Colors.black)),
                          border: new OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            ),
                          ),
                          filled: true,
                          hintStyle: TextStyle(color: Color(0xFF979797)),
                          hintText: "Cerca admin...",
                          fillColor: Colors.white,
                        )),
                  ),
                ],
              ),
            ),
            Container(
                child: Column(
              children: [
                Container(
                  height: 65,
                  child: Row(
                    children: [
                      Flexible(
                          fit: FlexFit.tight,
                          flex: 1,
                          child: Container(child: Container())),
                      Flexible(
                          fit: FlexFit.tight,
                          flex: 1,
                          child: Container(child: Text('Nome'))),
                      Flexible(
                          fit: FlexFit.tight,
                          flex: 1,
                          child: Container(child: Text('Cognome'))),
                      SizedBox(
                        width: 110,
                      )
                    ],
                  ),
                ),
                Divider(
                  height: 0,
                )
              ],
            )),
            Expanded(child: AdminListView()),
          ],
        ),
      ),
    );
  }
}
