// import '../widgets/custom_dialog.dart';
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../global_class.dart' as Globals;

// enum Status { DEFAULT, LOADING, DONE }

// class SupportDialog extends StatefulWidget {
//   @override
//   _SupportDialogState createState() => _SupportDialogState();
// }

// class _SupportDialogState extends State<SupportDialog> {
//   final GlobalKey<FormState> _formKey = GlobalKey();
//   Map<String, String> _submitData = {
//     'fullName': '',
//     'email': '',
//     'phone': '',
//     'request': '',
//   };
//   Status status = Status.DEFAULT;

//   Future<void> sendEmail(
//       context, String object, String email, String description,
//       {int retry = 0}) async {
//     setState(() {
//       status = Status.LOADING;
//     });
//     print(object);
//     print(email);
//     print(description);
//     var response = await http.post(Uri.parse('${Globals.URL}api/v1/contact'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer ${Globals.token}'
//         },
//         body: jsonEncode({
//           'obj': object,
//           'email': email,
//           'description': description,
//           'log': {'logid': Globals.logid, 'time': Globals.time}
//         }));

//     if (response.statusCode == 200) {
//       var body = jsonDecode(response.body) as Map<String, dynamic>;
//       bool success = body['success'];
//       if (!success) {
//         print('___HTTP WARNING SEND EMAIL');
//         String message = body['message'];
//         Navigator.pop(context);
//         showDialog(
//             context: context,
//             builder: (context) => CustomDialog(title: 'ERRORE', text: message));
//         setState(() {
//           status = Status.DEFAULT;
//         });
//       } else {
//         Globals.updateLog(body['log']['logid'], body['log']['time']);
//         print('___SEND EMAIL SUCCESS');
//         setState(() {
//           status = Status.DONE;
//         });
//       }
//     } else if (response.statusCode == 401 && retry == 0) {
//       print('___TRY REFRESH TOKEN');
//       await Globals.refreshToken().whenComplete(
//           () => sendEmail(context, object, email, description, retry: 1));
//     } else {
//       print('___HTTP ERROR SEND EMAIL');
//       showDialog(
//           context: context,
//           builder: (context) => CustomDialog(
//               title: 'ERRORE',
//               text: 'Qualcosa è andato storto, riprova più tardi'));
//       setState(() {
//         status = Status.DEFAULT;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     var mediaQuery = MediaQuery.of(context).size;

