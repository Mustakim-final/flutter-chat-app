import 'dart:convert';
import 'dart:developer';

import 'package:chat_app/api/apis.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/widgets/chat_user_cart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  CollectionReference _reference=FirebaseFirestore.instance.collection("Users");

  List<ChatUser> list=[];

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      //app bar
      appBar: AppBar(
        leading: Icon(CupertinoIcons.home),
        title: Text("Chat App"),
        actions: [
          //user searching
          IconButton(onPressed: (){}, icon: Icon(Icons.search)),
          //profile
          IconButton(onPressed: (){}, icon: Icon(Icons.more_vert)),
        ],
      ),

      //floating button for new user add
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: FloatingActionButton(
          onPressed: () async{
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();
          },
          child: Icon(Icons.add),
        ),
      ),

      body: StreamBuilder(
        stream: APIs.firestore.collection("Users").snapshots(),
        builder:(context,snapshot){
          switch(snapshot.connectionState){
            //if data is loading
            case ConnectionState.waiting:
            case ConnectionState.none:
              return Center(child: CircularProgressIndicator(),);

              //if some or all data is loaded then it show
            case ConnectionState.active:
            case ConnectionState.done:
              final data=snapshot.data?.docs;
              list=data?.map((e) => ChatUser.fromJson(e.data())).toList()??[];

              if(list.isNotEmpty){
                return ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (context,index){
                      return ChatUserCart(user: list[index]);
                    }
                );
              }else{
                return Center(
                  child: Text("No data found"),
                );
              }

          }



        }
      ),
    );
  }
}
