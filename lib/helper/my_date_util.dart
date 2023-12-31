import 'package:flutter/material.dart';

class MyDateUtil{
  //for getting formatted time
  static String getFormattedTime({required BuildContext context,required String time}){
    final date=DateTime.fromMicrosecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  //get formatted time sen and read
  static String getMessageTime({required BuildContext context,required String time}){
    final DateTime sent=DateTime.fromMicrosecondsSinceEpoch(int.parse(time));
    final DateTime now=DateTime.now();

    final formattedTime=TimeOfDay.fromDateTime(sent).format(context);
    if(now.day==sent.day && now.month==sent.month && now.year==sent.year){
      return TimeOfDay.fromDateTime(sent).format(context);
    }

    return now.year==sent.year?'$formattedTime - ${sent.day} ${getMonth(sent)}':'$formattedTime - ${sent.day} ${getMonth(sent)} ${sent.year}';
  }


  //get last message time(use in chat user card)
  static String getLastMessageTime({required BuildContext context,required String time,bool showYear=false}){
    final DateTime sent=DateTime.fromMicrosecondsSinceEpoch(int.parse(time));
    final DateTime now=DateTime.now();

    if(now.day==sent.day && now.month==sent.month && now.year==sent.year){
      return TimeOfDay.fromDateTime(sent).format(context);
    }

    return showYear?'${sent.day} ${getMonth(sent)} ${sent.year}': '${sent.day} ${getMonth(sent)}';

  }

  //get formatted last active time of user in chat screen

  static String getLastActiveTime({required BuildContext context,required String lastActive}){
    final int i=int.tryParse(lastActive)??-1;

    //if time is not availabel the return statment
    if(i==-1)
      return 'Last seen not available';
    DateTime time=DateTime.fromMicrosecondsSinceEpoch(i);
    DateTime dateTime=DateTime.now();

    String formattedTime=TimeOfDay.fromDateTime(time).format(context);

    if(time.day==dateTime.day && time.month==dateTime.month && time.year==dateTime.year){
      return 'Last seen today at $formattedTime}';
    }

    String month=getMonth(time);
    return 'Last seen on ${time.day} $month on $formattedTime';

  }

  //get month name form month no or index
  static String getMonth(DateTime date){
    switch(date.month){
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
    }
    return 'NA';
  }
}