//     return GestureDetector(
//         onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
//         child: AlertDialog(
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
//             contentPadding: EdgeInsets.all(0),
//             content: ClipRRect(
//                 borderRadius: BorderRadius.circular(35),
//                 child: Container(
//                   height: mediaQuery.height * 0.7,
//                   child: SingleChildScrollView(
//                     child: Column(children: [
//                       Container(
//                         height: 35,
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                           colors: [
//                             Color(0xFF3bbddc),
//                             Color(0xFF0375fe),
//                           ],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         )),
//                       ),
//                       Container(
//                           alignment: Alignment.centerLeft,
//                           margin: EdgeInsets.symmetric(
//                               vertical: 15, horizontal: 20),
//                           child: Form(
//                             key: _formKey,
//                             // child: SingleChildScrollView(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   'Contattaci',
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .headline2!
//                                       .apply(color: Colors.black),
//                                 ),
//                                 SizedBox(
//                                   height: 15,
//                                 ),
//                                 TextFormField(
//                                   autocorrect: false,
//                                   cursorColor: Theme.of(context).primaryColor,
//                                   textCapitalization: TextCapitalization.none,
//                                   decoration: InputDecoration(
//                                     focusedBorder: UnderlineInputBorder(
//                                       borderSide: BorderSide(
//                                           color: Theme.of(context).primaryColor,
//                                           width: 1.5),
//                                     ),
//                                     hintText: 'Oggetto',
//                                   ),
//                                   validator: (value) {
//                                     if (value!.isEmpty) {
//                                       return 'Scrivi qualcosa';
//                                     }
//                                     return null;
//                                   },
//                                   onSaved: (value) {
//                                     _submitData['obj'] = value!;
//                                   },
//                                 ),
//                                 SizedBox(
//                                   height: 10,
//                                 ),
//                                 TextFormField(
//                                   autocorrect: false,
//                                   cursorColor: Theme.of(context).primaryColor,
//                                   textCapitalization: TextCapitalization.none,
//                                   decoration: InputDecoration(
//                                     focusedBorder: UnderlineInputBorder(
//                                       borderSide: BorderSide(
//                                           color: Theme.of(context).primaryColor,
//                                           width: 1.5),
//                                     ),
//                                     hintText: 'Email',
//                                   ),
//                                   keyboardType: TextInputType.emailAddress,
//                                   validator: (value) {
//                                     if (value!.isEmpty ||
//                                         !value.contains('@')) {
//                                       return 'Email non valida';
//                                     }
//                                     return null;
//                                   },
//                                   onSaved: (value) {
//                                     _submitData['email'] = value!;
//                                   },
//                                 ),
//                                 SizedBox(
//                                   height: 30,
//                                 ),
//                                 TextFormField(
//                                   autocorrect: false,
//                                   scrollPadding:
//                                       const EdgeInsets.only(bottom: 90.0),
//                                   cursorColor: Theme.of(context).primaryColor,
//                                   minLines: 5,
//                                   maxLines: 10,
//                                   scrollPhysics: BouncingScrollPhysics(),
//                                   textCapitalization: TextCapitalization.none,
//                                   decoration: InputDecoration(
//                                     hintText: 'Descrizione',
//                                     focusedBorder: OutlineInputBorder(
//                                       borderSide: BorderSide(
//                                           color: Theme.of(context).primaryColor,
//                                           width: 1.5),
//                                     ),
//                                     errorBorder: OutlineInputBorder(
//                                       borderSide: BorderSide(
//                                           color: Colors.red, width: 1.0),
//                                     ),
//                                     focusedErrorBorder: OutlineInputBorder(
//                                       borderSide: BorderSide(
//                                           color: Colors.red, width: 1.5),
//                                     ),
//                                     enabledBorder: OutlineInputBorder(
//                                       borderSide: BorderSide(
//                                           color: Colors.grey.shade500,
//                                           width: 1.0),
//                                     ),
//                                   ),
//                                   validator: (value) {
//                                     if (value!.isEmpty) {
//                                       return 'Scrivi qualcosa';
//                                     }
//                                     return null;
//                                   },
//                                   onSaved: (value) {
//                                     _submitData['description'] = value!;
//                                   },
//                                 ),
//                                 SizedBox(
//                                   height: 40,
//                                 ),
//                                 if (status == Status.LOADING)
//                                   Center(
//                                     child: CircularProgressIndicator(
//                                       color: Color(0xFF0375fe),
//                                     ),
//                                   ),
//                                 if (status == Status.DEFAULT)
//                                   Container(
//                                     height: 50,
//                                     child: ElevatedButton(
//                                       style: ButtonStyle(
//                                           elevation:
//                                               MaterialStateProperty.all(3),
//                                           backgroundColor:
//                                               MaterialStateProperty.all(
//                                             const Color(0xFF0375fe),
//                                           )),
//                                       onPressed: () {
//                                         var isValid =
//                                             _formKey.currentState!.validate();
//                                         FocusScope.of(context).unfocus();
//                                         if (isValid) {
//                                           _formKey.currentState!.save();
//                                           sendEmail(
//                                               context,
//                                               _submitData['obj']!,
//                                               _submitData['email']!,
//                                               _submitData['description']!);
//                                         }
//                                       },
//                                       child: Center(
//                                           child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Icon(
//                                             (Icons.add_circle_outline),
//                                             color: Colors.white,
//                                           ),
//                                           SizedBox(
//                                             width: 5,
//                                           ),
//                                           Text(
//                                             'INVIA',
//                                             style:
//                                                 TextStyle(color: Colors.white),
//                                           ),
//                                         ],
//                                       )),
//                                     ),
//                                   ),
//                                 if (status == Status.DONE)
//                                   Container(
//                                     height: 50,
//                                     color: Colors.green,
//                                     child: Row(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.center,
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Icon(
//                                           Icons.done,
//                                           color: Colors.white,
//                                         ),
//                                         SizedBox(
//                                           width: 5,
//                                         ),
//                                         Text(
//                                           'FATTO',
//                                           style: TextStyle(color: Colors.white),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 SizedBox(
//                                   height: 30,
//                                 ),
//                               ],
//                             ),
//                           )) //)
//                     ]),
//                   ),
//                 ))));
//   }
// }
