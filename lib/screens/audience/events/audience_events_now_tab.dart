import 'package:flutter/material.dart';

import 'package:parkapp/providers/events_provider.dart';
import 'package:parkapp/utils/constants.dart';
import 'package:parkapp/utils/functions.dart';
import 'package:parkapp/widgets/empty_list.dart';
import 'package:parkapp/widgets/event_item.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_theme.dart';

class AudienceEventsNowTab extends StatefulWidget {
  @override
  _AudienceEventsNowTabState createState() => _AudienceEventsNowTabState();
}

class _AudienceEventsNowTabState extends State<AudienceEventsNowTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15,),
          Text("Eventos comienzan ahora", style: TextStyle(color: AppTheme.getTheme().colorScheme.secondary, fontSize: 18),),
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
        if(eventsProvider.audienceEventsNow.length > 0)
          return RefreshIndicator(
            onRefresh: () async {
              bool internet = await check(context);
              if(internet){
                await Future.wait([
                  eventsProvider.getAudienceEventsClose(),
                  eventsProvider.getAudienceEventsNow(),
                  eventsProvider.getAudienceEventsWeekend(),
                ]);
              }else{
                showErrorMessage(context, "No tienes conexion a internet");
              }
            },
            child: Scrollbar(
              child: ListView.builder(
                itemCount: eventsProvider.audienceEventsNow.length,
                itemBuilder: (context, index) => EventItem(event: eventsProvider.audienceEventsNow[index],),
              )
            ),
          );
        return EmptyList(color: greyLightColor,);
      },
    );
  }
}