import 'package:flutter/material.dart';
import 'package:parkapp/utils/functions.dart';

import 'package:provider/provider.dart';

import '../../../providers/chat_provider.dart';
import '../../../utils/constants.dart';
import '../../../widgets/messages.dart';
import '../../../widgets/new_message.dart';
import '../../../widgets/custom_bottom_menu.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  bool _isLoaded = false;
  bool _isLoading = false;
  
  @override
  void didChangeDependencies() async {
    if(!_isLoaded){
      _isLoading = true;
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      bool internet = await check(context);
      if(internet){
        await Future.wait([
          chatProvider.getUserConversation(),
        ]);
      }else{
        showErrorMessage(context, "No tienes conexión a internet");
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
    return Scaffold(
      bottomNavigationBar: Container(
        height: 58 + MediaQuery.of(context).padding.bottom,
        child: CustomBottomMenu(current: 4)
      ),
      body: _isLoading ? Center(
          child: CircularProgressIndicator(),
        ) : SafeArea(
        child: Consumer<ChatProvider>(
          builder: (ctx, chatProvider, _){
            print("chatProvider.userConversation.conversationId");
            print(chatProvider.userConversation.conversationId);
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10,),
                    child: Text("Mensajes con Park App", style: title1.copyWith(color: secondaryColor),),
                  ),
                  Text("Dejanos tus comentarios o consultas. Nos comunicaremos a la brevedad", style: text3.copyWith(color: greyLightColor),),
                  Expanded(
                    child: Messages(conversationId: chatProvider.userConversation.conversationId,),
                  ),
                  NewMessage(conversation: chatProvider.userConversation),
                ]
              )
            );
          },
        )
      )
    );
  }
}