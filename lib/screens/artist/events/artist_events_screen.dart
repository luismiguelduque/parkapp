import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../models/event_model.dart';
import '../../../models/place_model.dart';
import '../../../utils/constants.dart';
import '../../../utils/preferences.dart';
import '../../../utils/app_theme.dart';
import '../../../providers/events_provider.dart';
import '../../../providers/places_provider.dart';
import '../../../providers/artists_provider.dart';
import 'artist_event_draft_tab.dart';
import 'artist_event_published_tab.dart';
import 'artist_event_resume_tab.dart';
import '../../../widgets/custom_bottom_menu.dart';

class ArtistEventsScreen extends StatefulWidget {
  @override
  _ArtistEventsScreenState createState() => _ArtistEventsScreenState();
}

class _ArtistEventsScreenState extends State<ArtistEventsScreen> {

  bool _isLoaded = false;
  bool _isLoading = false;
  final _preferences = new Preferences();
  
  @override
  void didChangeDependencies() async {
    if(!_isLoaded){
      _isLoading = true;
      final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
      final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
      final artistsProvider = Provider.of<ArtistsProvider>(context, listen: false);
      await Future.wait([
        eventsProvider.getArtistEvents(),
        placesProvider.getPlaces(),
        artistsProvider.getArtistDetail(_preferences.artistId),
      ]);
      setState(() {
        _isLoading = false;
        _isLoaded = true;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        bottomNavigationBar: Container(
          height: 58 + MediaQuery.of(context).padding.bottom,
          child: CustomBottomMenu(current: 1)
        ),
        floatingActionButton: _accauntSuspended(
          widget: Container(),
          defaultValue: FloatingActionButton(
            backgroundColor: AppTheme.getTheme().colorScheme.secondary,
            onPressed: () => {
              Provider.of<EventsProvider>(context, listen: false).eventDetail = new EventModel(
                place: new PlaceModel(),
                categories: [],
              ),
              Navigator.of(context).pushNamed('artist-events-form')
            },
            child: Icon(Icons.add, size: 35, color: Colors.white,),
          ),
        ),
        body: _isLoading ? Center(
            child: CircularProgressIndicator(),
          ) : SafeArea(
          child: DefaultTabController(
          length: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Mis eventos", style: AppTheme.getTheme().textTheme.headline1,),
                    ],
                  )
                ),
                _accauntSuspended(
                  widget: Container(
                    color: redColor.withOpacity(0.1),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info, color: redColor, size: 28,),
                        SizedBox(width: 3,),
                        Text("Tu cuenta ha sido suspendida", style: title3.copyWith(color: redColor),),
                      ],
                    )
                  ),
                  defaultValue: Container(),
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
        color: AppTheme.getTheme().colorScheme.secondary,
        borderRadius: BorderRadius.circular(30)
      ),
      child: TabBar(
        indicatorColor: AppTheme.getTheme().colorScheme.primary,
        labelColor: AppTheme.getTheme().colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        unselectedLabelColor: Colors.grey,
        tabs: [
          Tab(
            child: Text("Resumen", style: TextStyle(fontSize: 14),),
          ),
          Tab(
            child: Text("Publicados", style: TextStyle(fontSize: 14),),
          ),
          Tab(
            child: Text("Borrador", style: TextStyle(fontSize: 14),),
          ),
        ],
      ),
    );
  }

  Widget _tabsContentSection(){
    return Container(
      child: TabBarView(children: [
          ArtistEventsResumeTab(),
          ArtistEventsPublishedTab(),
          ArtistEventsDraftTab(),
        ]
      ),
    );
  }

  Widget _accauntSuspended({Widget widget, Widget defaultValue}){
    return Consumer<ArtistsProvider>(
      builder: (ctx, artistsProvider, _){
        if(!_isLoading){
          if(artistsProvider.artistDetail.status =="3"){
            return widget;
          }
        }
        return defaultValue;
      },
    );
  }
}