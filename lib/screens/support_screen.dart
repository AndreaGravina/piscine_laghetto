import 'package:flutter/material.dart';
import 'package:piscine_laghetto/widgets/custom_dialog.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../global_class.dart' as Globals;

enum Status { DEFAULT, LOADING, DONE }

class SupportScreen extends StatefulWidget {
  static const routeName = '/support';

  @override
  _SupportScreenState createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  Map<String, String> _submitData = {
    'fullName': '',
    'email': '',
    'phone': '',
    'request': '',
  };
  Status status = Status.DEFAULT;

  Future<void> sendEmail(
      context, String object, String email, String description,
      {int retry = 0}) async {
    setState(() {
      status = Status.LOADING;
    });
    print(object);
    print(email);
    print(description);
    var response = await http.post(Uri.parse('${Globals.URL}api/v1/contact'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Globals.token}'
        },
        body: jsonEncode({
          'obj': object,
          'email': email,
          'description': description,
          'log': {'logid': Globals.logid, 'time': Globals.time}
        }));

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body) as Map<String, dynamic>;
      bool success = body['success'];
      if (!success) {
        print('___HTTP WARNING SEND EMAIL');
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
        print('___SEND EMAIL SUCCESS');
        setState(() {
          status = Status.DONE;
        });
      }
    } else if (response.statusCode == 401 && retry == 0) {
      print('___TRY REFRESH TOKEN');
      await Globals.refreshToken().whenComplete(
          () => sendEmail(context, object, email, description, retry: 1));
    } else {
      print('___HTTP ERROR SEND EMAIL');
      showDialog(
          context: context,
          builder: (context) => CustomDialog(
              title: 'ERRORE',
              text: 'Qualcosa è andato storto, riprova più tardi'));
      setState(() {
        status = Status.DEFAULT;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;

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
                'Contattaci',
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
                                  'COMPILARE I CAMPI\nSOTTOSTANTI',
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
                              SizedBox(
                                height: 15,
                              ),
                              TextFormField(
                                autocorrect: false,
                                cursorColor: Theme.of(context).primaryColor,
                                textCapitalization: TextCapitalization.none,
                                decoration: InputDecoration(
                                  hintText: 'Oggetto',
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Scrivi qualcosa';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _submitData['obj'] = value!;
                                },
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              TextFormField(
                                autocorrect: false,
                                cursorColor: Theme.of(context).primaryColor,
                                textCapitalization: TextCapitalization.none,
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                ),
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
                                autocorrect: false,
                                scrollPadding:
                                    const EdgeInsets.only(bottom: 90.0),
                                cursorColor: Theme.of(context).primaryColor,
                                minLines: 5,
                                maxLines: 10,
                                scrollPhysics: BouncingScrollPhysics(),
                                textCapitalization: TextCapitalization.none,
                                decoration: InputDecoration(
                                  hintText: 'Descrizione',
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Scrivi qualcosa';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _submitData['description'] = value!;
                                },
                              ),
                              SizedBox(
                                height: 40,
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
                                        sendEmail(
                                                context,
                                                _submitData['obj']!,
                                                _submitData['email']!,
                                                _submitData['description']!)
                                            .whenComplete(() => Future.delayed(
                                                    Duration(milliseconds: 500), () {
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
                                          'INVIA',
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
                              SizedBox(
                                height: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ))),
          ),
        ),
      ]),
    );
  }
}
