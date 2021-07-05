import 'package:flutter/material.dart';

class UserInfoItem extends StatelessWidget {
  const UserInfoItem({required this.title, required this.data, Key? key }) : super(key: key);

  final String title;
  final dynamic data;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Padding(
          padding: const EdgeInsets.only(left: 25, top: 20, bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(title, style: TextStyle(fontFamily: 'Muli', fontSize: 18, )),
            SizedBox(height: 5,),
            Text(data, style: TextStyle(fontFamily: 'Muli', fontSize: 15, color: Color(0xff158cf2)))
          ],),
        ),
    );
  }
}