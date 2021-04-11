import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parkapp/utils/constants.dart';
import 'package:parkapp/utils/preferences.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_theme.dart';
import '../../../utils/functions.dart';
import '../../../models/event_model.dart';
import '../../../providers/events_provider.dart';
import '../../../widgets/custom_map_widget.dart';
import '../../../widgets/custom_rating_widget.dart';

class AudienceEventsCloseTab extends StatefulWidget {
  @override
  _AudienceEventsCloseTabState createState() => _AudienceEventsCloseTabState();
}

class _AudienceEventsCloseTabState extends State<AudienceEventsCloseTab> {

  BitmapDescriptor pinLocationIcon;
  bool _isLoaded = false;
  bool _isSaving = false;
  final _preferences = new Preferences();

   @override
  void didChangeDependencies() async {
    if(!_isLoaded){
      setCustomMapPin();
      _isLoaded = true;
    }
    super.didChangeDependencies();
  }

  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(
        devicePixelRatio: 2.5,
      ), 
      'assets/images/simple-icon.png'
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<EventsProvider>(
      builder: (ctx, eventsProvider, _){
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15,),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Eventos cerca de ti", style: TextStyle(color: AppTheme.getTheme().colorScheme.secondary, fontSize: 18, fontWeight: FontWeight.w500),),
                    /*
                    Row(
                      children: [
                        Text("Filtrar", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                        IconButton(icon: Icon(Icons.sort, size: 30, color: AppTheme.getTheme().colorScheme.primary),
                        onPressed: (){
                          Navigator.of(context).pushNamed("audience-filter");
                        },
                      )
                      ],
                    ),
                    */
                  ],
                ),
              ),
              SizedBox(height: 5,),
              Expanded(
                child: Stack(
                  children: [
                    CustomMapWidget(
                      allowMarker: false,
                      onCLick: (val){},
                      markers: eventsProvider.audienceEventsClose.map((event) {
                        return Marker(
                          markerId: MarkerId('${event.id}'),
                          position: LatLng(double.parse(event.place.lat), double.parse(event.place.long)),
                          icon: pinLocationIcon,
                          infoWindow: InfoWindow(
                            title: '${event.name}'
                          )
                        );
                      }).toList(),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        height: 150,
                        width: size.width,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: eventsProvider.audienceEventsClose.length,
                          itemBuilder: (context, index){
                            return _carouselItem(context, eventsProvider.audienceEventsClose[index]);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        );
      },
    );
  }

  Widget _carouselItem(BuildContext context, EventModel event){
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: (){
        Navigator.of(context).pushNamed("event-detail", arguments: event.id);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
        width: size.width*0.90,
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  child:Container(
                    width: size.width*0.3,
                    height: 120,
                    child:  FadeInImage(
                      image: event.profileImage != null ? NetworkImage(event.profileImage) : AssetImage("assets/images/no-image.png"),
                      placeholder: AssetImage("assets/images/loading.gif"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 7,
                  left: 7,
                  child: GestureDetector(
                    onTap: () async {
                      if(!_isSaving){
                        if(event.scheduled == 2){
                          setState(() => _isSaving = true );
                          final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
                          final resp = await eventsProvider.scheduleEvent(event.id, _preferences.userId);
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
                          final resp = await eventsProvider.unScheduleEvent(event.id);
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
                          child: _isSaving ? CircularProgressIndicator() : Icon(event.scheduled == 2 ? Icons.favorite_border : Icons.favorite, color: event.scheduled == 2 ? greyLightColor : primaryColor,),
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
                            child: Text("${event.scheduledCount}", style: title3.copyWith(color: greyLightColor),)
                          )
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: size.width*0.55,
                              child: Text(
                                "${event.name}", 
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,),
                                overflow: TextOverflow.ellipsis,
                                ),
                            ),
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: AppTheme.getTheme().colorScheme.primary,),
                        SizedBox(width: 5,),
                        Flexible(
                          child: Text(
                            "${event.place.name}  -  ${event.distance}", 
                            style: TextStyle(color: AppTheme.getTheme().disabledColor), 
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: AppTheme.getTheme().colorScheme.primary, size: 20,),
                        SizedBox(width: 5,),
                        Text("${formaterDate(event.date)} ${formatTimeOfDay(event.start)}", style: TextStyle(color: AppTheme.getTheme().disabledColor),),
                      ],
                    ),
                    CustomRatingWidget(ranking: event.rating, height: 40,),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}