import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/functions.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble({
    this.message,
    this.createdAt,
    this.isMe,
    this.key
  });

  final Key key;
  final String message;
  final DateTime createdAt;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: isMe ? Colors.grey[300] : blueColor,
                borderRadius: BorderRadius.circular(12)
              ),
              width: size.width*0.65,
              padding: EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: isMe ? 15 : 35,
                right: isMe ? 35 : 15,
              ),
              margin: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 8,
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    "${formaterDateTime(createdAt)}",
                    style: text5.copyWith(color: isMe ? greyLightColor : blueLightColor),
                  ),
                  Text(
                    "$message",
                    style: text4.copyWith(color: isMe ? blackColor : whiteColor),
                    textAlign: isMe ? TextAlign.start : TextAlign.end,
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: 0,
          left: isMe ? null : 0,
          right: isMe ? 0 : null,
          child: CircleAvatar(
            radius: 25,
            backgroundColor: primaryColor,
            child: !isMe ? Image(
              image: AssetImage("assets/images/simple-icon.png"),
            ) : Text("Tu", style: title3.copyWith(color: secondaryColor),),
          ),
        ),
      ],
      overflow: Overflow.visible,
    );
  }
}
