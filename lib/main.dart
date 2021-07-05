import 'package:piscine_laghetto/providers/tags_provider.dart';
import 'package:piscine_laghetto/screens/user_detail_screen.dart';
import './providers/auth_status.dart';
import './providers/file_provider.dart';
import './providers/group_provider.dart';
import './providers/notification_provider.dart';
import './providers/users_provider.dart';
import './screens/admin_management_screen.dart';
import 'screens/edit_repository_screen.dart';
import './screens/edit_user_screen.dart';
import './screens/group_management_screen.dart';
import './screens/home_screen.dart';
import './screens/login_screen.dart';
import './screens/new_repository_screen.dart';
import './screens/new_user_screen.dart';
import './screens/notification_screen.dart';
import './screens/profile_screen.dart';
import './screens/splash_screen.dart';
import './screens/user_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
  OneSignal.shared.setAppId("05ac92a0-ce42-4b39-9521-505b67902f0e");
  OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
    print("Accepted permission: $accepted");
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (ctx) => AuthStatus()),
          ChangeNotifierProvider(create: (ctx) => FileProvider()),
          ChangeNotifierProvider(create: (ctx) => NotificationProvider()),
          ChangeNotifierProvider(create: (ctx) => UsersProvider()),
          ChangeNotifierProvider(create: (ctx) => GroupProvider()),
          ChangeNotifierProvider(create: (ctx) => TagProvider()),
        ],
        child: MaterialApp(
            title: 'Piscine Laghetto',
            theme: ThemeData(
                // primaryColor: Color(0xFF4dd2ff),
                primaryColor: Color(0xFF0375fe),
                accentColor: Color(0xffe6e6e6),
                inputDecorationTheme: InputDecorationTheme(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 1.5)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 1.5)),
                    filled: true,
                    hintStyle: TextStyle(color: Color(0xFF979797))),
                textTheme: TextTheme(
                  headline1: TextStyle(
                      fontFamily: 'Muli',
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.w800),
                  headline2: TextStyle(
                      fontFamily: 'Muli',
                      fontSize: 19,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                  headline3: TextStyle(fontFamily: 'Muli', fontSize: 16, color: Colors.black),
                  headline4: TextStyle(
                      fontFamily: 'Muli', fontSize: 13, color: Colors.black),
                  headline5: TextStyle(
                      fontFamily: 'Muli',
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                )),
            home: SpashScreen(),
            routes: {
              LoginScreen.routeName: (ctx) => LoginScreen(),
              HomeScreen.routeName: (ctx) => HomeScreen(),
              ProfileScreen.routeName: (ctx) => ProfileScreen(),
              NotificationScreen.routeName: (ctx) => NotificationScreen(),
              AdminManagementScreen.routeName: (ctx) => AdminManagementScreen(),
              GroupManagementScreen.routeName: (ctx) => GroupManagementScreen(),
              UserManagementScreen.routeName: (ctx) => UserManagementScreen(),
              EditUserScreen.routeName: (ctx) => EditUserScreen(),
              EditRepositoryScreen.routeName: (ctx) => EditRepositoryScreen(),
              NewUserScreen.routeName: (ctx) => NewUserScreen(),
              NewRepositoryScreen.routeName: (ctx) => NewRepositoryScreen(),
              UserDetailScreen.routeName: (ctx) => UserDetailScreen(),
            }));
  }
}
