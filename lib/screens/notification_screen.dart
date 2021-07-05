import 'package:flutter/material.dart';
import 'package:piscine_laghetto/providers/notification_provider.dart';
import 'package:piscine_laghetto/widgets/notification_item.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);
  static const routeName = '/notification';

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<NotificationProvider>(context, listen: false)
        .setNotificationStatus();
  }

  @override
  Widget build(BuildContext context) {
    var notificationList =
        Provider.of<NotificationProvider>(context).notificationList;
    return Stack(children: [
      Container(
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
      Scaffold(
        appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
            title: Text(
              'Notifiche',
              style: Theme.of(context).textTheme.headline1,
            )),
        backgroundColor: Colors.transparent,
        body: Container(
          height: 500 * notificationList.length.toDouble(),
          child: ListView.builder(
            padding: EdgeInsets.only(top: 30, right: 30, left: 30),
            physics: BouncingScrollPhysics(),
            itemCount: notificationList.length,
            itemBuilder: (ctx, index) => NotificationListItem(
              notification: notificationList[index],
            ),
          ),
        ),
      )
    ]);
  }
}
