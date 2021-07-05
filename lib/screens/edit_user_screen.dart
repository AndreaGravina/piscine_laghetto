import 'package:flutter/material.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:piscine_laghetto/providers/group_provider.dart';
import 'package:piscine_laghetto/providers/users_provider.dart';
import 'package:piscine_laghetto/widgets/custom_dialog.dart';
import 'package:piscine_laghetto/widgets/support_dialog.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../global_class.dart' as Globals;

class EditUserScreen extends StatefulWidget {
  static const routeName = '/edit-user';

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  Status status = Status.DEFAULT;
  bool userStatus = true;
  var isAdmin = true;
  List<dynamic> groupData = [];
  Map<String, dynamic> _submitData = {
    'name': null,
    'surname': null,
    'email': null,
    'username': null,
    'business_name': null,
    'vat_number': null,
    'groups': [],
    'password': null,
    'status': 1,
  };

  Future<void> editUser(context, UserClass user, {int retry = 0}) async {
    setState(() {
      status = Status.LOADING;
    });
    print(user.roleidfk);
    var response = await http.post(Uri.parse('${Globals.URL}api/v1/save-user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Globals.token}'
        },
        body: jsonEncode({
          'userid': user.userid,
          'name': _submitData['name'],
          'surname': _submitData['surname'],
          'email': _submitData['email'],
          'username': _submitData['username'],
          'business_name': _submitData['business_name'],
          'vat_number': _submitData['vat_number'],
          'groups': _submitData['groups'],
          'password': _submitData['password'],
          'status': _submitData['status'],
          'type': user.roleidfk,
          'log': {'logid': Globals.logid, 'time': Globals.time}
        }));

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body) as Map<String, dynamic>;

