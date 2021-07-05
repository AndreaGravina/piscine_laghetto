import 'package:flutter/material.dart';
import 'package:piscine_laghetto/screens/user_detail_screen.dart';
import '../providers/users_provider.dart';
import './user_listitem.dart';
import 'package:provider/provider.dart';

class AdminListView extends StatefulWidget {
  const AdminListView({Key? key}) : super(key: key);

  @override
  _AdminListViewState createState() => _AdminListViewState();
}

class _AdminListViewState extends State<AdminListView> {
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
      Provider.of<UsersProvider>(context, listen: false).getMoreUsers(UserClass.ROLE_ADMIN);
    }
  }

  @override
  Widget build(BuildContext context) {
    var admins = Provider.of<UsersProvider>(context).adminsList;

    return ListView.builder(
        itemCount: admins.length + 1,
        itemBuilder: (ctx, index) {
          if (index == admins.length)
            return Container(
              height: 90,
            );
          else
            return InkWell(onTap: () => {
               Navigator.of(context).pushNamed(UserDetailScreen.routeName, arguments: admins[index].userid)
            }, 
            child: UserListItem(admins[index]));
        });
  }
}
