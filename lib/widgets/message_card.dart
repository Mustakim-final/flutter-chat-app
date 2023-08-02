
import 'dart:developer';

import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/models/message.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  const MessageCard({Key? key, required this.message}) : super(key: key);

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    //before bottom sheet add
    // return APIs.user!.uid==widget.message.fromId?_greenMessage(context):_blueMessage(context);
    //after add bottom sheet

    bool isMe=APIs.user!.uid==widget.message.fromId;
    return InkWell(
      onLongPress: (){
        _showBottomSheet(isMe);
      },
      child: isMe?_greenMessage(context):_blueMessage(context),
    );


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

  void _showBottomSheet(bool isMe){
    var mq=MediaQuery.of(context).size;

    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),topRight: Radius.circular(20)
          )
        ),
        builder: (_){
          return ListView(
            shrinkWrap: true,

            children: [
              //black divider
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                  vertical: mq.height*.015,horizontal: mq.width*.4
                ),
                decoration: BoxDecoration(
                  color: Colors.grey,borderRadius: BorderRadius.circular(8)
                ),
              ),

              //copy text
              widget.message.type==Type.text?
              OtionItem(
                  icon: Icon(Icons.copy_all_rounded,color: Colors.blue,size: 26,),
                  name: 'Copy text', onTap: () async {
                    await Clipboard.setData(ClipboardData(text: widget.message.msg)).then((value) {
                      Navigator.pop(context);
                      Dialogs.showSnackbar(context, "Copied");
                    });
              }):
                  //save option
              OtionItem(
                  icon: Icon(Icons.download,color: Colors.blue,size: 26,),
                  name: 'save image', onTap: () async {

                    try{
                      await GallerySaver.saveImage(widget.message.msg,albumName: 'Barta').then((value) {
                        Navigator.pop(context);
                        if(value!=null  && value){
                          Dialogs.showSnackbar(context, "save image");
                        }

                      });
                    }catch(e){
                      log('image save error: $e');
                    }
                   
              }),

              //separator or divider
              Divider(
                color: Colors.black54,
                endIndent: mq.width*.04,
                indent: mq.height*.04,
              ),
              //edit option
              if(widget.message.type==Type.text && isMe)
                 OtionItem(
                    icon: Icon(Icons.edit,color: Colors.blue,size: 26,),
                     name: 'Edit message', onTap: (){
                      Navigator.pop(context);
                      showMessageDialog();
                 }),
              //delete option
              if(isMe)
                  OtionItem(
                     icon: Icon(Icons.delete_forever,color: Colors.red,size: 26,),
                     name: 'Delete', onTap: () async {
                       await APIs.deleteMessage(widget.message).then((value) {
                         Navigator.pop(context);
                       });
                  }),

              //separator or divider
              if(isMe)
                  Divider(
                    color: Colors.black54,
                    endIndent: mq.width*.04,
                    indent: mq.height*.04,
                  ),
              //sent item
              OtionItem(
                  icon: Icon(Icons.remove_red_eye,color: Colors.blue,size: 26,),
                  name: 'Sent At ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}', onTap: (){}),
              //read item
              OtionItem(
                  icon: Icon(Icons.remove_red_eye,color: Colors.green,size: 26,),
                  name: widget.message.read.isEmpty
                  ?'Read At: Not seen yet':
                  'Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}', onTap: (){}),
            ],
          );
        }
    );
  }

  //show message update dialog
 void showMessageDialog(){
    String updateMsg=widget.message.msg;
    showDialog(
        context: context,
        builder: (context)=>AlertDialog(
          contentPadding: EdgeInsets.only(left: 24,right: 24,top: 20,bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.message,color: Colors.blue,size: 28,),
              Text("Update Message"),
            ],
          ),
          content: TextFormField(
            initialValue: updateMsg,
            maxLines: null,
            onChanged: (value)=>updateMsg=value,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))
            ),
          ),
          actions: [
            MaterialButton(onPressed: (){
              Navigator.pop(context);
            },child: Text("Cancel",style: TextStyle(color: Colors.blue,fontSize: 16),),),

            MaterialButton(onPressed: (){
              Navigator.pop(context);
              APIs.updateMessage(widget.message, updateMsg);
            },child: Text("Update",style: TextStyle(color: Colors.blue,fontSize: 16),),),
          ],
        )
    );
 }
}

class OtionItem extends StatelessWidget {


  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const OtionItem({Key? key, required this.icon, required this.name, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mq=MediaQuery.of(context).size;
    return InkWell(
      onTap: ()=>onTap(),
      child: Padding(
        padding: const EdgeInsets.only(left: 15,top: 7,bottom: 20),
        child: Row(
          children: [
            icon,Flexible(child: Text('   $name',style: TextStyle(fontSize: 15,color: Colors.black54,letterSpacing: 0.5),))
          ],
        ),
      ),
    );
  }
}



