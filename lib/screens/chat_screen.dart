import 'package:chat_app/models/chat_user.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    var mq=MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: _appBar(context),
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
}
