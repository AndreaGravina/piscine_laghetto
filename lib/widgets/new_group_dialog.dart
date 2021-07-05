import '../providers/group_provider.dart';
import '../widgets/custom_dialog.dart';
import '../global_class.dart' as Globals;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

enum Status { DEFAULT, LOADING, DONE }

class NewGroupDialog extends StatefulWidget {
  @override
  _NewGroupDialogState createState() => _NewGroupDialogState();
}

class _NewGroupDialogState extends State<NewGroupDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  dynamic groupName;
  Status status = Status.DEFAULT;

  Future<void> saveGroup(context, {int retry = 0}) async {
    setState(() {
      status = Status.LOADING;
    });

    var response = await http.post(Uri.parse('${Globals.URL}api/v1/save-group'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Globals.token}'
        },
        body: jsonEncode({
          'name': groupName,
          'log': {'logid': Globals.logid, 'time': Globals.time}
        }));

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body) as Map<String, dynamic>;
      bool success = body['success'];
      if (!success) {
        print('___HTTP WARNING EDIT GROUP');
        String message = body['message'];
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) => CustomDialog(title: 'ERRORE', text: message));
        setState(() {
          status = Status.DEFAULT;
        });
      }
      Globals.updateLog(body['log']['logid'], body['log']['time']);
      print('___EDIT GROUP SUCCESS');
      setState(() {
        status = Status.DONE;
      });
    } else if (response.statusCode == 401 && retry == 0) {
      print('___TRY REFRESH TOKEN');
      await Globals.refreshToken()
          .whenComplete(() => saveGroup(context, retry: 1));
    } else {
      print('___HTTP ERROR EDIT GROUP');
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
    Provider.of<GroupProvider>(context, listen: false).getGroups();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;

    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
            contentPadding: EdgeInsets.all(0),
            content: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: Container(
                  height: mediaQuery.height * 0.4,
                  child: SingleChildScrollView(
                    child: Column(children: [
                      Container(
                        height: 35,
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
                      Container(
                        alignment: Alignment.centerLeft,
                        margin:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        child: Form(
                          key: _formKey,
                          // child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Aggiungi gruppo',
                                  style: Theme.of(context).textTheme.headline2),
                              SizedBox(
                                height: 15,
                              ),
                              TextFormField(
                                key: Key('1'),
                                autocorrect: false,
                                cursorColor: Theme.of(context).primaryColor,
                                textCapitalization: TextCapitalization.none,
                                decoration: InputDecoration(
                                    hintText: 'Inserisci il nome'),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Scrivi qualcosa';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  groupName = value!;
                                },
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              if (status == Status.LOADING)
                                Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF0375fe),
                                  ),
                                ),
                              if (status == Status.DEFAULT)
                                Container(
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                        elevation: MaterialStateProperty.all(3),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                          const Color(0xFF0375fe),
                                        )),
                                    onPressed: () {
                                      var isValid =
                                          _formKey.currentState!.validate();
                                      FocusScope.of(context).unfocus();
                                      if (isValid) {
                                        _formKey.currentState!.save();
                                        saveGroup(context).whenComplete(() =>
                                            Future.delayed(Duration(seconds: 1),
                                                () {
                                              Navigator.pop(context);
                                            }));
                                      }
                                    },
                                    child: Center(
                                        child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          (Icons.add_circle_outline),
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'SALVA',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    )),
                                  ),
                                ),
                              if (status == Status.DONE)
                                Container(
                                  height: 50,
                                  color: Colors.green,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                      )
                    ]),
                  ),
                ))));
  }
}
