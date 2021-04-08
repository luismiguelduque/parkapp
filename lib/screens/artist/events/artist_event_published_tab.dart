import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../providers/events_provider.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/event_item.dart';

class ArtistEventsPublishedTab extends StatefulWidget {
  @override
  _ArtistEventsPublishedTabState createState() => _ArtistEventsPublishedTabState();
}

class _ArtistEventsPublishedTabState extends State<ArtistEventsPublishedTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15,),
          Text("Tus eventos publicados", style: TextStyle(color: AppTheme.getTheme().colorScheme.secondary, fontSize: 18),),
          SizedBox(height: 15,),
          _headerSection(),
          Expanded(
            child: _eventsList(),
          ),
        ],
      )
    );
  }

  Widget _headerSection(){
    return Container();
  }

  Widget _eventsList(){
    return Consumer<EventsProvider>(
      builder: (ctx, eventsProvider, _){
        return ListView.builder(
          itemCount: eventsProvider.artistEvents.length,
          itemBuilder: (context, index) => EventItem(event: eventsProvider.artistEvents[index],),
        );
      },
    );
  }
}