import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final Icon icon;
  final String title;
  final String text;

  CustomDialog({
    this.icon = const Icon(
      Icons.error_outline,
      color: const Color(0xFF0375fe),
      size: 40,
    ),
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        height: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(
              height: 5,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              text,
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              Theme.of(context).primaryColor,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Container(
              width: double.infinity,
              child: Center(
                  child: Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ))),
        ),
      ],
    );
  }
}
