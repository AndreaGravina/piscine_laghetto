import 'package:flutter/material.dart';

class UserStatsItem extends StatelessWidget {
  const UserStatsItem({required this.title, required this.data, Key? key }) : super(key: key);

  final String title;
  final dynamic data;

  @override
  Widget build(BuildContext context) {
    return Container(
     height: 110,
     child: Card(
       elevation: 0.0,
       shape:  RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey, width: 0.2)),
       color: const Color(0xffdaf6ff),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(title, style: TextStyle(fontFamily: 'Muli', fontSize: 18, )),
            SizedBox(height: 5,),
            Text(data, style: TextStyle(fontFamily: 'Muli', fontSize: 15, color: Color(0xff158cf2)))
          ],),
        ),
      ),
    );
  }
}