import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/conversation_model.dart';
import './../utils/constants.dart';
import './../utils/preferences.dart';
import './../providers/chat_provider.dart';
import './../widgets/custom_textfield.dart';

class NewMessage extends StatefulWidget {

  NewMessage({
    this.conversation,
  });

  final ConversationModel conversation;

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {

  String _messajeText = "";
  bool _isSaving = false;
  final _preferences = new Preferences();
  final textController = TextEditingController();

   @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: CustomTextfield(
              controller: textController,
              onChanged: (value){
                _messajeText = value;
              },
              label: "Enviar un mensaje",
              horizontalMargin: 5,
              maxLines: 2,
            )
          ),
          SizedBox(width: 5,),
          GestureDetector(
            onTap: !_isSaving ? _sendMessage : null,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: blueColor,
              child: !_isSaving ? Icon(Icons.send, color: whiteColor,) : CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if(_messajeText !=""){
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      setState(() {
        _isSaving = true;
      });
      if(widget.conversation.conversationId == ""  || widget.conversation.conversationId == null){
        
        DocumentReference docRef = await FirebaseFirestore.instance.collection('conversations').add({"user_id": _preferences.userId});
        final conversationId = docRef.id;
        docRef.collection("messages").add({
          'text': _messajeText,
          'created_at': Timestamp.now(),
          'is_admin': _preferences.userTypeId == 3,
        });
        
        final data = await chatProvider.storeConversation(conversationId);
        await chatProvider.updateLastMessage(data['id'], _messajeText, _preferences.userId, _preferences.userTypeId == 3 ? widget.conversation.user.id : null);
        await chatProvider.getUserConversation();
        
      }else{
        FocusScope.of(context).unfocus();
        
        FirebaseFirestore.instance.collection('conversations').doc("${widget.conversation.conversationId}").collection("messages").add({
          'text': _messajeText,
          'created_at': Timestamp.now(),
          'is_admin': _preferences.userTypeId == 3,
        });
        
        await chatProvider.updateLastMessage(widget.conversation.id, _messajeText, _preferences.userId, _preferences.userTypeId == 3 ? widget.conversation.user.id : null);
      }
      
      setState(() {
        _isSaving = false;
        textController.clear();
        _messajeText = "";
      });
    }
  }
}
