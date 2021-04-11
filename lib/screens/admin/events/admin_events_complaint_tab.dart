import 'package:flutter/material.dart';
import 'package:parkapp/utils/constants.dart';
import 'package:parkapp/utils/functions.dart';
import 'package:parkapp/widgets/empty_list.dart';

import 'package:provider/provider.dart';

import '../../../providers/events_provider.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/event_item.dart';

class AdminEventsComplaintTab extends StatefulWidget {
  @override
  _AdminEventsComplaintTabState createState() => _AdminEventsComplaintTabState();
}

class _AdminEventsComplaintTabState extends State<AdminEventsComplaintTab> {

  bool _isLoadingPagination = false;
  int _offset = 0;
  int _limit = 20;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15,),
          Text("Eventos denunciados", style: TextStyle(color: AppTheme.getTheme().colorScheme.secondary, fontSize: 18),),
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
        if(eventsProvider.adminEventsComplaints.length > 0)
          return RefreshIndicator(
            onRefresh: () async {
              bool internet = await check(context);
              if(internet){
                await Future.wait([
                  eventsProvider.getAdminEventsComplained(),
                ]);
              }else{
                showErrorMessage(context, "No tienes conexion a internet");
              }
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo){
                if (!_isLoadingPagination && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                  if(eventsProvider.adminEventsComplaintsTotal > _limit){
                    paginacion(context);
                  }
                  return true;
                }
                return false;
              },
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: eventsProvider.adminEventsComplaints.length,
                  itemBuilder: (context, index) => EventItem(event: eventsProvider.adminEventsComplaints[index],),
                ),
              ),
            ),
          );
        return EmptyList(color: greyLightColor,);
      }
    );
  }

  void paginacion(BuildContext context) async {
    _isLoadingPagination = true;
    _offset+=20;
    _limit+=20;
    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
    bool internet = await check(context);
    if(internet){
      await Future.wait([
        eventsProvider.getAdminEventsComplained(limit: _limit, offset: _offset, search: null),
      ]);
    }else{
      showErrorMessage(context, "No tienes conexion a internet");
    }
    _isLoadingPagination = false;
  }
}