import 'package:flutter/material.dart';
import '../providers/group_provider.dart';
import './delete_dialog.dart';
import './edit_group_dialog.dart';

class GroupListItem extends StatelessWidget {
  const GroupListItem(this.group, {Key? key}) : super(key: key);

  final GroupItem group;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(),
          ),
          Row(
            children: [
              Flexible(
                fit: FlexFit.tight,
                flex: 1,
                child: Icon(Icons.supervised_user_circle,
                    size: 45, color: const Color(0xFF1c96ee)),
              ),
              Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: Text(group.groupid.toString())),
              Flexible(fit: FlexFit.tight, flex: 1, child: Text(group.name)),
              Container(
                width: 50,
                alignment: Alignment.center,
                child: IconButton(
                  splashRadius: 20,
                  icon: Icon(Icons.edit,
                      size: 30, color: const Color(0xFF1c96ee)),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => EditGroupDialog(group));
                  },
                ),
              ),
              Container(
                width: 50,
                child: IconButton(
                  splashRadius: 20,
                  icon: Icon(Icons.delete,
                      size: 30, color: const Color(0xFF1c96ee)),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) =>
                            DeleteDialog(id: group.groupid, type: 'Group'));
                  },
                ),
              ),
              SizedBox(
                width: 10,
              )
            ],
          ),
          Expanded(
            child: Container(),
          ),
          Divider(
            height: 0,
          )
        ],
      ),
    );
  }
}
