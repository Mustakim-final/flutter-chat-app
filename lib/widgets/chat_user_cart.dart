import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatUserCart extends StatefulWidget {
  final ChatUser user;
  const ChatUserCart({super.key, required this.user});

  @override
  State<ChatUserCart> createState() => _ChatUserCartState();
}

class _ChatUserCartState extends State<ChatUserCart> {
  //last message info
  Message? message;

  @override
  Widget build(BuildContext context) {
    var mq=MediaQuery.of(context).size;

    return Card(
      elevation: 0.5,
      margin: EdgeInsets.symmetric(horizontal: mq.width*.04,vertical: 4),
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatScreen(user: widget.user,)));
        },
          child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context,snapshot){
              final data=snapshot.data?.docs;
              final list=data?.map((e) => Message.fromJson(e.data())).toList()??[];
              if(list.isNotEmpty){
                message=list[0];
              }
              return ListTile(
                // leading: const CircleAvatar(child: Icon(Icons.person),),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: widget.user.image,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => CircleAvatar(child: Icon(Icons.person),),
                  ),
                ),
                title: Text(widget.user.name),
                subtitle: Text(message!=null?message!.type==Type.image? 'Photo': message!.msg: widget.user.about,maxLines: 1,),
                trailing:
                message==null?null
                :message!.read.isEmpty && message!.fromId!=APIs.user!.uid?
                Container(
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(
                      color: Colors.greenAccent.shade400,
                      borderRadius: BorderRadius.circular(10)
                  ),
                ):
                Text(MyDateUtil.getLastMessageTime(context: context, time: message!.sent),style: TextStyle(color: Colors.black54),),
              );
            },
          )
      ),
    );
  }
}
