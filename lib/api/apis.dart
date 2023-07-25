import 'dart:developer';
import 'dart:io';

import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
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
  // static Stream<QuerySnapshot<Map<String,dynamic>>> getAllMessages(){
  //   return firestore.collection("messags").snapshots();
  // }

  //useful for getting conversion id
  static String getConversionId(String id)=>user!.uid.hashCode<=id.hashCode?'${user!.uid}_$id':'${id}_${user!.uid}';
  //for getting all messages of a specific conversion from firestore database
  static Stream<QuerySnapshot<Map<String,dynamic>>> getAllMessages(ChatUser user){
    return firestore.collection('chats/${getConversionId(user.id)}/messages/')
        .orderBy('sent',descending: true)
        .snapshots();
  }

  //for sending message

  static Future<void> sendMessage(ChatUser chatUser,String msg,Type type) async {
    //message sending time
    final time=DateTime.now().microsecondsSinceEpoch.toString();
    //message to send
    final Message message=Message(msg: msg, read: '', told: chatUser.id, type: type, fromId: user!.uid, sent: time);
    //type: Type.text beginng write
    final ref=firestore.collection('chats/${getConversionId(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson());

  }

  //update read status of message

  static Future<void> updateMessageReadStatus(Message message) async{
    firestore.collection('chats/${getConversionId(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read':DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //get only last message of specific chat
  static Stream<QuerySnapshot<Map<String,dynamic>>> getLastMessage(ChatUser user){
    return firestore.collection('chats/${getConversionId(user.id)}/messages/')
        .orderBy('sent',descending: true)
        .limit(1).snapshots();
  }

  //sent chat image
  static Future<void> sendChatImage(ChatUser chatUser,File file) async {
    //getting image file extension
    final ext=file.path.split('.').last;

    //storage file ref with path
    final ref=firebaseStorage.ref().child('images/${getConversionId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    //uploading image
    ref.putFile(file,SettableMetadata(contentType: 'images/$ext')).then((p0) async {
      log('Data transferred: ${p0.bytesTransferred/1000} kb');
      // log('message');
      //upload image in firestore
      final imageUrl= await ref.getDownloadURL();
      log('Image: ${imageUrl}');
      await sendMessage(chatUser, imageUrl, Type.image);
      log('upload mus');


    });
  }
}

