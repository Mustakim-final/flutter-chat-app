import 'package:chat_app/helper/utils.dart';
import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallInviationPage extends StatelessWidget {
  final String username;
  const CallInviationPage({Key? key,required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
        appID: Utils.appid,
        appSign: Utils.appSignIn,
        callID: "123",
        userID: username,
        userName: username,
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
        ..onOnlySelfInRoom=(context){
          Navigator.pop(context);
        },
    );
  }
}
