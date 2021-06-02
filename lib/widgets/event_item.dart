import 'package:flutter/material.dart';

import 'package:parkapp/utils/preferences.dart';
import 'package:provider/provider.dart';

import '../utils/constants.dart';
import '../utils/functions.dart';
import '../utils/app_theme.dart';
import '../models/event_model.dart';
import '../providers/events_provider.dart';
import '../widgets/custom_general_button.dart';
import '../widgets/status_content.dart';

class EventItem extends StatefulWidget {

  final EventModel event;

  EventItem({
    this.event
  });

  @override
  _EventItemState createState() => _EventItemState();
}

class _EventItemState extends State<EventItem> {

  bool _isSaving = false;
  final _preferences = new Preferences();
  int _offset = 0;
  int _limit = 20;
  
  @override
  Widget build(BuildContext context) {
    final seeStatus = _preferences.userTypeId == 3 || _preferences.userId ==  widget.event.artist.userId;
    return GestureDetector(
      onTap: (){
        Navigator.of(context).pushNamed("event-detail", arguments: widget.event.id);
      },
      child: Container(
          padding: EdgeInsets.only(bottom: 5),
          margin: EdgeInsets.only(bottom: 30, left: 4, right: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                spreadRadius: 2.5,
                blurRadius: 3.5,
                offset: Offset(0, 2)
              )
            ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      child: FadeInImage(
                        image: widget.event.profileImage != null ? NetworkImage(widget.event.profileImage) : AssetImage("assets/images/no-image.png"),
                        imageErrorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                          return Text('No se pudo cargar la imagen');
                        },
                        placeholder: AssetImage("assets/images/loading.gif"),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: widget.event.categories.map((item) {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              margin: EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: greyColor.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(8)
                              ),
                              child: Text(item.name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                            );
                          }).toList(),
                        ),
                        if(widget.event.status == "1" && widget.event.draft != "1")
                          GestureDetector(
                            onTap: () async {
                              if(!_isSaving){
                                if(widget.event.scheduled == 2){
                                  setState(() => _isSaving = true );
                                  final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
                                  final resp = await eventsProvider.scheduleEvent(widget.event.id, _preferences.userId);
                                  await Future.wait([
                                    eventsProvider.getUserSheduledEvent(),
                                    eventsProvider.getAudienceEventsClose(),
                                    eventsProvider.getAudienceEventsNow(),
                                    eventsProvider.getAudienceEventsWeekend(),
                                    eventsProvider.getAudienceEventsAll()
                                  ]);
                                  setState(() => _isSaving = false );
                                  if (resp['success']) {
                                    showSuccessMessage(context, resp["message"]);
                                  }else{ 
                                    showErrorMessage(context, resp["message"]);
                                  }
                                }else{
                                  setState(() => _isSaving = true );
                                  final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
                                  final resp = await eventsProvider.unScheduleEvent(widget.event.id);
                                  await Future.wait([
                                    eventsProvider.getUserSheduledEvent(),
                                    eventsProvider.getAudienceEventsClose(),
                                    eventsProvider.getAudienceEventsNow(),
                                    eventsProvider.getAudienceEventsWeekend(),
                                    eventsProvider.getAudienceEventsAll()
                                  ]);
                                  setState(() => _isSaving = false );
                                  if (resp['success']) {
                                    showSuccessMessage(context, resp["message"]);
                                  }else{ 
                                    showErrorMessage(context, resp["message"]);
                                  }
                                }
                              }
                            },
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: _isSaving ? CircularProgressIndicator() : Icon(widget.event.scheduled == 2 ? Icons.favorite_border : Icons.favorite, color: widget.event.scheduled == 2 ? greyLightColor : primaryColor,),
                                ),
                                Positioned(
                                  right: 2,
                                  top: 2,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: whiteColor.withOpacity(0.6),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                    child: Text("${widget.event.scheduledCount}", style: title3.copyWith(color: greyLightColor),)
                                  )
                                ),
                              ],
                            ),
                          ),
                        if(widget.event.status != "1" && widget.event.draft != "1" && seeStatus)
                          StatusContent(status: widget.event.status,),
                        if(widget.event.draft == "1"  && seeStatus)
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.getTheme().colorScheme.secondary,
                              borderRadius: BorderRadius.circular(15)
                            ),
                            child: Text("Borrador", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),),
                          ),
                      ],
                    ),
                  )
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.event.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: greyLightColor),),
                    SizedBox(height: 5,),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: AppTheme.getTheme().colorScheme.primary, size: 25,),
                        SizedBox(width: 3,),
                        Text(widget.event.place.name, style: TextStyle(color: AppTheme.getTheme().disabledColor),),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Row(
                      children: [
                        Icon(Icons.event, color: AppTheme.getTheme().colorScheme.primary, size: 22,),
                        SizedBox(width: 3,),
                        Text("${formaterDate(widget.event.date)}", style: TextStyle(color: AppTheme.getTheme().disabledColor, fontWeight: FontWeight.bold),),
                        SizedBox(width: 8,),
                        Icon(Icons.access_time, color: AppTheme.getTheme().colorScheme.primary, size: 22,),
                        SizedBox(width: 3,),
                        Text("${formatTimeOfDay(widget.event.start)}", style: TextStyle(color: AppTheme.getTheme().disabledColor, fontWeight: FontWeight.bold),),
                        Text("-", style: TextStyle(color: AppTheme.getTheme().disabledColor),),
                        Text("${formatTimeOfDay(widget.event.end)}hs", style: TextStyle(color: AppTheme.getTheme().disabledColor, fontWeight: FontWeight.bold),),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5,),
              if(_preferences.userTypeId == 2  && _preferences.artistId == widget.event.artist.id) 
                _artistOptions(),
              if(_preferences.userTypeId == 3)
                _adminOptions(),
            ],
          ),
        ),
    );
  }

  Widget _adminOptions(){
    final now = new DateTime.now();
    final dateEnd = DateTime(widget.event.date.year, widget.event.date.month, widget.event.date.day, widget.event.end.hour, widget.event.end.minute);
    final eventsProvider = Provider.of<EventsProvider>(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Wrap( 
        children: [
          if(widget.event.status == "1" && widget.event.fullEnd.isAfter(now))
            CustomGeneralButton(
              onPressed: () async {
                setState(() => _isSaving = true);
                final resp = await eventsProvider.blockEvent(widget.event.id);
                setState(() => _isSaving = false);
                if (resp['success']) {
                  showSuccessMessage(context, resp["message"]);
                  await Future.wait([
                    eventsProvider.getAdminEventsAll(limit: _limit, offset: _offset, search: null),
                    eventsProvider.getAdminEventsPending(limit: _limit, offset: _offset, search: null),
                    eventsProvider.getAdminEventsComplained(limit: _limit, offset: _offset, search: null),
                  ]);
                }else{ 
                  showErrorMessage(context, resp["message"]);
                }
              },
              loading: _isSaving,
              width: 125,
              color: redColor,
              height: 35,
              text: "Bloquear",
              textStyle: text4.copyWith(color:whiteColor),
            ),
          if(widget.event.status == "3" && widget.event.fullEnd.isAfter(now))
            CustomGeneralButton(
              onPressed: () async {
                setState(() => _isSaving = true);
                final resp = await eventsProvider.unBlockEvent(widget.event.id);
                setState(() => _isSaving = false);
                if (resp['success']) {
                  showSuccessMessage(context, resp["message"]);
                  await Future.wait([
                    eventsProvider.getAdminEventsAll(limit: _limit, offset: _offset, search: null),
                    eventsProvider.getAdminEventsPending(limit: _limit, offset: _offset, search: null),
                    eventsProvider.getAdminEventsComplained(limit: _limit, offset: _offset, search: null),
                  ]);
                }else{ 
                  showErrorMessage(context, resp["message"]);
                }
              },
              loading: _isSaving,
              width: 125,
              color: Colors.yellow,
              height: 35,
              text: "Desbloquear",
              textStyle: text4,
            ),
          if(widget.event.status == "2")
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomGeneralButton(
                      onPressed: () async {
                        setState(() => _isSaving = true);
                        final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
                        final resp = await eventsProvider.rejectEvent(widget.event.id);
                        setState(() => _isSaving = false);
                        if (resp['success']) {
                          showSuccessMessage(context, resp["message"]);
                          await Future.wait([
                            eventsProvider.getAdminEventsAll(limit: _limit, offset: _offset, search: null),
                            eventsProvider.getAdminEventsPending(limit: _limit, offset: _offset, search: null),
                            eventsProvider.getAdminEventsComplained(limit: _limit, offset: _offset, search: null),
                          ]);
                        }else{ 
                          showErrorMessage(context, resp["message"]);
                        }
                      },
                      loading: _isSaving,
                      width: 120,
                      color: AppTheme.getTheme().colorScheme.secondary,
                      height: 35,
                      text: "Rechazar",
                    ),
                    CustomGeneralButton(
                      onPressed: () async {
                        setState(() => _isSaving = true);
                        final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
                        final resp = await eventsProvider.activateEvent(widget.event.id);
                        setState(() => _isSaving = false);
                        if (resp['success']) {
                          showSuccessMessage(context, resp["message"]);
                          await Future.wait([
                            eventsProvider.getAdminEventsAll(limit: _limit, offset: _offset, search: null),
                            eventsProvider.getAdminEventsPending(limit: _limit, offset: _offset, search: null),
                            eventsProvider.getAdminEventsComplained(limit: _limit, offset: _offset, search: null),
                          ]);
                        }else{ 
                          showErrorMessage(context, resp["message"]);
                        }
                      },
                      loading: _isSaving,
                      width: 120,
                      color: AppTheme.getTheme().colorScheme.primary,
                      height: 35,
                      text: "Aprobar",
                    )
                  ],
                ),
              ), 
        ],
      ),
    );
  }

  Widget _artistOptions(){
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        children: [
          if(widget.event.draft == "2")
            CustomGeneralButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return  AlertDialog(
                          contentPadding: EdgeInsets.all(10.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                          title: Container(
                            alignment: Alignment.center,
                            child: Text(
                              "¿Estás seguro en eliminar el evento ${widget.event.name} permanentemente?",
                              style: title2.copyWith(color:redColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          content: Container(
                            width: size.width*0.9,
                            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 15,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      CustomGeneralButton(
                                        text: "Si",
                                        loading: _isSaving,
                                        color: AppTheme.getTheme().colorScheme.surface,
                                        textStyle: title3,
                                        width: size.width*0.3,
                                        onPressed: _isSaving ? null : () async {
                                          setState(() => _isSaving = true);
                                          final artistsProvider = Provider.of<EventsProvider>(context, listen: false);
                                          final resp = await artistsProvider.deleteEvent(widget.event.id);
                                          setState(() => _isSaving = false);
                                          Navigator.pop(context);
                                          if (resp['success']) {
                                            showSuccessMessage(context, resp["message"]);
                                            await Future.wait([
                                              artistsProvider.getArtistEvents(),
                                            ]);
                                          }else{ 
                                            showErrorMessage(context, resp["message"]);
                                          }
                                        },
                                      ),
                                      CustomGeneralButton(
                                        text: "No",
                                        loading: _isSaving,
                                        color: AppTheme.getTheme().colorScheme.primary,
                                        textStyle: title3,
                                        width: size.width*0.3,
                                        onPressed: () { Navigator.pop(context); },
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    );
                  },
                );
              },
              marginVertical: 5.0,
              loading: _isSaving,
              width: 125,
              color: redColor,
              height: 35,
              text: "Eliminar",
            ),

          if(widget.event.draft == "1")
            CustomGeneralButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return  AlertDialog(
                          contentPadding: EdgeInsets.all(10.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                          title: Container(
                            alignment: Alignment.center,
                            child: Text(
                              "¿Estás seguro en descartar el evento ${widget.event.name} permanentemente?",
                              style: title2.copyWith(color:redColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          content: Container(
                            width: size.width*0.9,
                            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 15,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      CustomGeneralButton(
                                        text: "Si",
                                        loading: _isSaving,
                                        color: AppTheme.getTheme().colorScheme.surface,
                                        textStyle: title3,
                                        width: size.width*0.3,
                                        onPressed: _isSaving ? null : () async {
                                          setState(() => _isSaving = true);
                                          final artistsProvider = Provider.of<EventsProvider>(context, listen: false);
                                          final resp = await artistsProvider.deleteEvent(widget.event.id);
                                          setState(() => _isSaving = false);
                                          Navigator.pop(context);
                                          if (resp['success']) {
                                            showSuccessMessage(context, resp["message"]);
                                            await Future.wait([
                                              artistsProvider.getArtistEvents(),
                                            ]);
                                          }else{ 
                                            showErrorMessage(context, resp["message"]);
                                          }
                                        },
                                      ),
                                      CustomGeneralButton(
                                        text: "No",
                                        loading: _isSaving,
                                        color: AppTheme.getTheme().colorScheme.primary,
                                        textStyle: title3,
                                        width: size.width*0.3,
                                        onPressed: () { Navigator.pop(context); },
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    );
                  },
                );
              },
              marginVertical: 5.0,
              loading: _isSaving,
              width: 125,
              color: AppTheme.getTheme().colorScheme.secondary,
              height: 35,
              text: "Descartar",
            ),

          if(widget.event.draft == "1")
            CustomGeneralButton(
              onPressed: () async {
                setState(() => _isSaving = true);
                final artistsProvider = Provider.of<EventsProvider>(context, listen: false);
                final resp = await artistsProvider.publicateEvent(widget.event.id);
                setState(() => _isSaving = false);
                if (resp['success']) {
                  showSuccessMessage(context, resp["message"]);
                  await Future.wait([
                    artistsProvider.getArtistEvents(),
                  ]);
                }else{ 
                  showErrorMessage(context, resp["message"]);
                }
              },
              marginVertical: 5.0,
              loading: _isSaving,
              width: 125,
              color: AppTheme.getTheme().colorScheme.primary,
              height: 35,
              text: "Publicar",
            ),

          CustomGeneralButton(
            onPressed: () async {
              Navigator.of(context).pushNamed("artist-events-form", arguments: widget.event.id);
            },
            marginVertical: 5.0,
            loading: _isSaving,
            width: 125,
            color: greenColor,
            height: 35,
            text: "Editar",
            textStyle: title3.copyWith(color:whiteColor),
          ),
        ],
      ),
    );
  }
}