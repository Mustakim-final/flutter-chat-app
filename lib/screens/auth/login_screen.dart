


import 'dart:developer';
import 'dart:io';

import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isAnimated=false;

  _handelGoogleBtnClick(){
    Dialogs.showProgressBar(context);
    signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if(user!=null){
        log('\nUser: ${user.user}');
        log('\nUser Info: ${user.additionalUserInfo}');
        if(await APIs.userExists()){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
        }else{
          await APIs.createUser().then((value){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
          });
        }

      }

    });
  }

  Future<UserCredential ?> signInWithGoogle() async {
    try{
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    }catch(e){
      log('\nsignInWithGoogle: ${e}');
      Dialogs.showSnackbar(context, 'something wrong,check internet');
      return null;
    }
  }

  //sign out
  // _signOut() async{
  //   await FirebaseAuth.instance.signOut();
  //   await GoogleSignIn().signOut();
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 500),(){
      setState(() {
        isAnimated=true;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    var mq=MediaQuery.of(context).size;

    return Scaffold(
      //app bar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Chat App"),
        actions: [

        ],
      ),

      body: Stack(
        children: [
          AnimatedPositioned(
            top: mq.height*.15,
              right: isAnimated ? mq.width*.25:-mq.width*.5,
              width: mq.width*.4,
              duration: Duration(seconds: 1),
              child: Image.asset('images/app_icon.png')
          ),
          Positioned(
              top: mq.height*.5,
              left: mq.width*.05,
              width: mq.width*.9,
              height: mq.height*.07,
              child: ElevatedButton.icon(
                onPressed: (){
                  _handelGoogleBtnClick();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 220, 166, 166),
                  shape: StadiumBorder(),
                  elevation: 1
                ),
                icon: Image.asset("images/google.png",height: mq.height*.05,),
                label: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black,fontSize: 16),
                    children: [
                      TextSpan(text: "Sign in With"),
                      TextSpan(text: " Google",style: TextStyle(fontWeight: FontWeight.w600))
                    ]
                  ),
                ),
              )
          ),
        ],
      ),


    );
  }
}