      bool success = body['success'];
      if (!success) {
        print('___HTTP EDIT USER SUCCESS FALSE');
        String message = body['message'];
        showDialog(
            context: context,
            builder: (context) => CustomDialog(title: 'ERRORE', text: message));
        setState(() {
          status = Status.DEFAULT;
        });
      } else {
        Globals.updateLog(body['log']['logid'], body['log']['time']);
        print('___EDIT USER SUCCESS');
        setState(() {
          status = Status.DONE;
        });
      }
    } else if (response.statusCode == 401 && retry == 0) {
      print('___TRY REFRESH TOKEN');
      await Globals.refreshToken()
          .whenComplete(() => editUser(context, user, retry: 1));
    } else {
      print('___HTTP ERROR EDIT USER');
      showDialog(
          context: context,
          builder: (context) => CustomDialog(
              title: 'ERRORE',
              text: 'Qualcosa è andato storto, riprova più tardi'));
      setState(() {
        status = Status.DEFAULT;
      });
    }
    print('aggiorno');
    Provider.of<UsersProvider>(context, listen: false).getUsers(user.roleidfk);
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    UserClass user = arguments['user'];
    if (user.roleidfk == 2) isAdmin = false;
    var groupList = Provider.of<GroupProvider>(context).groupList;
    if (groupList.isNotEmpty) {
      groupData = [];
      groupList.forEach((group) {
        groupData.add({'display': group.name, 'value': group.groupid});
      });
    }
    print(user.groupsId.toString());

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Stack(children: [
        Column(
          children: [
            Container(
              height: 200,
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
            Container(
              height: mediaQuery.height - 200,
              color: Colors.grey.shade100,
            ),
          ],
        ),
        Scaffold(
          appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.white),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              centerTitle: true,
              title: Text(
                user.roleidfk == 4 ? 'Modifica utente' : 'Modifica Admin',
                style: Theme.of(context).textTheme.headline1,
              )),
          backgroundColor: Colors.transparent,
          body: Container(
            margin: EdgeInsets.only(top: 10),
            child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45)),
                child: Card(
                    margin: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(45),
                            topRight: Radius.circular(45))),
                    elevation: 0.0,
                    color: Colors.grey.shade100,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 50,
                              ),
                              Container(
                                width: 300,
                                child: Text(
                                  'COMPILARE I CAMPI\nCHE SI VOGLIONO MODIFICARE',
                                  style: TextStyle(
                                      fontSize: 19,
                                      color: Colors.grey.shade800),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                                width: double.infinity,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 50),
                                child: Container(
                                  width: 150,
                                  height: 3,
                                  color: Colors.blue.shade400,
                                ),
                              ),
                              SizedBox(
                                height: 35,
                              ),
                              TextFormField(
                                key: Key('${user.name}1'),
                                autocorrect: false,
                                cursorColor: Theme.of(context).primaryColor,
                                textCapitalization: TextCapitalization.none,
                                initialValue: user.name,
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                        borderSide: BorderSide(
                                            color: Colors.transparent,
                                            width: 1.5)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                        borderSide: BorderSide(
                                            color: Colors.transparent,
                                            width: 1.5)),
                                    filled: true,
                                    hintStyle:
                                        TextStyle(color: Color(0xFF979797)),
                                    hintText: 'Nome'),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Scrivi qualcosa';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _submitData['name'] = value!;
                                },
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              TextFormField(
                                key: Key('${user.surname}2'),
                                autocorrect: false,
                                cursorColor: Theme.of(context).primaryColor,
                                textCapitalization: TextCapitalization.none,
                                initialValue: user.surname,
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                        borderSide: BorderSide(
                                            color: Colors.transparent,
                                            width: 1.5)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                        borderSide: BorderSide(
                                            color: Colors.transparent,
                                            width: 1.5)),
                                    filled: true,
                                    hintStyle:
                                        TextStyle(color: Color(0xFF979797)),
                                    hintText: 'Cognome'),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Scrivi qualcosa';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _submitData['surname'] = value!;
                                },
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              TextFormField(
                                key: Key('${user.email}3'),
                                initialValue: user.email,
                                autocorrect: false,
                                cursorColor: Theme.of(context).primaryColor,
                                textCapitalization: TextCapitalization.none,
                                decoration: InputDecoration(
                                    hintText: 'Email'),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value!.isEmpty || !value.contains('@')) {
                                    return 'Email non valida';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _submitData['email'] = value!;
                                },
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              TextFormField(
                                key: Key('${user.username}4'),
                                autocorrect: false,
                                cursorColor: Theme.of(context).primaryColor,
                                textCapitalization: TextCapitalization.none,
                                initialValue: user.username,
                                decoration: InputDecoration(
                                    hintText: 'Username'),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Scrivi qualcosa';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _submitData['username'] = value!;
                                },
                              ),
                              if (user.roleidfk == UserClass.ROLE_USER)
                                SizedBox(
                                  height: 15,
                                ),
                              if (user.roleidfk == UserClass.ROLE_USER)
                                TextFormField(
                                  key: Key('${user.name}5'),
                                  autocorrect: false,
                                  cursorColor: Theme.of(context).primaryColor,
                                  textCapitalization: TextCapitalization.none,
                                  initialValue: user.businessName,
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
                                          borderSide: BorderSide(
                                              color: Colors.transparent,
                                              width: 1.5)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
                                          borderSide: BorderSide(
                                              color: Colors.transparent,
                                              width: 1.5)),
                                      filled: true,
                                      hintStyle:
                                          TextStyle(color: Color(0xFF979797)),
                                      hintText: 'Ragione sociale'),
                                  enabled: user.roleidfk == UserClass.ROLE_USER,
                                  onSaved: (value) {
                                    if (user.roleidfk == UserClass.ROLE_USER)
                                      _submitData['business_name'] = value!;
                                  },
                                ),
                              if (user.roleidfk == UserClass.ROLE_USER)
                                SizedBox(
                                  height: 15,
                                ),
                              if (user.roleidfk == UserClass.ROLE_USER)
                                TextFormField(
                                  key: Key('${user.name}6'),
                                  autocorrect: false,
                                  initialValue: user.vatNumber,
                                  cursorColor: Theme.of(context).primaryColor,
                                  textCapitalization: TextCapitalization.none,
                                  decoration: InputDecoration(
                                      hintText: 'Partita Iva'),
                                  onSaved: (value) {
                                    if (user.roleidfk == UserClass.ROLE_USER)
                                      _submitData['vat_number'] = value!;
                                  },
                                ),
                              if (user.roleidfk == UserClass.ROLE_USER)
                                SizedBox(
                                  height: 15,
                                ),
                              if (user.roleidfk == UserClass.ROLE_USER)
                                MultiSelectFormField(
                                  autovalidate: false,
                                  enabled: user.roleidfk == UserClass.ROLE_USER,
                                  checkBoxCheckColor:
                                      Theme.of(context).primaryColor,
                                  dialogShapeBorder: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0))),
                                  title: Text(
                                    "Gruppi",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF979797),
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  dataSource: groupData,
                                  textField: 'display',
                                  valueField: 'value',
                                  okButtonLabel: 'OK',
                                  cancelButtonLabel: 'ANNULLA',
                                  hintWidget: Text(
                                    'Inserisci almeno un gruppo*',
                                    style: TextStyle(
                                      color: Color(0xFF979797),
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  initialValue: user.groupsId,
                                  onSaved: (groups) {
                                    _submitData['groups'] = [];
                                    groups.forEach((element) {
                                      _submitData['groups'].add(element);
                                    });
                                    print(_submitData['groups'].toString());
                                  },
                                  border: InputBorder.none,
                                  fillColor: Colors.grey.shade200,
                                  validator: (groups) {
                                    if (groups!.isEmpty)
                                      return 'Nessun gruppo selezionato';
                                  },
                                ),
                              SizedBox(
                                height: 15,
                              ),
                              TextFormField(
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                decoration: InputDecoration(
                                    hintText: 'Nuova password'),
                                obscureText: true,
                                controller: _passwordController,
                                validator: (value) {
                                  if (value!.isEmpty ||
                                      value.length < 8 ||
                                      !Globals.validatePassword(value))
                                    return 'La password deve contenere almeno : Un carattere in maiuscolo Un carattere speciale Un carattere numerico, e 8 caratteri';
                                },
                                onSaved: (value) {
                                  _submitData['password'] = value.toString();
                                },
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                        borderSide: BorderSide(
                                            color: Colors.transparent,
                                            width: 1.5)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                        borderSide: BorderSide(
                                            color: Colors.transparent,
                                            width: 1.5)),
                                    filled: true,
                                    hintStyle:
                                        TextStyle(color: Color(0xFF979797)),
                                    hintText: 'Conferma password'),
                                obscureText: true,
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return 'Le Password non corrispondono';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              Container(
                                width: double.infinity,
                                height: 100,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text('Stato')),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Switch(
                                        activeColor:
                                            Theme.of(context).primaryColor,
                                        value: userStatus,
                                        onChanged: (newState) {
                                          setState(() {
                                            userStatus = newState;
                                            if (newState)
                                              _submitData['status'] = 1;
                                            else
                                              _submitData['status'] = 0;
                                          });
                                        }),
                                  ],
                                ),
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
                                          Colors.blue,
                                        )),
                                    onPressed: () {
                                      var isValid =
                                          _formKey.currentState!.validate();
                                      FocusScope.of(context).unfocus();
                                      if (isValid) {
                                        _formKey.currentState!.save();
                                        // if (user.roleidfk == 4)
                                        editUser(context, user);
                                        // else
                                        //    editAdmin(context, user);
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
                              Container(
                                height: 50,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ))),
          ),
          //       )),
        ),
      ]),
    );
  }
}
