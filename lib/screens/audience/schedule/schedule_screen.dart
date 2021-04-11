import 'package:flutter/material.dart';
import 'package:parkapp/utils/functions.dart';

import 'package:provider/provider.dart';

import '../../../utils/constants.dart';
import '../../../widgets/empty_list.dart';
import '../../../widgets/event_item.dart';
import '../../../providers/events_provider.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/custom_bottom_menu.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {

  bool showFilter = false;
  bool _isLoaded = false;
  bool _isLoading = true;
  bool _currentOnly = true;

  @override
  void didChangeDependencies() async {
    if (!_isLoaded) {
      _isLoading = true;
      bool internet = await check(context);
      if(internet){
        await Provider.of<EventsProvider>(context, listen: false).getUserSheduledEvent();
      }else{
        showErrorMessage(context, "No tienes conexion a internet");
      }
      setState(() {
        _isLoading = false;
      });
      _isLoaded = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        height: 58 + MediaQuery.of(context).padding.bottom,
        child: CustomBottomMenu(current: 3)
      ),
      body:SafeArea(
        child: _isLoading ?
          Center(
            child: CircularProgressIndicator(),
          ) : Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
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
                        Text("Mi agenda", style: title1.copyWith(color: greyLightColor),),
                      ],
                    ),
                  ], 
                )
              ),
              SizedBox(height: 5,),
              Consumer<EventsProvider>(
                builder: (ctx, eventsProvider, _){
                  return Row(
                    children: [
                      Text("${eventsProvider.scheduledEvents.length} ", style: TextStyle(color: AppTheme.getTheme().colorScheme.secondary, fontSize: 18, fontWeight: FontWeight.bold),),
                      Text("Eventos agendados", style: TextStyle(color: AppTheme.getTheme().colorScheme.secondary, fontSize: 18),),
                    ],
                  );
                },
              ),
              SizedBox(height: 10,),
              _headerSection(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Switch(
                    activeColor: secondaryColor,
                    onChanged: (value){
                      setState(() {
                        _currentOnly = value;
                        Provider.of<EventsProvider>(context, listen: false).sheduledActiveOnly = value;
                      });
                    },
                    value: _currentOnly,
                  ),
                  Text("Solo vigentes", style: text4.copyWith(color:secondaryColor),),
                ],
              ),
              Expanded(
                child: _eventsList(),
              ),
            ]
          ),
        )
      )
    );
  }

  Widget _headerSection(){
    return Container();
  }

  Widget _eventsList(){
    return Consumer<EventsProvider>(
      builder: (ctx, eventsProvider, _){
        if(eventsProvider.scheduledEvents.length > 0) {
          return RefreshIndicator(
            onRefresh: () async {
              bool internet = await check(context);
              if(internet){
                await Future.wait([
                  eventsProvider.getUserSheduledEvent(),
                ]);
              }else{
                showErrorMessage(context, "No tienes conexion a internet");
              }
            },
            child: Scrollbar(
              child: ListView.builder(
                itemCount: eventsProvider.scheduledEvents.length,
                itemBuilder: (context, index) => EventItem(event: eventsProvider.scheduledEvents[index],),
              ),
            ),
          );
        }
        return EmptyList(color: greyLightColor,);
      },
    );
  }
}