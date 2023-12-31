import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screens/view_profile_screen.dart';
import 'package:chat_app/widgets/call-invitation.dart';
import 'package:chat_app/widgets/message_card.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/message.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';


class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  List<Message> list=[];
  final _textController=TextEditingController();
  //storing value showing or hiding emoji
  bool _showEmoji=false,_isScrollng=false;
  @override
  Widget build(BuildContext context) {
    var mq=MediaQuery.of(context).size;
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          //if emojis are shown & back button is pressed then hide emojis
          //or else simple close current screen on back button click
          onWillPop: (){
            if(_showEmoji){
              setState(() {
                _showEmoji=!_showEmoji;

              });
              return Future.value(false);
            }else{
              return Future.value(true);
            }
          },
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
                      stream: APIs.getAllMessages(widget.user),
                      builder:(context,snapshot){
                        switch(snapshot.connectionState){
                        //if data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return SizedBox();

                        //if some or all data is loaded then it show
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data=snapshot.data?.docs;
                            // log('Data: ${jsonEncode(data![0].data())}');
                            list=data?.map((e) => Message.fromJson(e.data())).toList()??[];
                            list=data?.map((e) => Message.fromJson(e.data())).toList()??[];
                            // list.clear();
                            // list.add(Message(msg: 'hi', read: '', told: 'xyz', type: Type.text, fromId: APIs.user!.uid, sent: '11:00 PM'));
                            // list.add(Message(msg: 'hello', read: '', told: APIs.user!.uid, type: Type.text, fromId: 'xyz', sent: '12:00 PM'));
                            if(list.isNotEmpty){
                              return ListView.builder(
                                reverse: true,
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
                if(_isScrollng)
                  Align(
                  alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8,horizontal: 20),
                        child: CircularProgressIndicator(strokeWidth: 2,)
                    )
                  ),
                _chatInput(context),
                if(_showEmoji)
                  SizedBox(
                   height: mq.height*.35,
                   child:EmojiPicker(
                    textEditingController: _textController,
                    config: Config(
                      columns: 7,
                      emojiSizeMax: 32*(Platform.isIOS?1.30:1.0),
                    ),
                  )
                 ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar(BuildContext context){
    var mq=MediaQuery.of(context).size;
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewProfileScreen(user: widget.user,)));
      },
      child: StreamBuilder(
        stream: APIs.getUserInfo(widget.user),
        builder:(context,snapshot) {
          final data=snapshot.data?.docs;
          final list=data?.map((e) => ChatUser.fromJson(e.data())).toList()??[];

          return Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back),
                color: Colors.black,
              ),

              ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .03),
                child: CachedNetworkImage(
                  height: mq.height * .09,
                  width: mq.width * .09,
                  imageUrl:list.isNotEmpty?list[0].image: widget.user.image,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      CircleAvatar(child: Icon(Icons.person),),
                ),
              ),
              SizedBox(width: 10,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list.isNotEmpty?list[0].name:widget.user.name,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500
                    ),
                  ),

                  SizedBox(height: 2,),

                  Text(
                    list.isNotEmpty?list[0].isOnline?'Online'
                        :MyDateUtil.getLastActiveTime(context: context, lastActive: list[0].lastActive)
                        : MyDateUtil.getLastActiveTime(context: context, lastActive: widget.user.lastActive),

                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              SizedBox(width: mq.width*.03,),
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>CallInviationPage(username: widget.user.name)));
                },
                icon: Icon(Icons.call),
                color: Colors.black,
              ),
            ],
          );
        },
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
                      setState(() {
                        FocusScope.of(context).unfocus();
                        _showEmoji=!_showEmoji;
                      });
                    },
                    icon: Icon(Icons.emoji_emotions),
                    color: Colors.blueAccent,
                  ),

                  Expanded(
                      child: TextField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        onTap:(){
                          if(_showEmoji){
                            _showEmoji=!_showEmoji;
                          }
                        },
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Type something...',
                          hintStyle: TextStyle(color: Colors.blueAccent),
                          border: InputBorder.none
                        ),
                      )
                  ),

                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      final List<XFile> images = await picker.pickMultiImage(imageQuality: 70);
                      for(var i in images){
                        log('Image Path: ${i.path}');
                        setState(() {
                          _isScrollng=true;
                        });
                        APIs.sendChatImage(widget.user, File(i.path));
                        setState(() {
                          _isScrollng=false;
                        });
                      }

                    },
                    icon: Icon(Icons.image),
                    color: Colors.blueAccent,
                  ),

                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      final XFile? image = await picker.pickImage(source: ImageSource.camera,imageQuality: 70);
                      if(image!=null){
                        log('Image path: ${image.path}');
                        setState(() {
                          _isScrollng=true;
                        });
                        await APIs.sendChatImage(widget.user,File(image!.path));
                        setState(() {
                          _isScrollng=false;
                        });
                      }

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
              onPressed: (){
              if(_textController.text.isNotEmpty){
                if(list.isEmpty){
                  APIs.sendFirstMessage(widget.user, _textController.text,Type.text);
                }else{
                  APIs.sendMessage(widget.user, _textController.text,Type.text);
                }

                _textController.text='';
              }
              },
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
