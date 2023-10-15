

import 'dart:developer';

import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 2),(){
      //splash screen off
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(systemNavigationBarColor: Colors.white,statusBarColor: Colors.white));

      if(FirebaseAuth.instance.currentUser!=null){
        log('\nUser: ${FirebaseAuth.instance.currentUser}');

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
      }else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
      }

    });
  }
  @override
  Widget build(BuildContext context) {
    var mq=MediaQuery.of(context).size;

    return Scaffold(
      //app bar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Barta"),
        actions: [

        ],
      ),

      body: Stack(
        children: [
          Positioned(
              top: mq.height*.15,
              right: mq.width*.25,
              width: mq.width*.4,
              child: Image.asset('images/app_icon.png')
          ),
          Positioned(
              width: mq.width*.9,
              bottom: mq.height*.15,
              child:Text("M",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),)
          ),
        ],
      ),


    );
  }
}
