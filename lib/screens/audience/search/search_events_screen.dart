import 'package:flutter/material.dart';

import 'package:parkapp/models/artist_model.dart';
import 'package:parkapp/models/neighborhood_model.dart';
import 'package:parkapp/providers/artists_provider.dart';
import 'package:parkapp/utils/functions.dart';
import 'package:parkapp/widgets/custom_rating_widget.dart';
import 'package:parkapp/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_theme.dart';
import '../../../utils/constants.dart';
import '../../../models/event_category_model.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/places_provider.dart';
import '../../../providers/events_provider.dart';
import '../../../widgets/custom_general_button.dart';
import '../../../widgets/empty_list.dart';
import '../../../widgets/event_item.dart';

class SearchEventScreen extends StatefulWidget {
  @override
  _SearchEventScreenState createState() => _SearchEventScreenState();
}

class _SearchEventScreenState extends State<SearchEventScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isLoaded = false;
  bool _isLoading = false;
  bool _isLoadingPagination = false;
  bool _isSaving=false;
  int _offset = 0;
  int _limit = 20;
  String _search;
  DateTime _fromDate;
  DateTime _toDate;
  TimeOfDay _fromTime;
  TimeOfDay _toTime;
  String _neighborhoodsName;
  int _neighborhoods;
  int _artist;
  String _artistName;
  double _rating;
  List<int> _categories = [];
  double _distance = 10;
  bool _searchDistance = false;
  
  @override
  void didChangeDependencies() async {
    if(!_isLoaded){
      _isLoading = true;
      final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
      final categoriesProvider = Provider.of<CategoriesProvider>(context, listen: false);
      final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
      final artistProvider = Provider.of<ArtistsProvider>(context, listen: false);
      await Future.wait([
        artistProvider.getArtists(search: null, limit: 150, offset: 0),
        placesProvider.getNeighborhoods(),
        categoriesProvider.getEventCategory(),
        eventsProvider.getAudienceEventsAll(
          offset: _offset,
          limit: _limit,
          search: _search,
          fromDate:  _fromDate,
          toDate: _toDate,
          fromTime:  _fromTime,
          toTime: _toTime,
          neighborhoods: _neighborhoods,
          artists: _artist,
          rating: _rating,
          categories: _categories.length > 0 ? _categories : null,
          distance: _searchDistance ? _distance : null,
        ),
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
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: Drawer(
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 3,),
                      Text("Filtrar", style: title1.copyWith(color: greyLightColor),),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Text("Fecha", style: text4.copyWith(color: greyVeryLightColor),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _iconFieldItem(Icons.calendar_today, "${_fromDate == null ? 'Desde' : formaterDate(_fromDate)}", _showDatePickerFrom),
                      SizedBox(width: 10,),
                      Text("-"),
                      SizedBox(width: 10,),
                      _iconFieldItem(Icons.calendar_today, "${_toDate == null ? 'Hasta' : formaterDate(_toDate)}", _showDatePickerTo),
                    ],
                  ),
                  Divider(),
                  Text("Hora", style: text4.copyWith(color: greyVeryLightColor),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _iconFieldItem(Icons.timer, "${_fromTime == null ? 'Inicio' : formatTimeOfDay(_fromTime)}", _showTimePickerStart),
                      SizedBox(width: 10,),
                      Text("-"),
                      SizedBox(width: 10,),
                      _iconFieldItem(Icons.timer, "${_fromTime == null ? 'Fin' : formatTimeOfDay(_toTime)}", _showTimePickerEnd),
                    ],
                  ),
                  Divider(),
                  _iconFieldItem(Icons.location_on, "${_neighborhoods == null ? 'Barrio' : _neighborhoodsName}", _showDialogPlaces),
                  Divider(),
                  _iconFieldItem(Icons.person, "${_artist == null ? 'Artista' : _artistName}", _showDialogArtists),
                  Divider(),
                  _iconFieldItem(Icons.star, _rating == null ? 'Calificación' : "$_rating Estrellas" , _showDialogRating),
                  Divider(),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Categoría del evento", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                      ],
                    ),
                  ),
                  SizedBox(height: 5,),
                  Consumer<CategoriesProvider>(
                    builder: (ctx, categoriesProvider, _){
                      return Container(
                        child: Wrap(
                          direction: Axis.horizontal,
                          children: categoriesProvider.categories.map((item){
                            return _categoryItem(context, item);
                          }).toList(),
                        ),
                      );
                    },
                  ),
                  Divider(),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Switch(
                              activeColor: secondaryColor,
                              onChanged: (value){
                                setState(() {
                                  _searchDistance = value;
                                });
                              },
                              value: _searchDistance,
                            ),
                            Text("Filtrar por distancia", style: text4.copyWith(color:secondaryColor),),
                          ],
                        ),
                        Text("Distancia a donde estas ahora (km)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                      ],
                    ),
                  ),
                  Slider(
                    activeColor: secondaryColor,
                    inactiveColor: secondaryColor.withOpacity(0.4),
                    value: _distance,
                    min: 10,
                    max: 100,
                    divisions: 9,
                    label: _distance.round().toString(),
                    onChanged: _searchDistance ? (double value) {
                      setState(() {
                        _distance = value;
                      });
                    } : null,
                  ),
                  Divider(),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomGeneralButton(
                        onPressed: () async {
                          setState(() => _isLoading = true );
                          _getItems();
                          setState(() => _isLoading = false );
                        },
                        loading: _isSaving,
                        color: AppTheme.getTheme().colorScheme.primary,
                        text: "Aplicar",
                        width: 200,
                        height: 55,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading ? Center(
          child: CircularProgressIndicator(),
        ) : SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: (){
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.arrow_back, size: 28, color: greyLightColor,)
                      ),
                      Text("Buscar", style: title1.copyWith(color: greyLightColor),),
                    ],
                  ),
                  IconButton(
                    onPressed: (){
                      _scaffoldKey.currentState.openEndDrawer();
                    },
                    icon: Icon(Icons.filter_list, size: 30, color: primaryColor,),
                  ),
                ],
              ),
              SizedBox(height: 15,), 
              CustomTextfield(
                onChanged: (value){
                  _search = value;
                  setState(() => _isLoading = true );
                  _getItems();
                  setState(() => _isLoading = false );
                },
                label: "Buscar",
              ),
              SizedBox(height: 20,),
              Expanded(
                child: _eventsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _eventsList(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Consumer<EventsProvider>(
        builder: (ctx, eventsProvider, _){
          if(eventsProvider.audienceEventsAll.length > 0)
            return RefreshIndicator(
              onRefresh: () async {
                _getItems();
              },
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo){
                  if (!_isLoadingPagination && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                    if(eventsProvider.audienceAllEventstotalItems > _limit){
                      paginacion(context);
                    }
                    return true;
                  }
                  return false;
                },
                child: Scrollbar(
                  child: ListView.builder(
                    itemCount: eventsProvider.audienceEventsAll.length,
                    itemBuilder: (context, index) {
                      if(index+1 == eventsProvider.audienceEventsAll.length){
                        return Column(
                          children: [
                            EventItem(event: eventsProvider.audienceEventsAll[index],),
                            SizedBox(height: 150,)
                          ],
                        );
                      }else{
                        return EventItem(event: eventsProvider.audienceEventsAll[index],);
                      }
                    }
                  )
                ),
              ),
            );
          return EmptyList(color: greyLightColor,);
        },
      ),
    );
  }

  Widget _iconFieldItem(IconData icon, String text, Function(BuildContext context) onPress){
    return GestureDetector(
      onTap: () => onPress(context),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 28, color: secondaryColor),
            SizedBox(width: 12,),
            Text(text, style: TextStyle(fontSize: 16),),
          ],
        ),
      ),
    );
  }

  _showDatePickerFrom(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2018),
      lastDate: DateTime(2022)
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked;
      });
    }
  }

  _showDatePickerTo(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2018),
      lastDate: DateTime(2022)
    );
    if (picked != null) {
      setState(() {
        _toDate = picked;
      });
    }
  }

  Future _showTimePickerStart(BuildContext context, ) async{
    final TimeOfDay selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: AppTheme.getTheme(),
            child: child
          ),
        );
      },
    );
    setState(() {
      _fromTime = selectedTime;
    });
  }

  Future _showTimePickerEnd(BuildContext context, ) async{
    final TimeOfDay selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: AppTheme.getTheme(),
            child: child
          ),
        );
      },
    );
    setState(() {
      _toTime = selectedTime;
    });
  }

  void _showDialogPlaces(BuildContext context) {
    final size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialig) {
            return  AlertDialog(
              contentPadding: EdgeInsets.all(10.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
              title: Container(
                alignment: Alignment.center,
                child: Text(
                  "Selecciona el lugar",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              content: Consumer<PlacesProvider>(
                builder: (ctx, placesProvider, _){
                  return Container(
                    width: size.width*0.9,
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    child: ListView.builder(
                      itemCount: placesProvider.neighborhoods.length,
                      itemBuilder: (context, index){
                        final NeighborhoodModel item = placesProvider.neighborhoods[index];
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: (){
                                setStateDialig((){
                                  _neighborhoods = item.id;
                                  _neighborhoodsName = item.name;
                                });
                                setState(() { });
                                Navigator.of(context).pop();
                              },
                              child: ListTile(
                                leading: Icon(Icons.location_on, size: 30, color: primaryColor,),
                                title: Text("${item.name}"),
                                trailing: IconButton(
                                  onPressed: (){},
                                  icon: Icon(Icons.arrow_forward),
                                ),
                              ),
                            ),
                            Divider(),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }
        );
      },
    );
  }
  
  void _showDialogArtists(BuildContext context) {
    final size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialig) {
            return  AlertDialog(
              contentPadding: EdgeInsets.all(10.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
              title: Container(
                alignment: Alignment.center,
                child: Text(
                  "Seleciona el artista",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              content: Consumer<ArtistsProvider>(
                builder: (ctx, artistsProvider, _){
                  return Container(
                    width: size.width*0.9,
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    child: ListView.builder(
                      itemCount: artistsProvider.artists.length,
                      itemBuilder: (context, index){
                        final ArtistModel item = artistsProvider.artists[index];
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: (){
                                setStateDialig((){
                                  _artist = item.id;
                                  _artistName = item.stageName;
                                });
                                setState(() { });
                                Navigator.of(context).pop();
                              },
                              child: ListTile(
                                leading: Icon(Icons.person, size: 30, color: primaryColor,),
                                title: Text("${item.stageName}"),
                                subtitle: Text("${item.artisticGenre.name}"),
                                trailing: IconButton(
                                  onPressed: (){},
                                  icon: Icon(Icons.arrow_forward),
                                ),
                              ),
                            ),
                            Divider(),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }
        );
      },
    );
  }

  void _showDialogRating(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialig) {
            return  AlertDialog(
              contentPadding: EdgeInsets.all(10.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
              title: Container(
                alignment: Alignment.center,
                child: Text(
                  "Seleciona la calificación del evento",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              content: Column(
                children: [
                  Divider(height: 2, color: greyVeryLightColor,),
                  _ratingEvent(4.0),
                  Divider(height: 2, color: greyVeryLightColor,),
                  _ratingEvent(3.0),
                  Divider(height: 2, color: greyVeryLightColor,),
                  _ratingEvent(2.0),
                  Divider(height: 2, color: greyVeryLightColor,),
                  _ratingEvent(1.0),
                  Divider(height: 2, color: greyVeryLightColor,),
                ],
              )
            );
          }
        );
      },
    );
  }

  GestureDetector _ratingEvent(double rating) {
    return GestureDetector(
      onTap: (){
        setState(() {
          _rating = rating;
        });
        Navigator.of(context).pop();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomRatingWidget(ranking: rating, height: 70.0,),
          SizedBox(width: 5.0,),
          Text("o más"),
        ],
      ),
    );
  }

  Widget _categoryItem(BuildContext context, EventCategoryModel category){
    final active = _categories.contains(category.id);
    return Container(
      width: 135,
      child: Row(
        children: [
          Checkbox(
            onChanged: (value){
              setState(() {
                if(value){
                  _categories.add(category.id);
                }else{
                  _categories.removeWhere((element) => element == category.id);
                }
              });
            },
            activeColor: AppTheme.getTheme().colorScheme.primary,
            value: active,
          ),
          Flexible(
            child: new Container(
              padding: new EdgeInsets.only(right: 13.0),
              child: new Text(
                "${category.name}",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, color: greyColor)
              ),
            ),
          ),
        ],
      ),
    );
  }

  void paginacion(BuildContext context) async {
    _isLoadingPagination = true;
    _offset+=20;
    _limit+=20;
    _getItems();
    _isLoadingPagination = false;
  }

  void _getItems() async {
    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
    await Future.wait([
      eventsProvider.getAudienceEventsAll(
        offset: _offset,
        limit: _limit,
        search: _search,
        fromDate:  _fromDate,
        toDate: _toDate,
        fromTime:  _fromTime,
        toTime: _toTime,
        neighborhoods: _neighborhoods,
        artists: _artist,
        rating: _rating,
        categories: _categories.length > 0 ? _categories : null,
        distance: _searchDistance ? _distance : null,
      ),
    ]);
  }
}