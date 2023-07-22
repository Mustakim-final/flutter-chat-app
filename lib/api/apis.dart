import 'dart:developer';
import 'dart:io';

import 'package:chat_app/models/chat_user.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class APIs{

  //for auth
  static FirebaseAuth auth=FirebaseAuth.instance;
  //for access firebase cloud store
  static   FirebaseFirestore firestore=FirebaseFirestore.instance;

  //for access firebase storage
  static FirebaseStorage firebaseStorage=FirebaseStorage.instance;

  //storing self info
  static late ChatUser me;

  //for check user exists or not

  static Future<bool> userExists() async{
    return (await firestore.collection("Users").doc(auth.currentUser!.uid).get()).exists;
  }




  //to return current user
  static User? get user=>auth.currentUser;

  //get my info
  static Future<void> getSelfInfo() async{
    await firestore.collection("Users").doc(auth.currentUser!.uid).get().then((user) async {
      if(user.exists){
        me=ChatUser.fromJson(user.data()!);
      }else{
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  //create new user

  static Future<void> createUser() async{
    final time=DateTime.now().microsecondsSinceEpoch.toString();
    final chatuser=ChatUser(
      id: auth.currentUser!.uid,
      name: auth.currentUser!.displayName.toString(),
      email: user!.email.toString(),
      about: "Hey, i am using chat app",
      image: user!.photoURL.toString(),
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: ''

    );
    return await firestore.collection("Users").doc(user!.uid).set(chatuser.toJson());
  }

//get all user
  static Stream<QuerySnapshot<Map<String,dynamic>>> getAllUser(){
     return firestore.collection("Users").where('id',isNotEqualTo: user?.uid).snapshots();
  }

  //for updating user info

  static Future<void> updateUserInfo() async{
    await firestore.collection("Users").doc(auth.currentUser!.uid).update({
      'name':me.name,
      'about':me.about
    });
  }

  //update image in firebase database

 static Future<void> updateProfilePicture(File file)async {

    //getting image file extension
   final ext=file.path.split('.').last;
   log('Extension: $ext');

   //storage file ref with path
   final ref=firebaseStorage.ref().child('profile_picture/${user?.uid}.$ext');

   //uploading image
   ref.putFile(file,SettableMetadata(contentType: 'image/$ext')).then((p0){
     log('Data transferred: ${p0.bytesTransferred/1000} kb');
   });


   //updating image in firestore
   me.image= await ref.getDownloadURL();

   await firestore.collection("Users").doc(auth.currentUser!.uid).update({
     'image':me.image
   });

 }

  //get messages specific user
  static Stream<QuerySnapshot<Map<String,dynamic>>> getAllMessages(){
    return firestore.collection("messags").snapshots();
  }

}

