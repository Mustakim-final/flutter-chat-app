import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/models/message.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  const MessageCard({Key? key, required this.message}) : super(key: key);

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.user!.uid==widget.message.fromId?_greenMessage(context):_blueMessage(context);
  }

  Widget _blueMessage(BuildContext context){
    var mq=MediaQuery.of(context).size;
    if(widget.message.read.isEmpty){
      APIs.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type==Type.image?mq.width*.03:mq.width*.04),
            margin: EdgeInsets.symmetric(horizontal: mq.width*.04,vertical: mq.height*.01),
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 221, 245, 255),
                border: Border.all(color: Colors.lightBlue),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20),bottomRight: Radius.circular(20))
            ),
            child:
            widget.message.type==Type.text?
            Text(widget.message.msg,style: TextStyle(fontSize: 15,color: Colors.black),):
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: widget.message.msg,
                placeholder: (context, url) => Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(strokeWidth: 2,)),
                errorWidget: (context, url, error) => CircleAvatar(child: Icon(Icons.person),),
              ),
            ),

          ),
        ),
        
        Padding(
          padding: EdgeInsets.only(right: mq.width* .04),
          child: Text(
            MyDateUtil.getFormattedTime(context: context, time: widget.message.sent,),
            style: TextStyle(fontSize: 13,color: Colors.black54),
          ),
        )
      ],
    );
  }

  //our or user message

Widget _greenMessage(BuildContext context){
  var mq=MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(width: mq.width*.04,),
            //for blue tick
            if(widget.message.read.isNotEmpty)
              Icon(Icons.done_all_rounded,color: Colors.blue,size: 20,),

            SizedBox(width: mq.width*.02,),
            Text(
              MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),
              style: TextStyle(fontSize: 13,color: Colors.black54),
            ),
          ],
        ),


        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type==Type.image?mq.width*.03:mq.width*.04),
            margin: EdgeInsets.symmetric(horizontal: mq.width*.04,vertical: mq.height*.01),
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 221, 245, 255),
                border: Border.all(color: Colors.lightGreen),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20),bottomLeft: Radius.circular(20))
            ),
            child:
            widget.message.type==Type.text?
            Text(widget.message.msg,style: TextStyle(fontSize: 15,color: Colors.black),):
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: widget.message.msg,
                placeholder: (context, url) => Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(strokeWidth: 2,)),
                errorWidget: (context, url, error) => CircleAvatar(child: Icon(Icons.person),),
              ),
            ),

          ),
        ),
      ],
    );
}
}
