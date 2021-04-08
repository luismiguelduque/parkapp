//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:parkapp/providers/users_provider.dart';
import 'package:parkapp/utils/functions.dart';

import 'package:parkapp/utils/preferences.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../providers/events_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/app_theme.dart';
import '../../../providers/chat_provider.dart';
import './audience_events_close_tab.dart';
import './audience_events_now_tab.dart';
import './audience_events_weekend_tab.dart';
import '../../../widgets/custom_bottom_menu.dart';

class AudienceEventsScreen extends StatefulWidget {
  @override
  _AudienceEventsScreenState createState() => _AudienceEventsScreenState();
}

class _AudienceEventsScreenState extends State<AudienceEventsScreen> {

  final _preferences = new Preferences();
  bool _isLoaded = false;
  bool _isLoading = false;
  Position _currentPosition;
  
  @override
  void didChangeDependencies() async {
    if(!_isLoaded){
      _isLoading = true;
      _currentPosition = await getCurrentUserLocation();
      final usersProvider = Provider.of<UsersProvider>(context, listen: false);
      final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
      await usersProvider.setUserLocation(_currentPosition.latitude.toString(), _currentPosition.longitude.toString());
      await Future.wait([
        eventsProvider.getAudienceEventsClose(),
        eventsProvider.getAudienceEventsNow(),
        eventsProvider.getAudienceEventsWeekend(),
      ]);
      //final fbm = FirebaseMessaging();
      //final _phoneToken = await fbm.getToken();
      //usersProvider.setUserFCM(_phoneToken);
      setState(() {
        _isLoading = false;
        _isLoaded = true;
      });
      sendFirstMessage();
    }
    super.didChangeDependencies();
  }

  Future<void> sendFirstMessage() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.getUserConversation();
    final id = chatProvider.userConversation.conversationId;
    if(id == null){
      /*
      DocumentReference docRef = await Firestore.instance.collection('conversations').add({"user_id": _preferences.userId});
      final conversationId = docRef.documentID;
      docRef.collection("messages").add({
        'text': "¡Bienvenido a ParkApp! Disfrutá de todos los eventos cerca de tu zona. Si sos artista y querés cargar eventos, entrá a 'Perfil', luego a 'Registrarme como artista' y solicitá ser parte de esta comunidad.",
        'created_at': Timestamp.now(),
        'is_admin': true,
      });
      final data = await chatProvider.storeConversation(conversationId);
      await chatProvider.updateLastMessage(data['id'], "¡Bienvenido a ParkApp! Disfrutá de todos los eventos cerca de tu zona...", 1, _preferences.userId);
      await chatProvider.getUserConversation();
      */
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        bottomNavigationBar: Container(
          height: 58 + MediaQuery.of(context).padding.bottom,
          child: CustomBottomMenu(current: _preferences.userTypeId == 1 ? 1 : 2)
        ),
        body: SafeArea(
          child: DefaultTabController(
          length: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 5,),
                          Text("Eventos", style: title1.copyWith(color: greyLightColor),),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.search, size: 35, color: AppTheme.getTheme().colorScheme.primary,),
                        onPressed: (){
                          Navigator.of(context).pushNamed("search-screen");
                        },
                      ),
                    ],
                  )
                ),
                SizedBox(height: 5,),
                _tabsSection(),
                Expanded(
                  child: _tabsContentSection(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _tabsSection(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.getTheme().colorScheme.primary,
        borderRadius: BorderRadius.circular(30)
      ),
      child: TabBar(
        indicatorColor: AppTheme.getTheme().colorScheme.secondary,
        labelColor: AppTheme.getTheme().colorScheme.secondary,
        indicatorSize: TabBarIndicatorSize.label,
        unselectedLabelColor: Colors.blueGrey,
        tabs: [
          Tab(
            child: Text("Cercanos", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
          ),
          Tab(
            child: Text("Ahora", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
          ),
          Tab(
            child: Text("Este finde", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
          ),
        ],
      ),
    );
  }

  Widget _tabsContentSection(){
    return Container(
      child: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          AudienceEventsCloseTab(),
          AudienceEventsNowTab(),
          AudienceEventsWeekendTab(),
        ]
      ),
    );
  }

  
}