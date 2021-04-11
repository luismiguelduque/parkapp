import 'package:flutter/material.dart';
import 'package:parkapp/utils/functions.dart';

import 'package:provider/provider.dart';

import '../../../utils/constants.dart';
import '../../../models/conversation_model.dart';
import '../../../providers/chat_provider.dart';
import '../../../widgets/messages.dart';
import '../../../widgets/new_message.dart';
import '../../../widgets/custom_bottom_menu.dart';

class AdminChatScreen extends StatefulWidget {
  @override
  _AdminChatScreenState createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {

  bool _isLoaded = false;
  bool _isLoading = false;
  ConversationModel _conversation;
  
  @override
  void didChangeDependencies() async {
    if(!_isLoaded){
      final int conversationId = ModalRoute.of(context).settings.arguments;
      _conversation = Provider.of<ChatProvider>(context, listen: false).adminAllConversations.firstWhere((item) => item.id == conversationId);
      _isLoading = true;
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      bool internet = await check(context);
      if(internet){
        await Future.wait([
          chatProvider.getUserConversation(),
        ]);
      }else{
        showErrorMessage(context, "No tienes conexion a internet");
      }
      setState(() {
        _isLoading = false;
        _isLoaded = true;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: Container(
        height: 58 + MediaQuery.of(context).padding.bottom,
        child: CustomBottomMenu(current: 3)
      ),
      body: _isLoading ? Center(
          child: CircularProgressIndicator(),
        ) : SafeArea(
        child: Consumer<ChatProvider>(
          builder: (ctx, chatProvider, _){
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: (){
                          Navigator.of(context).pushNamed("admin-messages");
                        },
                        icon: Icon(Icons.arrow_back),
                      ),
                      Container(
                        width: size.width*0.7,
                        child: Text("Mensajes con ${_conversation.user.name}", style: title1.copyWith(color: greyLightColor),)
                      ),
                    ],
                  ),
                  Expanded(
                    child: Messages(conversationId: _conversation.conversationId,),
                  ),
                  NewMessage(conversation: _conversation),
                ]
              )
            );
          },
        )
      )
    );
  }
}