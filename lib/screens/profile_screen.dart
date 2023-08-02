import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/dialogs.dart';
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

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final _formkey=GlobalKey<FormState>();
  String? _image;

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

          title: Text("Profile"),

        ),

        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: FloatingActionButton.extended(
            onPressed: () async{
              Dialogs.showProgressBar(context);
              APIs.updateActiveStatus(false);
              //firebase sign out
              await FirebaseAuth.instance.signOut().then((value) async {
                //google sign out
                await GoogleSignIn().signOut().then((value){
                  Navigator.pop(context);

                  Navigator.pop(context);

                  APIs.auth=FirebaseAuth.instance;

                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
                });
              });


            },
            icon: Icon(Icons.logout),
            label: Text("logout"),


          ),
        ),

        body: Form(
          key: _formkey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width*.05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(width: mq.width,height: mq.height*.03,),

                  Stack(
                    children: [
                      _image!=null?
                      ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height*.1),
                        //profile picture
                        child: Image.file(
                          File(_image!),
                          height: mq.height*0.2,
                          width: mq.height*.2,
                          fit: BoxFit.fill,
                        ),
                      ):
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

                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          elevation: 1,
                            onPressed: (){
                              showModalBottomSheet(
                                  context: context,
                                  builder: (_){
                                    return ListView(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.only(top: mq.height*.03,bottom: mq.height*.05),
                                      children: [
                                        Text("Pick Profile Picture",
                                        textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),

                                        ),

                                        SizedBox(height: mq.height*.05,),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () async {
                                                final ImagePicker picker = ImagePicker();
                                                // Pick an image.
                                                final XFile? image = await picker.pickImage(source: ImageSource.gallery,imageQuality: 80);
                                                if(image!=null){
                                                  log('Image path: ${image.path} -- MimeType: ${image.mimeType}');

                                                  setState(() {
                                                    _image=image.path;
                                                  });
                                                }

                                                APIs.updateProfilePicture(File(_image!));

                                                Navigator.pop(context);
                                              },
                                              child: Icon(Icons.image,size: 100,color: Colors.blue,),
                                              style: ElevatedButton.styleFrom(
                                                shape: CircleBorder(),
                                                backgroundColor: Colors.white,
                                                fixedSize: Size(mq.width*.3, mq.height*.15),
                                              ),
                                            ),

                                            ElevatedButton(
                                              onPressed: () async {
                                                final ImagePicker picker = ImagePicker();
                                                // Pick an image.
                                                final XFile? image = await picker.pickImage(source: ImageSource.camera,imageQuality: 80);

                                                if(image!=null){
                                                  log('Image path: ${image.path} -- MimeType: ${image.mimeType}');

                                                  setState(() {
                                                    _image=image.path;
                                                  });
                                                }
                                                APIs.updateProfilePicture(File(_image!));

                                                Navigator.pop(context);
                                              },
                                              child: Icon(Icons.camera_alt,size: 100,color: Colors.blue,),
                                              style: ElevatedButton.styleFrom(
                                                shape: CircleBorder(),
                                                backgroundColor: Colors.white,
                                                fixedSize: Size(mq.width*.3, mq.height*.15),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: mq.height*.05,)
                                      ],
                                    );
                                  }
                              );
                            },
                          shape: CircleBorder(),
                          child: Icon(Icons.edit),
                          color: Colors.white,
                        ),
                      )
                    ],

                  ),
                  SizedBox(width: mq.width,height: mq.height*.03,),
                  Text(widget.user.email,style: TextStyle(fontSize: 16),),
                  SizedBox(width: mq.width,height: mq.height*.03,),
                  //user name
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val)=>APIs.me.name=val??'',
                    validator: (val)=>val!=null && val.isNotEmpty?null:'Required Field',
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                      hintText: 'Name....',
                      label: Text("name")
                    ),
                  ),
                  SizedBox(width: mq.width,height: mq.height*.03,),

                  //user about
                  
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val)=>APIs.me.about=val??'',
                    validator: (val)=>val!=null && val.isNotEmpty?null:'Required Field',
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
                      onPressed: (){
                      if(_formkey.currentState!.validate()){
                        log('inside validator');
                        _formkey.currentState!.save();
                        APIs.updateUserInfo().then((msg){
                          Dialogs.showSnackbar(context, "Profile update successfully");
                        });

                        //MySnakBar("click", context);



                      }
                      },
                      icon: Icon(Icons.edit,size: 28,),
                    label: Text("Update",style: TextStyle(fontSize: 16),),
                  )
                ],
              ),
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



