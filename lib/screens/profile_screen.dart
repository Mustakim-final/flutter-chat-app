import 'dart:convert';
import 'dart:developer';

import 'package:chat_app/api/apis.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:chat_app/widgets/chat_user_cart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {



  @override
  Widget build(BuildContext context) {


    var mq=MediaQuery.of(context).size;
    return Scaffold(
      //app bar
      appBar: AppBar(

        title: Text("Profile"),

      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: FloatingActionButton.extended(
          onPressed: () async{
            await FirebaseAuth.instance.signOut();
            await GoogleSignIn().signOut();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
          },
          icon: Icon(Icons.logout),
          label: Text("logout"),


        ),
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: mq.width*.05),
        child: Column(
          children: [
            SizedBox(width: mq.width,height: mq.height*.03,),

            ClipRRect(
              borderRadius: BorderRadius.circular(mq.height*.1),
              child: CachedNetworkImage(
                height: mq.height*0.2,
                width: mq.height*.2,
                fit: BoxFit.fill,
                imageUrl: widget.user.image,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => CircleAvatar(child: Icon(Icons.person),),
              ),
            ),
            SizedBox(width: mq.width,height: mq.height*.03,),
            Text(widget.user.email,style: TextStyle(fontSize: 16),),
            SizedBox(width: mq.width,height: mq.height*.03,),
            TextFormField(
              initialValue: widget.user.name,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
                hintText: 'Name....',
                label: Text("name")
              ),
            ),
            SizedBox(width: mq.width,height: mq.height*.03,),
            TextFormField(
              initialValue: widget.user.about,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.info_outline),
                  border: OutlineInputBorder(),
                  hintText: 'about....',
                label: Text("About")
              ),
            ),

            SizedBox(width: mq.width,height: mq.height*.03,),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: StadiumBorder(),
                minimumSize: Size(mq.width*.5, mq.height*.06)
              ),
                onPressed: (){},
                icon: Icon(Icons.edit,size: 28,),
              label: Text("Update",style: TextStyle(fontSize: 16),),
            )
          ],
        ),
      ),

    );
  }
}
