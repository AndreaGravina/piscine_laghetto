import '../providers/file_provider.dart';
import '../providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationListItem extends StatelessWidget {
  const NotificationListItem({required this.notification, Key? key})
      : super(key: key);

  final NotificationItem notification;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.only(bottom: 10),
      elevation: 2,
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Provider.of<FileProvider>(context, listen: false)
              .getFiles(repoid: notification.repositoryIdfk);
          Navigator.pop(context);
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFe8f0fe),
                Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          padding: EdgeInsets.all(20),
          height: 90,
          width: double.infinity,
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  notification.title,
                  textAlign: TextAlign.center,
                ),
                Text(
                  notification.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                Text(
                  notification.date,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
