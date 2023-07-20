import 'package:chat_app/models/chat_user.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatUserCart extends StatefulWidget {
  final ChatUser user;
  const ChatUserCart({super.key, required this.user});

  @override
  State<ChatUserCart> createState() => _ChatUserCartState();
}

class _ChatUserCartState extends State<ChatUserCart> {
  @override
  Widget build(BuildContext context) {
    var mq=MediaQuery.of(context).size;

    return Card(
      elevation: 0.5,
      margin: EdgeInsets.symmetric(horizontal: mq.width*.04,vertical: 4),
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: (){},
          child: ListTile(
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
            subtitle: Text(widget.user.about,maxLines: 1,),
            trailing: Container(
              height: 15,
              width: 15,
              decoration: BoxDecoration(
                color: Colors.greenAccent.shade400,
                borderRadius: BorderRadius.circular(10)
              ),
            ),
            // trailing: const Text("12:00 PM",style: TextStyle(color: Colors.black54),),
          )
      ),
    );
  }
}
