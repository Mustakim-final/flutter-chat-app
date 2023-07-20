import 'package:chat_app/models/chat_user.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class APIs{

  //for auth
  static FirebaseAuth auth=FirebaseAuth.instance;
  //for access firebase cloud store
  static   FirebaseFirestore firestore=FirebaseFirestore.instance;

  //for check user exists or not

  static Future<bool> userExists() async{
    return (await firestore.collection("Users").doc(auth.currentUser!.uid).get()).exists;
  }


  //to return current user
  static User? get user=>auth.currentUser;

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
}

