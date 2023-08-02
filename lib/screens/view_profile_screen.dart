import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/helper/my_date_util.dart';
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
import 'package:image_picker/image_picker.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {



  MySnakBar(message,context){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message),
      backgroundColor: Colors.blue,
      behavior: SnackBarBehavior.floating,

    ));
  }


  @override
  Widget build(BuildContext context) {


    var mq=MediaQuery.of(context).size;

    return GestureDetector(
      //for hiding keybord
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: Scaffold(
        //app bar
        appBar: AppBar(

          title: Text(widget.user.name),

        ),

        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Joined On: ',style: TextStyle(color: Colors.black54,fontWeight: FontWeight.w500,fontSize: 16),),
            Text(MyDateUtil.getLastMessageTime(context: context, time: widget.user.createdAt,showYear: true),style: TextStyle(color: Colors.black54,),)
          ],
        ),


        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.width*.05),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(width: mq.width,height: mq.height*.03,),

                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height*.1),
                  //profile picture
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
                //user name
                Text(widget.user.name,style: TextStyle(fontSize: 16),),
                SizedBox(width: mq.width,height: mq.height*.03,),

                //user about

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Text('About:',style: TextStyle(color: Colors.blue,fontSize: 18,fontWeight: FontWeight.w500),),


                    Flexible(
                      child: Container(
                        padding: EdgeInsets.all(mq.width*.04),
                        margin: EdgeInsets.symmetric(horizontal: mq.width*.04,vertical: mq.height*.01),
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 221, 245, 255),
                            border: Border.all(color: Colors.lightGreen),
                        ),
                        child:
                        Text(widget.user.about,style: TextStyle(fontSize: 15,color: Colors.black),)


                      ),
                    )
                  ],
                ),


                SizedBox(width: mq.width,height: mq.height*.03,),

              ],
            ),
          ),
        ),

      ),
    );
  }

  //bottom sheet for picking a profile picture

  void _showBootmSheet(){

  }
}



