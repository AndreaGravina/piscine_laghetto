import 'package:piscine_laghetto/screens/user_detail_screen.dart';

import '../providers/users_provider.dart';
import '../widgets/user_listitem.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserListView extends StatefulWidget {
  const UserListView({Key? key}) : super(key: key);

  @override
  _UserListViewState createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  late ScrollController controller;

  @override
  void initState() {
    super.initState();
    controller = ScrollController()..addListener(() => scrollCheck());
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void scrollCheck() {
    if (controller.position.maxScrollExtent == controller.offset) {
      Provider.of<UsersProvider>(context, listen: false).getMoreUsers(UserClass.ROLE_USER);
    }
  }

  @override
  Widget build(BuildContext context) {
    var users = Provider.of<UsersProvider>(context).usersList;

    return ListView.builder(
        itemCount: users.length,
        itemBuilder: (ctx, index) {
          if (index == users.length)
            return Container(
              height: 90,
            );
          else
            return InkWell(onTap: () => {
              Navigator.of(context).pushNamed(UserDetailScreen.routeName, arguments: users[index].userid)
            }, child: UserListItem(users[index]));
        });
  }
}
