import 'package:flutter/material.dart';

import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parkapp/widgets/images_slide.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/event_model.dart';
import '../../../providers/events_provider.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/constants.dart';
import '../../../utils/functions.dart';
import '../../../utils/preferences.dart';
import '../../../widgets/custom_material_textfield.dart';
import '../../../widgets/custom_general_button.dart';
import '../../../widgets/custom_map_widget.dart';
import '../../../widgets/custom_rating_widget.dart';

class EventDetailScreen extends StatefulWidget {
  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {

  final _preferences = new Preferences();
  bool _isLoaded = false;
  bool _isLoading = false;
  bool _isSaving = false;
  PageController _pageController;
  BitmapDescriptor pinLocationIcon;
  String _description;
  String _report;
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

   @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeDependencies() async {
    if(!_isLoaded){
      _isLoading = true;
      final eventId = ModalRoute.of(context).settings.arguments;
      final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
      setCustomMapPin();
      bool internet = await check(context);
      if(internet){
        await Future.wait([
          eventsProvider.getEventDetail(eventId),
          eventsProvider.getUserSheduledEvent(),
        ]);
      }else{
        showErrorMessage(context, "No tienes conexion a internet");
      }
      setState(() {
        _isLoading = false;
        _isLoaded = true;
      });
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
    return Scaffold(
      body: _isLoading ? Center(
          child: CircularProgressIndicator(),
        ) : Container(
        child: Consumer<EventsProvider>(
          builder: (ctx, eventsProvider, _){
            final bool isSheduled = eventsProvider.scheduledEvents.where((element) => element.id == eventsProvider.eventDetail.id).length>0;
            return PageView(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              children: <Widget>[
                _topPage(context, eventsProvider.eventDetail, isSheduled),
                _bottomPage(context, eventsProvider.eventDetail)
              ],
            );
          },
        ),
      ),
    );
  }

  _topPage(BuildContext context, EventModel event, bool isSheduled) {
    final size = MediaQuery.of(context).size;
    final now = new DateTime.now();
    final dateEnd = DateTime(event.date.year, event.date.month, event.date.day, event.end.hour, event.end.minute);

    return Stack(
      children: <Widget>[
        Container(
          width: double.infinity,
          height: double.infinity,
          child: FadeInImage(
            image: event.coverImage != null ? NetworkImage(event.coverImage) : AssetImage("assets/images/no-image.png"),
            placeholder: AssetImage("assets/images/loading.gif"),
            fit: BoxFit.cover,
          ),
        ),
        SafeArea(
          child: Column(
            children: <Widget>[
              SizedBox(height: 10.0 ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: (){
                        Navigator.of(context).pop();
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.arrow_back, color: Colors.grey,),
                      ),
                    ),
                    Text(
                      "Detalle del evento",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white, shadows: <Shadow>[
                        Shadow(
                          offset: Offset(0, 0),
                          blurRadius: 5.0,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ],),
                    ),
                    GestureDetector(
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.share, color: Colors.grey,),
                      ),
                      onTap: () {
                        FlutterOpenWhatsapp.sendSingleMessage("", "¡Hey!, te invito a ver ${event.name} en ${event.place.name}.%0A%0ADescubre este y muchos otros eventos en la nueva app www.parkapp.com.ar");
                      },
                    ),
                  ],
                ),
              ),
              Expanded( child: Container() ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: greyColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(30)
                ),
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Column(
                  children: [
                    Text("${event.name}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),),
                    SizedBox(height: 5,),
                    Wrap(
                      children: event.categories.map((item) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppTheme.getTheme().colorScheme.primary.withOpacity(0.2),
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          child: Text("${item.name}", style: TextStyle(color: AppTheme.getTheme().colorScheme.primary, fontWeight: FontWeight.bold),),
                        );
                      }).toList()
                    ),
                    SizedBox(height: 5,),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: AppTheme.getTheme().colorScheme.primary, size: 25,),
                        SizedBox(width: 5,),
                        Text("${event.place.name}", style: TextStyle(color: Colors.white),),
                        SizedBox(width: 10,),
                      ],
                    ),
                    SizedBox(height: 8,),
                    Row(
                      children: [
                        Icon(Icons.event, color: AppTheme.getTheme().colorScheme.primary, size: 24,),
                        SizedBox(width: 5,),
                        Text("${formaterDate(event.date)}", style: TextStyle(color: Colors.white),),
                        SizedBox(width: 10,),
                        Text("${formatTimeOfDay(event.start)} - ${formatTimeOfDay(event.end)}", style: TextStyle(color: Colors.white),),
                      ],
                    ),
                    Row(
                      children: [
                        CustomRatingWidget(height: 40, ranking: event.rating),
                      ],
                    ),
                    (_preferences.userId != event.artist.userId) ? CustomGeneralButton(
                      height: 45,
                      width: size.width*0.7,
                      onPressed: () async {
                        bool internet = await check(context);
                        if(internet){
                          if(!_isSaving){
                            if(!isSheduled){
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
                        }else{
                          showErrorMessage(context, "No tienes conexion a internet");
                        }
                      },
                      color: isSheduled ? AppTheme.getTheme().disabledColor : AppTheme.getTheme().colorScheme.secondary,
                      text: isSheduled ? "Agendado" : "Agendar",
                      loading: _isSaving,
                    ): Container(),
                    SizedBox(height: 10,),
                    (event.rated == 2 && event.fullEnd.isBefore(now) && _preferences.userTypeId != 3 && _preferences.userId != event.artist.userId) ? CustomGeneralButton(
                      height: 45,
                      width: size.width*0.7,
                      onPressed: (){
                        _rateEvent(event.id);
                      },
                      color: AppTheme.getTheme().colorScheme.primary,
                      text: "¿Cómo estuvo el evento?",
                    ): Container(),
                    SizedBox(height: 10,),
                    event.fullEnd.isBefore(now) ? (
                      event.complained == 2 ? FlatButton(
                        onPressed: (){
                          _reportEvent(event.id);
                        },
                        child: Text("Denunciar evento", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: whiteColor),),
                      ) 
                      : Text("Evento denunciado", style: title3.copyWith(color: whiteColor),)
                    ) : Container(),
                    SizedBox(height: 5,),
                  ],
                ),
              ),
              SizedBox(height: 25,),
              GestureDetector(
                onTap: (){
                  _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.linear);
                },
                child: Container(
                  width: 240,
                  decoration: BoxDecoration(
                    color: greyColor.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(30)
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Mas información", style: TextStyle(fontSize: 18, color: whiteColor),),
                      SizedBox(width: 8,),
                      Icon(Icons.keyboard_arrow_down, size: 30, color: whiteColor,),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15,),
            ],
          ),
        ),
      ],
    );
  }

  _bottomPage(BuildContext context, EventModel event) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.0 ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: (){
                      _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.linear);
                    },
                    child: Container(
                      width: 250,
                      decoration: BoxDecoration(
                        color: greyColor.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(30)
                      ),
                      padding: EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Menos información", style: TextStyle(fontSize: 18, color: whiteColor),),
                          SizedBox(width: 8,),
                          Icon(Icons.keyboard_arrow_up, size: 30, color: whiteColor,),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0 ),
              Text("¿Qué? ¿Cuándo?", style: TextStyle(color: AppTheme.getTheme().colorScheme.primary, fontSize: 25, fontWeight: FontWeight.bold),),
              SizedBox(height: 20,),
              Text("Tipo de evento: ", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
              Wrap(
                children: event.categories.map((item) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppTheme.getTheme().colorScheme.primary.withOpacity(0.2),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                    child: Text("${item.name}", style: TextStyle(color: AppTheme.getTheme().colorScheme.primary, fontSize: 16, fontWeight: FontWeight.bold),),
                  );
                }).toList()
              ),
              SizedBox(height: 10.0 ),
              Container(
                width: size.width * 0.80,
                child: Text("${event.name}", style: TextStyle(color: AppTheme.getTheme().colorScheme.secondary, fontSize: 26, fontWeight: FontWeight.bold),)
              ),
              SizedBox(height: 8,),
              Row(
                children: [
                  Icon(Icons.location_on, color: AppTheme.getTheme().colorScheme.primary, size: 24,),
                  SizedBox(width: 5,),
                  Container(
                    width: size.width * 0.80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${event.distance}", style: TextStyle(color: blackColor, fontSize: 16),),
                        Text("${event.place.name}", style: TextStyle(color: blackColor, fontSize: 16, ), overflow: TextOverflow.visible,),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4,),
              Row(
                children: [ 
                  Icon(Icons.timer, color: AppTheme.getTheme().colorScheme.primary, size: 24,),
                  SizedBox(width: 5,),
                  Text("${formaterDate(event.date)}", style: TextStyle(color: blackColor, fontSize: 16),),
                  SizedBox(width: 10,),
                  Text("${formatTimeOfDay(event.start)} - ${formatTimeOfDay(event.end)}", style: TextStyle(color: blackColor, fontSize: 16),),
                ],
              ),
              SizedBox(height: 4,),
              Row(
                children: [
                  Icon(Icons.event, color: AppTheme.getTheme().colorScheme.primary, size: 24,),
                  SizedBox(width: 5,),
                  Text("Duración:", style: TextStyle(color: blackColor, fontSize: 16),),
                  SizedBox(width: 5,),
                  Text("${event.duration}", style: TextStyle(color: blackColor, fontSize: 16),),
                ],
              ),
              SizedBox(height: 8,),
              Divider(),
              SizedBox(height: 5,),
              Text("Detalle de evento:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.getTheme().colorScheme.secondary),),
              SizedBox(height: 5,),
              Text("${event.description}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: greyLightColor),),
              SizedBox(height: 5,),
              if(event.images.length > 0)
                Column(
                  children: [
                    Text("Imágenes:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.getTheme().colorScheme.secondary),),
                    SizedBox(height: 5,),
                    ImagesSlide(images: event.images, isDeleted: false,),
                    SizedBox(height: 10.0 ),
                  ],
                ),
              if(event.urlVideo != null)
                _videoSection(event),
              Divider(),
              SizedBox(height: 10.0 ),
              Text("¿Dónde?", style: TextStyle(color: AppTheme.getTheme().colorScheme.primary, fontSize: 25, fontWeight: FontWeight.bold),),
              SizedBox(height: 20,),
              Text("${event.place.name}", style: TextStyle(color: AppTheme.getTheme().colorScheme.secondary,fontWeight: FontWeight.bold, fontSize: 20)),
              SizedBox(height: 5,),
              Text("${event.place.address}", style: TextStyle(color: greyLightColor, fontSize: 18)),
              SizedBox(height: 10,),
              Container(
                height: 200,
                child: CustomMapWidget(
                  allowMarker: false,
                  useLocation: false,
                  onCLick: (val){},
                  markers: [
                    Marker(
                      markerId: MarkerId('${event.id}'),
                      position: LatLng(double.parse(event.place.lat), double.parse(event.place.long)),
                      icon: pinLocationIcon,
                      infoWindow: InfoWindow(
                        title: '${event.name}'
                      )
                    ),
                  ]
                ),
              ),
              Divider(),
              SizedBox(height: 10,),
              _artistInfo(event),
              SizedBox(height: 50,),
            ],
          ),
        )
      ),
    );
  }

  _videoSection(EventModel event){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10,),
        Text("Video:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.getTheme().colorScheme.secondary),),
        SizedBox(height: 5,),
        Container(
          width: MediaQuery.of(context).size.width*0.9,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: GestureDetector(
            child: Text("${event.urlVideo}", style: text4),
            onTap: () async {
              String url = "${event.urlVideo}";
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            },
          ),
        ),
        SizedBox(height: 5,),
      ],
    );
  }

  Widget _artistInfo(EventModel event){
    final size = MediaQuery.of(context).size;
    return Row(
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundImage: NetworkImage('${event.artist.profileImage}'),
            ),
            
          ],
        ),
        SizedBox(width: 20,), 
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Artista/s", style: TextStyle(fontSize: 18)), 
            Container(width: size.width*0.50, child: Text("${event.artist.stageName}", maxLines: 2, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.getTheme().colorScheme.secondary),)),
            CustomGeneralButton(
              text: " Ver perfil ",
              onPressed: (){
                Navigator.of(context).pushNamed('artist-detail', arguments: event.artist.id);
              },
              color: AppTheme.getTheme().colorScheme.secondary,
            ),
          ],
        ),
      ],
    );
  }

  _rateEvent(int id) {
    final size = MediaQuery.of(context).size;
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
                  "Califica el evento",
                  style: title2,
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
                      RatingBar(
                        initialRating: 0,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        ratingWidget: RatingWidget(
                          full: Icon(Icons.star, color: Colors.yellow,),
                          half: Icon(Icons.star_half, color: Colors.yellow,),
                          empty: Icon(Icons.star_border, color: Colors.yellow,),
                        ),
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        onRatingUpdate: (rating) {
                          _rating = rating;
                        },
                      ),
                      SizedBox(height: 15,),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: CustomMaterialTextField(
                          maxLines: 5,
                          onChanged: (value){
                            _description = value;
                          },
                        ),
                      ),
                      SizedBox(height: 20,),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: CustomGeneralButton(
                          text: "Confirmar",
                          loading: _isSaving,
                          color: AppTheme.getTheme().colorScheme.primary,
                          textStyle: title3,
                          width: size.width,
                          onPressed: _isSaving ? null : () async {
                            bool internet = await check(context);
                            if(internet){
                              if (_rating > 0) {
                                setState((){
                                  _isSaving = true;
                                });
                                final ordersProvider = Provider.of<EventsProvider>(context, listen: false);
                                Map<String, dynamic> response = await ordersProvider.rateEvent(id, _description, _rating);
                                setState((){
                                  _isSaving = false;
                                  _rating = 0;
                                });

                                Navigator.pop(context);
                                if (response['success']) {
                                  showSuccessMessage(context, "Calificación del evento guardada exitosamente");
                                } else {
                                  showErrorMessage(context, "Ha habido un problema al procesar su peticion. Por favor, intente nuevamente.");
                                }
                              } else {
                                showErrorMessage(context, "Dale una calificación al evento");
                              }
                            }else{
                              showErrorMessage(context, "No tienes conexion a internet");
                            }
                          },
                        ),
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
  }

  _reportEvent(int id) {
    final size = MediaQuery.of(context).size;
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
                  "¿Está seguro querer denunciar este evento?",
                  style: title2.copyWith(color: redColor),
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
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: CustomMaterialTextField(
                          label: "Indica la razón",
                          maxLines: 5,
                          onChanged: (value){
                            _report = value;
                          },
                        ),
                      ),
                      SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CustomGeneralButton(
                            text: "Confirmar",
                            loading: _isSaving,
                            color: AppTheme.getTheme().colorScheme.surface,
                            textStyle: title3,
                            width: size.width*0.3,
                            onPressed: _isSaving ? null : () async {
                              bool internet = await check(context);
                              if(internet){
                                if (_report.toString().length > 0) {
                                  setState((){
                                    _isSaving = true;
                                  });
                                  final ordersProvider = Provider.of<EventsProvider>(context, listen: false);
                                  Map<String, dynamic> response = await ordersProvider.reportEvent(id, _report);
                                  setState((){
                                    _isSaving = false;
                                  }); 
                                  Navigator.pop(context);
                                  if (response['success']) {
                                    showSuccessMessage(context, "Evento denunciado exitosamente");
                                  } else {
                                    showErrorMessage(context, "Ha habido un problema al procesar su peticion. Por favor, intente nuevamente.");
                                  }
                                } else {
                                  showErrorMessage(context, "Indica la razón");
                                }
                              }else{
                                showErrorMessage(context, "No tienes conexion a internet");
                              }
                            },
                          ),
                          CustomGeneralButton(
                            text: "Cancelar",
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
  }
}