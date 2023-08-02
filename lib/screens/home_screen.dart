import 'dart:convert';
import 'dart:developer';

import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/widgets/chat_user_cart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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

  //for storing search item
  final List<ChatUser> _searchList=[];

  //for storing search status

  bool _isSearching=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APIs.getSelfInfo();
    //APIs.updateActiveStatus(true);
    SystemChannels.lifecycle.setMessageHandler((message){

      if(APIs.auth.currentUser!=null){
        if(message.toString().contains('resume')) APIs.updateActiveStatus(true);
        if(message.toString().contains('pause')) APIs.updateActiveStatus(false);
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {


    return GestureDetector(
      //for hiding keyboard
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: WillPopScope(
        //if search is on & back button is pressed then close search
        //or else simple close current screen on back button click
        onWillPop: (){
          if(_isSearching){
            setState(() {
              _isSearching=!_isSearching;

            });
            return Future.value(false);
          }else{
            return Future.value(true);
          }
        },
        child: Scaffold(
          //app bar
          appBar: AppBar(
            leading: Icon(CupertinoIcons.home),
            title: _isSearching?TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Name,Email,...',
              ),
              autofocus: true,

              //when search text changes then update search list
              onChanged: (val){
                //search logic
                _searchList.clear();
                for(var i in list){
                  if(i.name.toLowerCase().contains(val.toLowerCase()) || i.email.toLowerCase().contains(val.toLowerCase()) ){
                    _searchList.add(i);
                  }
                  setState(() {
                    _searchList;
                  });
                }
              },
            ): Text("Barta"),
            actions: [
              //user searching
              IconButton(onPressed: (){
                setState(() {
                  _isSearching=!_isSearching;
                });
              }, icon: Icon(_isSearching?CupertinoIcons.clear_circled_solid:Icons.search)

              ),
              //profile
              IconButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen(user: APIs.me,)));
              }, icon: Icon(Icons.more_vert)),
            ],
          ),

          //floating button for new user add
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: FloatingActionButton(
              onPressed: (){
                showUserAddDialog();
              },
              child: Icon(Icons.add),
            ),
          ),

          body: StreamBuilder(
            stream: APIs.getMyUserId(),
            builder: (context,snapshot){
                switch(snapshot.connectionState){
                      //if data is loading
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                      return Center(child: CircularProgressIndicator(),);

                      //if some or all data is loaded then it show
                      case ConnectionState.active:
                      case ConnectionState.done:
                return StreamBuilder(
                  // stream: APIs.firestore.collection("Users").snapshots(),
                    stream:APIs.getAllUser(snapshot.data?.docs.map((e) => e.id).toList()??[]),
                    builder:(context,snapshot){

                          final data=snapshot.data?.docs;
                          list=data?.map((e) => ChatUser.fromJson(e.data())).toList()??[];

                          if(list.isNotEmpty){
                            return ListView.builder(
                                physics: BouncingScrollPhysics(),
                                itemCount:_isSearching?_searchList.length: list.length,
                                itemBuilder: (context,index){
                                  return ChatUserCart(user: _isSearching?_searchList[index]: list[index]);
                                }
                            );
                          }else{
                            return Center(
                              child: Text("No data found"),
                            );
                          }

                      }

                );
              }//if

            },
          )

        ),
      ),
    );
  }

  //show user add dialog
  void showUserAddDialog(){
    String email='';
    showDialog(
        context: context,
        builder: (context)=>AlertDialog(
          contentPadding: EdgeInsets.only(left: 24,right: 24,top: 20,bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.person_add,color: Colors.blue,size: 28,),
              Text(" Add User"),
            ],
          ),
          content: TextFormField(
            maxLines: null,
            onChanged: (value)=>email=value,
            decoration: InputDecoration(
              hintText: 'email id',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))
            ),
          ),
          actions: [
            MaterialButton(onPressed: (){
              Navigator.pop(context);
            },child: Text("Cancel",style: TextStyle(color: Colors.blue,fontSize: 16),),),

            MaterialButton(onPressed: () async {
              Navigator.pop(context);
              if(email.isNotEmpty){
                await APIs.addChatUser(email).then((value){
                  if(!value){
                    Dialogs.showSnackbar(context, "User does not exits!");
                  }
                });
              }
            },child: Text("Add",style: TextStyle(color: Colors.blue,fontSize: 16),),),
          ],
        )
    );
  }
}
