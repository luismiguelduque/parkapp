import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:parkapp/widgets/custom_error_message.dart';
import 'package:parkapp/widgets/images_slide.dart';
import 'package:provider/provider.dart';

import '../../../utils/constants.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/functions.dart';
import '../../../models/event_category_model.dart';
import '../../../models/event_model.dart';
import '../../../models/place_model.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/events_provider.dart';
import '../../../providers/places_provider.dart';
import '../../../widgets/images_slide_files.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/custom_general_button.dart';

class ArtistEventFormScreen extends StatefulWidget {
  @override
  _ArtistEventFormScreenState createState() => _ArtistEventFormScreenState();
}

class _ArtistEventFormScreenState extends State<ArtistEventFormScreen> {
  
  final GlobalKey<FormState> _formKey = GlobalKey();
  EventModel _tempEvent = new EventModel(
    place: new PlaceModel(),
    categories: [],
  );
  final picker = ImagePicker();
  int _eventId;
  File _profileImage;
  File _coverImage;
  bool _isSaving = false;
  List<int> _categories = [];
  bool _isLoaded = false;
  bool _isLoading = false;
  bool _showErrors = false;
  String _profileImageUrl = '';
  String _coverImageUrl = '';
  List<File> _images = [];
  Map<String, String> _errors = {
    'categories': 'Este campo es requerido',
    'date': 'Este campo es requerido',
    'time': 'Este campo es requerido',
    'place': 'Este campo es requerido',
    'profileImage': 'Este campo es requerido',
    'coverImage': 'Este campo es requerido',
  };

