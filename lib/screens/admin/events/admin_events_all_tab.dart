import 'package:flutter/material.dart';
import 'package:parkapp/utils/functions.dart';

import 'package:provider/provider.dart';

import '../../../utils/constants.dart';
import '../../../utils/app_theme.dart';
import '../../../providers/events_provider.dart';
import '../../../widgets/empty_list.dart';
import '../../../widgets/event_item.dart';

class AdminEventsAllTab extends StatefulWidget {
  @override
  _AdminEventsAllTabState createState() => _AdminEventsAllTabState();
}

class _AdminEventsAllTabState extends State<AdminEventsAllTab> {

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
          Text("Todos los eventos", style: TextStyle(color: AppTheme.getTheme().colorScheme.secondary, fontSize: 18),),
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
        if(eventsProvider.adminEventsAll.length > 0)
          return RefreshIndicator(
            onRefresh: () async {
              bool internet = await check(context);
              if(internet){
                await Future.wait([
                  eventsProvider.getAdminEventsAll(),
                ]);
              }else{
                showErrorMessage(context, "No tienes conexion a internet");
              }
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo){
                if (!_isLoadingPagination && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                  if(eventsProvider.adminEventsAllTotal > _limit){
                    paginacion(context);
                  }
                  return true;
                }
                return false;
              },
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: eventsProvider.adminEventsAll.length,
                  itemBuilder: (context, index) => EventItem(event: eventsProvider.adminEventsAll[index],),
                ),
              ),
            ),
          );
        return EmptyList(color: greyLightColor,);
      },
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
        eventsProvider.getAdminEventsAll(limit: _limit, offset: _offset, search: null),
      ]);
    }else{
      showErrorMessage(context, "No tienes conexion a internet");
    }
    _isLoadingPagination = false;
  }
}