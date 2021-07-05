import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/file_provider.dart';
import '../providers/group_provider.dart';
import '../providers/users_provider.dart';
import './custom_dialog.dart';
import '../global_class.dart' as Globals;

enum Status { DEFAULT, LOADING, DONE }

class DeleteDialog extends StatefulWidget {
  DeleteDialog({required this.id, this.role = 0, required this.type});

  final int id;
  final int role;
  final String type;

  @override
  _DeleteDialogState createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  Status status = Status.DEFAULT;

  Future<void> deleteUser(context, {int retry = 0}) async {
    setState(() {
      status = Status.LOADING;
    });
    var response = await http.post(Uri.parse('${Globals.URL}api/v1/delete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Globals.token}'
        },
        body: jsonEncode({
          'id': widget.id,
          'type': widget.type,
          'log': {'logid': Globals.logid, 'time': Globals.time}
        }));

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body) as Map<String, dynamic>;
      bool success = body['success'];
      if (!success) {
        print('___HTTP DELETE SUCCESS FALSE');
        String message = body['message'];
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) => CustomDialog(title: 'ERRORE', text: message));
        setState(() {
          status = Status.DEFAULT;
        });
      } else {
        Globals.updateLog(body['log']['logid'], body['log']['time']);
        print('___DELETE SUCCESS');
        setState(() {
          status = Status.DONE;
        });
      }
    } else if (response.statusCode == 401 && retry == 0) {
      print('___TRY REFRESH TOKEN');
      await Globals.refreshToken()
          .whenComplete(() => deleteUser(context, retry: 1));
    } else {
      print('___HTTP ERROR DELETE USER');
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) => CustomDialog(
              title: 'ERRORE',
              text: 'Qualcosa è andato storto, riprova più tardi'));
      setState(() {
        status = Status.DEFAULT;
      });
    }
    if (widget.type == 'User') {
      Provider.of<UsersProvider>(context, listen: false)
          .getUsers(UserClass.ROLE_USER);
      Provider.of<UsersProvider>(context, listen: false)
          .getUsers(UserClass.ROLE_ADMIN);
    } else if (widget.type == 'Group')
      Provider.of<GroupProvider>(context, listen: false).getGroups();
    else if (widget.type == 'Repository') {
      var currentFolderId =
          Provider.of<FileProvider>(context, listen: false).currentFolderId;
      Provider.of<FileProvider>(context, listen: false)
          .getFiles(folderidfk: currentFolderId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      content: Container(
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).primaryColor,
              size: 70,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              'Sei sicuro?',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Non potrai tornare indietro',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 30,
            ),
            if (status == Status.DEFAULT)
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Theme.of(context).primaryColor,
                  ),
                ),
                onPressed: () {
                  deleteUser(context);
                },
                child: Container(
                    width: double.infinity,
                    child: Center(
                        child: Text(
                      'Si, procedi',
                      style: TextStyle(color: Colors.white),
                    ))),
              ),
            if (status == Status.DEFAULT)
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                    width: double.infinity,
                    child: Center(
                        child: Text(
                      'Annulla',
                      style: TextStyle(color: Colors.white),
                    ))),
              ),
            if (status == Status.LOADING || status == Status.DONE)
              SizedBox(
                height: 20,
              ),
            if (status == Status.LOADING)
              Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF0375fe),
                ),
              ),
            if (status == Status.DONE)
              Container(
                height: 50,
                color: Colors.green,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
          ],
        ),
      ),
    );
  }
}