  @override
  void didChangeDependencies() async {
    if(!_isLoaded){
      _isLoading = true;
      final categoriesProvider = Provider.of<CategoriesProvider>(context, listen: false);
      final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
      _eventId = ModalRoute.of(context).settings.arguments;
      bool internet = await check(context);
      if(internet){
        await Future.wait([
          categoriesProvider.getEventCategory(),
          if (_eventId != null) eventsProvider.getEventDetail(_eventId),
        ]);
      }else{
        showErrorMessage(context, "No tienes conexion a internet");
      }
      if (_eventId != null) {
        setState(() {
          _profileImageUrl = eventsProvider.eventDetail.profileImage;
          _coverImageUrl = eventsProvider.eventDetail.coverImage;
          _errors = {
            'categories': '',
            'date': '',
            'time': '',
            'place': '',
            'profileImage': 'Este campo es requerido',
            'coverImage': 'Este campo es requerido',
          };
        });
        eventsProvider.eventDetail.categories.forEach((element) {_categories.add(element.id);});
      }
      setState(() {
        _isLoading = false;
        _isLoaded = true;
      });
    }
    super.didChangeDependencies();
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 28, color: blackColor,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_eventId != null ? "Editar evento" : "Crear evento", style: TextStyle(color: AppTheme.getTheme().colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 25),),
      ),
      body: _isLoading ? Center(
          child: CircularProgressIndicator(),
        ) : SafeArea(
        child: Form(
          key: _formKey,
          child: Stack(
            children: [
              Consumer<EventsProvider>(
                builder: (ctx, eventsProvider, _){
                  _tempEvent = eventsProvider.eventDetail;
                  return Container(
                    child: ListView(
                      children: [
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 15,),
                                Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Categoría del evento", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                      _showErrors == true ? CustomErrorMessage(message: _errors['categories']) : Container(),
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
                                _iconFieldItem(Icons.calendar_today, "${_tempEvent.date == null ? 'Fecha' : formaterDate(_tempEvent.date)}", _showDatePicker),
                                _showErrors == true ? CustomErrorMessage(message: _errors['date']) : Container(),
                                Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    _iconFieldItem(Icons.timer, "${ _tempEvent.start == null ? 'Hora inicio' : formatTimeOfDay(_tempEvent.start)}", _showTimePickerStart),
                                    SizedBox(width: 10,),
                                    Text("--"),
                                    SizedBox(width: 10,),
                                    _iconFieldItem(Icons.timer, "${ _tempEvent.end == null ? 'Hora fin' : formatTimeOfDay(_tempEvent.end)}", _showTimePickerEnd),
                                  ],
                                ),
                                _showErrors == true ? CustomErrorMessage(message: _errors['time']) : Container(),
                                Divider(),
                                CustomTextfield(
                                  label: "Nombre del evento",
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Este campo es requerido';
                                    }
                                    return null;
                                  },
                                  maxLength: 100,
                                  height: 55,
                                  verticalMargin: 8,
                                  value: _tempEvent.name,
                                  onChanged: (value){
                                    _tempEvent.name = value;
                                  },
                                ),
                                Divider(),
                                CustomTextfield(
                                  value: eventsProvider.eventDetail.description ?? '',
                                  maxLines: 3,
                                  height: 100,
                                  label: "Descripción",
                                  maxLength: 250,
                                  verticalMargin: 8,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Este campo es requerido';
                                    }
                                    return null;
                                  },
                                  onChanged: (value){
                                    _tempEvent.description = value;
                                  },
                                ),
                                Divider(),
                                _iconFieldItem(Icons.location_on, "${ _tempEvent.place.id == null ? 'Lugar' : _tempEvent.place.name}", _showDialogPlaces),
                                _tempEvent.place.restricted == "1" ? Text("Este lugar esta restringido, por lo tanto el evento será revisado antes de publicarse", style: text4.copyWith(color: secondaryColor),) : Container(),
                                _showErrors == true ? CustomErrorMessage(message: _errors['place']) : Container(),
                                Divider(),
                                CustomTextfield(
                                  value: eventsProvider.eventDetail.placeComments ?? '',
                                  maxLines: 3,
                                  height: 100,
                                  label: "Comentarios sobre el lugar (Opcional)",
                                  verticalMargin: 8,
                                  maxLength: 250,
                                  onChanged: (value){
                                    _tempEvent.placeComments = value;
                                  },
                                ),
                                Divider(),
                                if(_eventId == null || _profileImageUrl == '') 
                                  _iconFieldItem(Icons.attach_file, _profileImage == null ? "Adjuntar foto de perfil" : "Cambiar foto de perfil", _openGalleryProfile)
                                else 
                                  Column(
                                    children: [
                                      Text("Foto de perfil", style: TextStyle(fontSize: 18),),
                                      SizedBox(height: 15.0,),
                                      _imageSlide(context, _profileImageUrl, true)
                                    ],
                                  ),
                                  
                                if(_profileImage != null) 
                                  Container(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(25.0),
                                      child: FadeInImage(
                                        width: 150,
                                        placeholder: AssetImage("assets/images/loading.gif"),
                                        image: _profileImage != null ? FileImage(_profileImage) : AssetImage("assets/images/no-image.png"),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                _showErrors == true ? CustomErrorMessage(message: _errors['profileImage']) : Container(),


                                if(_eventId == null || _coverImageUrl == '') 
                                  _iconFieldItem(Icons.attach_file, _coverImage == null ? "Adjuntar foto de portada" : "Cambiar foto de portada", _openGalleryCover)
                                else 
                                  Column(
                                    children: [
                                      Text("Foto de portada", style: TextStyle(fontSize: 18),),
                                      SizedBox(height: 15.0,),
                                      _imageSlide(context, _coverImageUrl, false)
                                    ],
                                  ),
                                  
                                if(_coverImage != null) 
                                  Container(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(25.0),
                                      child: FadeInImage(
                                        width: 150,
                                        placeholder: AssetImage("assets/images/loading.gif"),
                                        image: _coverImage != null ? FileImage(_coverImage) : AssetImage("assets/images/no-image.png"),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                _showErrors == true ? CustomErrorMessage(message: _errors['coverImage']) : Container(),
                                Divider(),
                                CustomTextfield(
                                  value: eventsProvider.eventDetail.urlVideo ?? '',
                                  height: 55,
                                  label: "URL video (Opcional)",
                                  verticalMargin: 8,
                                  maxLength: 150,
                                  onChanged: (value){
                                    _tempEvent.urlVideo = value;
                                  },
                                ),
                                Divider(),
                                _iconFieldItem(Icons.attach_file, "Imágenes adicionales ", _openGalleryImages),
                                Row(
                                  children: [
                                    SizedBox(width: 50.0,),
                                    Text('(Opcional)', style: text4,),
                                  ],
                                ),
                                _images.length > 0
                                  ? ImagesSlideFiles(
                                      images: _images,
                                      onDeleteFunction: (i){
                                        setState(() {
                                          _images.removeAt(i);
                                        });
                                      },
                                    )
                                  : Container(),
                                  if (_eventId != null && eventsProvider.eventDetail.images.length > 0)
                                    Column(
                                      children: [
                                        Divider(),
                                        SizedBox(height: 10.0,),
                                        Container(
                                          width: size.width,
                                          padding: EdgeInsets.symmetric(horizontal: 45.0),
                                          child: Text('Imágenes cargadas', style: TextStyle(fontSize: 18),)
                                        ),
                                        SizedBox(height: 20.0,),
                                        ImagesSlide(images: eventsProvider.eventDetail.images, isDeleted: true, deleteImage: 'event', id: eventsProvider.eventDetail.id),
                                      ],
                                    ),
                                  

                                SizedBox(height: 150),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                }
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: size.width,
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomGeneralButton(
                        onPressed: (){
                          _tempEvent.draft = "1";
                          _save();
                        },
                        loading: _isSaving,
                        color: AppTheme.getTheme().colorScheme.secondary,
                        text: "Borrador",
                        width: size.width*0.43,
                        height: 50,
                      ),
                      CustomGeneralButton(
                        onPressed: (){
                          _tempEvent.draft = "2";
                          _save();
                        },
                        loading: _isSaving,
                        color: AppTheme.getTheme().colorScheme.primary,
                        text: "Publicar",
                        width: size.width*0.43,
                        height: 50,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryItem(BuildContext context, EventCategoryModel category){
    final size = MediaQuery.of(context).size;
    final active = _categories.contains(category.id);
    return Container(
      width: size.width*0.4618,
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
                if(_categories.length == 0) {
                  _errors['categories'] = 'Este campo es requerido';
                } else {
                  _errors['categories'] = '';
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
                overflow: TextOverflow.visible,
                style: TextStyle(fontSize: 15, color: greyColor)
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDialog(BuildContext context, String image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return  Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(image),
                    fit: BoxFit.contain
                  )
                ),
              ),
            );
          }
        );
      },
    );
  }

  Container _imageSlide(BuildContext context, String image, bool isProfile) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        color: greyVeryLightColor,
        borderRadius: BorderRadius.circular(15.0),
      ),
      margin: EdgeInsets.only(right: 10.0),
      padding: EdgeInsets.all(1.0),
      child: Container(
        width: width * 0.3,
        height: width * 0.3,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: FadeInImage(
                width: width * 0.3,
                placeholder: AssetImage("assets/images/loading.gif"),
                image: image != null ? NetworkImage(image) : AssetImage("assets/images/no-image.png"),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: greyColor.withOpacity(0.2),
                child: IconButton(
                  icon: Icon(Icons.search,color: blackColor, size: 28),
                  onPressed: () {
                    _showDialog(context, image);
                  },
                ),
              ),
            ),
            Positioned(
              top: -12,
              right: -12,
              child: IconButton(
                icon: Icon(Icons.cancel, size: 30, color: redColor.withOpacity(0.7),),
                onPressed: () {
                  setState((){
                    if(isProfile){
                      _profileImageUrl = "";
                    }else{
                      _coverImageUrl = "";
                    }
                  });
                }, 
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDialogDelete(BuildContext context) {
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
                  "¿Quieres borrar esta imagen?",
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
                      SizedBox(height: 15,),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomGeneralButton(
                              text: "Confirmar",
                              loading: _isSaving,
                              color: AppTheme.getTheme().colorScheme.surface,
                              textStyle: title3,
                              width: size.width*0.3,
                              onPressed: () {
                                Navigator.pop(context);
                                setState((){
                                  _profileImageUrl = '';
                                });
                              },
                            ),
                            CustomGeneralButton(
                              text: "Cancelar",
                              loading: _isSaving,
                              color: AppTheme.getTheme().colorScheme.primary,
                              textStyle: title3,
                              width: size.width*0.3,
                              onPressed: (){
                                Navigator.pop(context);
                              },
                            ),
                          ],
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

  Widget _iconFieldItem(IconData icon, String text, Function(BuildContext context) onPress){
    return GestureDetector(
      onTap: () => onPress(context),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 32, color: AppTheme.getTheme().colorScheme.secondary,),
            SizedBox(width: 15,),
            Text(text, style: TextStyle(fontSize: 18),),
          ],
        ),
      ),
    );
  }

  void _showDialogPlaces(BuildContext context) {
    final size = MediaQuery.of(context).size;
    String search = '';
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
                child: Column(
                  children: [
                    Text(
                      "Selecciona el lugar",
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 25.0,),
                    CustomTextfield(
                      label: 'Buscar Lugar',
                      onChanged: (value){
                        setStateDialig(() {
                          search = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              content: Consumer<PlacesProvider>(
                builder: (ctx, placesProvider, _){
                  List<PlaceModel> placesList = placesProvider.places;
                  placesList = placesList.where((element) => element.name.toLowerCase().contains(search.toLowerCase()) ).toList();
                  return Container(
                    width: size.width*0.9,
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    child: ListView.builder(
                      itemCount: placesList.length,
                      itemBuilder: (context, index){
                        final PlaceModel item = placesList[index];
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: (){
                                setStateDialig((){
                                  _tempEvent.place = item;
                                });
                                setState(() { });
                                if(_tempEvent.place != null){
                                  _errors['place'] = '';
                                }
                                Navigator.of(context).pop();
                              },
                              child: ListTile(
                                leading: Icon(Icons.location_on, size: 30, color: _tempEvent.place.id != item.id ? greyLightColor : AppTheme.getTheme().colorScheme.primary,),
                                title: Text("${item.name}"),
                                subtitle: Text("${item.address}"),
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
      _tempEvent.start = selectedTime;
    });
    if(_tempEvent.end != null){
      _errors['time'] = '';
    }
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
      _tempEvent.end = selectedTime;
    });
    if(_tempEvent.start != null){
      _errors['time'] = '';
    }
  }

  _showDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2018),
      lastDate: DateTime(2022)
    );
    if (picked != null) {
      setState(() {
        _tempEvent.date = picked;
      });
    }
    if(_tempEvent.date != null){
      _errors['date'] = '';
    }
  }

  void _openGalleryProfile(BuildContext context) async {
    try{
      final pickedFile = await picker.getImage(
        source: ImageSource.gallery,
        imageQuality: 95,
        maxWidth: 700,
      );
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      if(_profileImage != null){
        _errors['profileImage'] = '';
      }
    }catch(error){
      print(error);
    }
  }

  void _openGalleryCover(BuildContext context) async {
    try{
      final pickedFile = await picker.getImage(
        source: ImageSource.gallery,
        imageQuality: 95,
        maxWidth: 700,
      );
      setState(() {
        _coverImage =  File(pickedFile.path);
      });
      if(_coverImage != null){
        _errors['coverImage'] = '';
      }
    }catch(error){
      print(error);
    }
  }

  void _openGalleryImages(BuildContext context) async {
    try{
      final pickedFile = await picker.getImage(
        source: ImageSource.gallery,
        imageQuality: 95,
        maxWidth: 700,
      );
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }catch(error){
      print(error);
    }
  }

  void _save() async {
    bool internet = await check(context);
    if(internet){
      if (!_formKey.currentState.validate() || _tempEvent.date == null || _tempEvent.start == null || _tempEvent.end == null || (_eventId == null && _profileImage == null) || (_eventId != null && (_profileImageUrl == '' && _profileImage == null)) || _categories.length == 0) {
        setState(() {_showErrors = true;});
        return;
      }
      _formKey.currentState.save();
      setState(() {
        _isSaving = true;
      });
      Map<String, dynamic> resp;
      if (_eventId != null) {
        resp = await Provider.of<EventsProvider>(context, listen: false).updateEvent(_tempEvent, _profileImage, _coverImage, _categories, _eventId, _images);
      } else {
        resp = await Provider.of<EventsProvider>(context, listen: false).store(_tempEvent, _profileImage, _coverImage, _categories, _images);
      }
      if (resp['success']) {
        showSuccessMessage(context, resp["message"]);
        await Future.delayed(const Duration(seconds: 3), (){});
        Navigator.of(context).pushNamed("artist-events");
      }else{ 
        showErrorMessage(context, resp["message"]);
      }
      setState(() {
        _isSaving = false;
      });
    }else{
      showErrorMessage(context, "No tienes conexion a internet");
    }
  }
}