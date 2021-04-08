import 'package:flutter/material.dart';

import 'package:flushbar/flushbar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import '../utils/constants.dart';
import '../utils/app_theme.dart';
import '../utils/preferences.dart';

class CustomBottomMenu extends StatefulWidget {

  final int current;

  CustomBottomMenu({
    this.current
  });

  @override
  _CustomBottomMenuState createState() => _CustomBottomMenuState();
}

class _CustomBottomMenuState extends State<CustomBottomMenu> {

  bool _isLoaded = false;
  final _preferences = new Preferences();
  
  @override
  void didChangeDependencies() async {
    if(!_isLoaded){
      
      _isLoaded = true;
    }
    super.didChangeDependencies();
  }

  @override
  void initState() { 
    super.initState();
    FirebaseMessaging fbm = FirebaseMessaging.instance;
    fbm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Flushbar(
        title:  message.notification.title,
        message:  message.notification.body,
        duration:  Duration(seconds: 3),
        onTap: (data){
          notificationGo(message);
        },             
      )..show(context); 
      if(_preferences.userType == 3 && message.data["type"] == "NEW_MESSAGE"){
        Provider.of<ChatProvider>(context, listen: false).getAdminAllConversation();
      }
      return;
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      notificationGo(message);
      return;
    });
    FirebaseMessaging.onBackgroundMessage((message) {
      notificationGo(message);
      return;
    });
  }

  void notificationGo(msg){
    if(msg['data']["type"]== "ARTIST_ACCOUNT_ACTIVATED"){
      Navigator.of(context).pushNamed("artist-events");
      //Provider.of<AuthProvider>(context).setPreferencesUserData({});
    }else if(msg['data']["type"]== "ARTIST_ACCOUNT_SUSPENDED"){
      Navigator.of(context).pushNamed("artist-events");
      //Provider.of<AuthProvider>(context).setPreferencesUserData({});
    }else if(msg['data']["type"]== "ARTIST_ACCOUNT_REJECTED"){
      Navigator.of(context).pushNamed("audience-events");
    }else if(msg['data']["type"]== "ARTIST_ACCOUNT_REACTIVATED"){
      Navigator.of(context).pushNamed("artist-events");
    }else if(msg['data']["type"]== "EVENT_CREATED_ON_NEIGHBORHOOD"){
      Navigator.of(context).pushNamed("event-detail", arguments: msg['data']["event_id"]);
    }else if(msg['data']["type"]== "EVENT_FROM_ARTIST_THAT_FOLLOW"){
      Navigator.of(context).pushNamed("event-detail", arguments: msg['data']["event_id"]);
    }else if(msg['data']["type"]== "APPROVED_EVENT_AT_RESTRICTED_PLACE"){
      Navigator.of(context).pushNamed("event-detail", arguments: msg['data']["event_id"]);
    }else if(msg['data']["type"]== "REJECTED_EVENT_AT_RESTRICTED_PLACE"){
      Navigator.of(context).pushNamed("event-detail", arguments: msg['data']["event_id"]);
    }else if(msg['data']["type"]== "ARTIST_DENOUNCED"){
      Navigator.of(context).pushNamed("admin-artists");
    }else if(msg['data']["type"]== "EVENT_DENOUNCED"){
      Navigator.of(context).pushNamed("admin-events");
    }else if(msg['data']["type"]== "ADMIN_ARTIST_REQUEST"){
      Navigator.of(context).pushNamed("admin-artists");
    }else if(msg['data']["type"]== "EVENT_CREATED_ON_RESTRICTED_PLACE"){
      Navigator.of(context).pushNamed("admin-events");
    }else if(msg['data']["type"]== "NEW_MESSAGE"){
      if(_preferences.userTypeId == 1){
        Navigator.of(context).pushNamed("messages");
      }else if(_preferences.userTypeId == 2){ 
        Navigator.of(context).pushNamed("messages");
      }else if(_preferences.userTypeId == 3){
        Navigator.of(context).pushNamed("admin-messages");
      }else{
        Navigator.of(context).pushNamed("messages");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    List<Widget> familiMenu = [
      _iconButtonItem(context, (widget.current == 1), Icons.home, "audience-events", "Eventos", false),
      _iconButtonItem(context, (widget.current == 2), Icons.people, "audience-artists", "Artistas", false),
      _iconButtonItem(context, (widget.current == 3), Icons.favorite, "audience-schedule", "Agenda", false),
      _iconButtonItem(context, (widget.current == 4), Icons.send, "messages", "Mensajes", chatProvider.userConversation.unreadUser == "1"),
      _iconButtonItem(context, (widget.current == 5), Icons.person, "audience-profile", "Perfil", false),
    ];
    List<Widget> artistMenu = [
      _iconButtonItem(context, (widget.current == 1), Icons.home, "artist-events", "Eventos", false),
      _iconButtonItem(context, (widget.current == 2), Icons.stars, "audience-events", "Otros", false),
      _iconButtonItem(context, (widget.current == 3), Icons.favorite, "audience-schedule", "Agenda", false),
      _iconButtonItem(context, (widget.current == 4), Icons.send, "messages", "Mensajes", chatProvider.userConversation.unreadUser == "1"),
      _iconButtonItem(context, (widget.current == 5), Icons.person, "artist-profile-options", "Perfil", false),
    ];
    List<Widget> adminMenu = [
      _iconButtonItem(context, (widget.current == 1), Icons.home, "admin-events", "Eventos", false),
      _iconButtonItem(context, (widget.current == 2), Icons.people, "admin-artists", "Artistas", false),
      _iconButtonItem(context, (widget.current == 3), Icons.send, "admin-messages", "Mensajes", false),
      _iconButtonItem(context, (widget.current == 4), Icons.settings, "settings", "Ajustes", false),
      _iconButtonItem(context, (widget.current == 5), Icons.person, "admin-profile", "Perfil", false),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getTheme().backgroundColor,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppTheme.getTheme().dividerColor,
            blurRadius: 2,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: _preferences.userTypeId==1 ? familiMenu : _preferences.userTypeId==2 ? artistMenu : adminMenu,
      ),
    );
  }

  Widget _iconButtonItem(BuildContext context, bool selected, IconData icon, String route, String text, bool putDot) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: AppTheme.getTheme().primaryColor.withOpacity(0.2),
          onTap: () async {
            if(putDot && text == "Mensajes"){
              final chatProvider = Provider.of<ChatProvider>(context, listen: false);
              chatProvider.setRead(chatProvider.userConversation.id);
            }
            Navigator.pushNamed(context, route);
            if(_preferences.userTypeId != 3){
              Provider.of<ChatProvider>(context, listen: false).getUserConversation();
            }
          },
          child: Column(
            children: <Widget>[
              SizedBox(height: 4),
              Container(
                width: 40,
                height: 32,
                child:  Stack(
                  children: [
                    Positioned(
                      left: 5,
                      child: Icon(
                        icon,
                        color: selected ? AppTheme.getTheme().colorScheme.secondary : AppTheme.getTheme().disabledColor,
                        size: 28,
                      ),
                    ),
                    if(putDot)
                      Positioned(
                        child: CircleAvatar(
                          backgroundColor: redColor,
                          radius: 6,
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  text,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: selected ? AppTheme.getTheme().colorScheme.secondary : AppTheme.getTheme().disabledColor
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
