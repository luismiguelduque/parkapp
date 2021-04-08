import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../providers/events_provider.dart';
import '../../../utils/constants.dart';
import '../../../widgets/empty_list.dart';
import '../../../widgets/event_item.dart';
import '../../../utils/app_theme.dart';

class AudienceEventsWeekendTab extends StatefulWidget {
  @override
  _AudienceEventsWeekendTabState createState() => _AudienceEventsWeekendTabState();
}

class _AudienceEventsWeekendTabState extends State<AudienceEventsWeekendTab> {
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15,),
          Text("Eventos este fin de semana", style: TextStyle(color: AppTheme.getTheme().colorScheme.secondary, fontSize: 18),),
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
        if(eventsProvider.audienceEventsWeekend.length > 0)
          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                eventsProvider.getAudienceEventsClose(),
                eventsProvider.getAudienceEventsNow(),
                eventsProvider.getAudienceEventsWeekend(),
              ]);
            },
            child: Scrollbar(
              child: ListView.builder(
                itemCount: eventsProvider.audienceEventsWeekend.length,
                itemBuilder: (context, index) => EventItem(event: eventsProvider.audienceEventsWeekend[index],),
              )
            ),
          );
        return EmptyList(color: greyLightColor,);
      },
    );
  }
}