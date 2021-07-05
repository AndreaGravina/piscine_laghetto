import 'package:piscine_laghetto/screens/edit_user_screen.dart';

import '../providers/users_provider.dart';
import '../widgets/delete_dialog.dart';
import 'package:flutter/material.dart';

class UserListItem extends StatelessWidget {
  const UserListItem(this.user, {Key? key}) : super(key: key);

  final UserClass user;

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
                child: Icon(Icons.account_circle,
                    size: 45, color: const Color(0xFF1c96ee)),
              ),
              Flexible(fit: FlexFit.tight, flex: 1, child: Text(user.name)),
              Flexible(fit: FlexFit.tight, flex: 1, child: Text(user.surname)),
              Container(
                width: 50,
                alignment: Alignment.center,
                child: IconButton(
                  splashRadius: 20,
                  icon: Icon(Icons.edit,
                      size: 30, color: const Color(0xFF1c96ee)),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      EditUserScreen.routeName,
                      arguments: {
                        'user': user,
                      },
                    );
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
                        builder: (context) => DeleteDialog(
                            id: user.userid,
                            role: user.roleidfk,
                            type: 'User'));
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
