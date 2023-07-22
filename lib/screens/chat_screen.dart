import 'dart:convert';
import 'dart:developer';

import 'package:chat_app/api/apis.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/widgets/message_card.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  List<Message> list=[];
  @override
  Widget build(BuildContext context) {
    var mq=MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: _appBar(context),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                // stream: APIs.firestore.collection("Users").snapshots(),
                  stream: APIs.getAllMessages(),
                  builder:(context,snapshot){
                    switch(snapshot.connectionState){
                    //if data is loading
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        // return Center(child: CircularProgressIndicator(),);

                    //if some or all data is loaded then it show
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data=snapshot.data?.docs;
                        log('Data: ${jsonEncode(data![0].data())}');
                        // list=data?.map((e) => ChatUser.fromJson(e.data())).toList()??[];
                        list.clear();
                        list.add(Message(msg: 'hi', read: '', told: 'xyz', type: Type.text, fromId: APIs.user!.uid, sent: '11:00 PM'));
                        list.add(Message(msg: 'hello', read: '', told: APIs.user!.uid, type: Type.text, fromId: 'xyz', sent: '12:00 PM'));
                        if(list.isNotEmpty){
                          return ListView.builder(
                              physics: BouncingScrollPhysics(),
                              padding: EdgeInsets.only(top: mq.height*.01),
                              itemCount: list.length,
                              itemBuilder: (context,index){
                                return MessageCard(message: list[index]);
                              }
                          );
                        }else{
                          return Center(
                            child: Text("Say Hi 👋",style: TextStyle(fontSize: 20),),
                          );
                        }

                    }



                  }
              ),
            ),
            _chatInput(context)
          ],
        ),
      ),
    );
  }

  Widget _appBar(BuildContext context){
    var mq=MediaQuery.of(context).size;
    return InkWell(
      onTap: (){},
      child: Row(
        children: [
          IconButton(
              onPressed: (){
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            color: Colors.black,
          ),

          ClipRRect(
            borderRadius: BorderRadius.circular(mq.height*.03),
            child: CachedNetworkImage(
              height: mq.height*.09,
              width: mq.width*.09,
              imageUrl: widget.user.image,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => CircleAvatar(child: Icon(Icons.person),),
            ),
          ),
          SizedBox(width: 10,),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user.name,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500
                ),
              ),

              SizedBox(height: 2,),

              const Text(
                'Last seen not availabel',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _chatInput(BuildContext context){
    var mq=MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.1,horizontal: .03),
      child: Row(
        children: [
          Expanded(
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [

                  IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.emoji_emotions),
                    color: Colors.blueAccent,
                  ),

                  Expanded(
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Type something...',
                          hintStyle: TextStyle(color: Colors.blueAccent),
                          border: InputBorder.none
                        ),
                      )
                  ),

                  IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.image),
                    color: Colors.blueAccent,
                  ),

                  IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.camera_alt),
                    color: Colors.blueAccent,
                  ),
                ],
              ),
            ),
          ),

          //send message button

          MaterialButton(
            minWidth: 0,
              onPressed: (){},
            padding: EdgeInsets.only(top: 10,bottom: 10,right: 5,left: 10),
            color: Colors.blueAccent,
            child: Icon(Icons.send),
            shape: CircleBorder(),
          ),
        ],
      ),
    );
  }
}
