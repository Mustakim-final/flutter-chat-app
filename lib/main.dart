import 'dart:developer';

import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/screens/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';

main(){

  WidgetsFlutterBinding.ensureInitialized();
  //splash screen on
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]).then((value){
    initializeFirebase();
    runApp(MyApp());
  });

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          elevation: 1,
          centerTitle: true,
            titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 19,
                fontWeight: FontWeight.normal
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black)
        )
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

initializeFirebase() async{
// ...
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  var result=FlutterNotificationChannel.registerNotificationChannel(
      id: 'chats',
      name: 'Chats',
      description: 'For Showing Message Notification',
      importance: NotificationImportance.IMPORTANCE_HIGH,
  );
  
  log('\nNotification Channel Result: $result');
}
