import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/chat_message_model.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

class LastMessageChat extends StatelessWidget {
  final stream;

  LastMessageChat({required this.stream});

  Widget typeWidget(ChatMessageModel message) {
    String? type = message.messageType;
    switch (type) {
      case TEXT:
        return Text(
          "${message.message.validate()}",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: secondaryTextStyle(size: 14),
        );
      case IMAGE:
        return Row(
          children: [
            Icon(Icons.photo_sharp, size: 16),
            6.width,
            Text(languages.lblImage, style: secondaryTextStyle(size: 14)),
          ],
        );
      case VIDEO:
        return Row(
          children: [
            Icon(Icons.videocam_outlined, size: 16),
            6.width,
            Text(languages.lblVideo, style: secondaryTextStyle(size: 14)),
          ],
        );
      case AUDIO:
        return Row(
          children: [
            Icon(Icons.audiotrack, size: 16),
            6.width,
            Text(languages.lblAudio, style: secondaryTextStyle(size: 14)),
          ],
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          var docList = snapshot.data!.docs;

          if (docList.isNotEmpty) {
            ChatMessageModel message = ChatMessageModel.fromJson(docList.last.data() as Map<String, dynamic>);
            String time = '';
            //DateTime date = DateTime.fromMicrosecondsSinceEpoch(message.createdAt! * 1000);
            time = DateFormat('hh:mm a').format(DateTime.fromMicrosecondsSinceEpoch(message.createdAt! * 1000));

            /*  if (date.day == DateTime.now().day) {
              time = DateFormat('hh:mm a').format(DateTime.fromMicrosecondsSinceEpoch(message.createdAt! * 1000));
            } else {
              time = DateFormat('dd/MM/yyy').format(DateTime.fromMicrosecondsSinceEpoch(message.createdAt! * 1000));
            }*/
            return Row(
              children: [
                typeWidget(message).expand(),
                Text(time, style: secondaryTextStyle()),
              ],
            ).paddingTop(2).expand();
          }
          return Text("", style: TextStyle(color: Colors.grey, fontSize: 14));
        }
        return Text("..", style: TextStyle(color: Colors.grey, fontSize: 14));
      },
    );
  }
}
