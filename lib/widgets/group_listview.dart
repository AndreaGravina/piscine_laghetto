import 'package:flutter/material.dart';
import '../providers/group_provider.dart';
import './group_listitem.dart';
import 'package:provider/provider.dart';

class GroupListView extends StatefulWidget {
  const GroupListView({Key? key}) : super(key: key);

  @override
  _GroupListViewState createState() => _GroupListViewState();
}

class _GroupListViewState extends State<GroupListView> {

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
      Provider.of<GroupProvider>(context, listen: false).getMoreGroups();
    }
  }

  @override
  Widget build(BuildContext context) {
     var groups = Provider.of<GroupProvider>(context).groupList;

    return ListView.builder(
        itemCount: groups.length + 1,
        controller: controller,
        itemBuilder: (ctx, index) {
          if (index == groups.length)
            return Container(
              height: 90,
            );
          else
            return InkWell(
                onTap: () => {}, child: GroupListItem(groups[index]));
        });
  }
}
