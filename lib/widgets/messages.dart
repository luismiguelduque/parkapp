import 'package:flutter/material.dart';

//import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/preferences.dart';
import './message_bubble.dart';

class Messages extends StatelessWidget {

  Messages({
    this.conversationId
  });

  final String conversationId;
  final _preferences = new Preferences();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      /*
      stream: Firestore.instance
          .collection('conversations').document("$conversationId").collection("messages")
          .orderBy(
            'created_at',
            descending: true,
          )
          .snapshots(),
        builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final chatDocs = chatSnapshot.data.documents;
        return ListView.builder(
          reverse: true,
          itemCount: chatDocs.length,
          itemBuilder: (ctx, index){
            bool isMe = false;
            if(_preferences.userTypeId == 3){
              isMe = chatDocs[index]['is_admin'];
            }else{
              isMe = !chatDocs[index]['is_admin'];
            }
            return  MessageBubble(
              message: chatDocs[index]['text'],
              createdAt: chatDocs[index]['created_at'].toDate(),
              isMe: isMe,
              key: ValueKey(chatDocs[index].documentID),
            );
          },
        );
      }
      */
    );
    
  }
}