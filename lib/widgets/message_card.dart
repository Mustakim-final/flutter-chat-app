import 'package:chat_app/api/apis.dart';
import 'package:chat_app/models/message.dart';
import 'package:flutter/material.dart';

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width*.04),
            margin: EdgeInsets.symmetric(horizontal: mq.width*.04,vertical: mq.height*.01),
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 221, 245, 255),
                border: Border.all(color: Colors.lightBlue),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20),bottomRight: Radius.circular(20))
            ),
            child: Text(widget.message.msg,style: TextStyle(fontSize: 15,color: Colors.black),),

          ),
        ),
        
        Padding(
          padding: EdgeInsets.only(right: mq.width* .04),
          child: Text(
            widget.message.sent,
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
            Icon(Icons.done_all_rounded,color: Colors.blue,size: 20,),
            SizedBox(width: mq.width*.02,),
            Text(
              widget.message.read+'12.00 PM',
              style: TextStyle(fontSize: 13,color: Colors.black54),
            ),
          ],
        ),


        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width*.04),
            margin: EdgeInsets.symmetric(horizontal: mq.width*.04,vertical: mq.height*.01),
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 221, 245, 255),
                border: Border.all(color: Colors.lightGreen),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20),bottomLeft: Radius.circular(20))
            ),
            child: Text(widget.message.msg,style: TextStyle(fontSize: 15,color: Colors.black),),

          ),
        ),
      ],
    );
}
}