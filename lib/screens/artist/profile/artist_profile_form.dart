import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:parkapp/utils/constants.dart';
import 'package:parkapp/utils/preferences.dart';
import 'package:parkapp/widgets/custom_error_message.dart';
import 'package:parkapp/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_theme.dart';
import '../../../utils/functions.dart';
import '../../../models/artist_model.dart';
import '../../../models/artistic_genres_model.dart';
import '../../../providers/artists_provider.dart';
import '../../../providers/genres_provider.dart';
import '../../../widgets/custom_dropdown.dart';
import '../../../widgets/custom_general_button.dart';

class ArtistProfileForm extends StatefulWidget {
  @override
  _ArtistProfileFormState createState() => _ArtistProfileFormState();
}

class _ArtistProfileFormState extends State<ArtistProfileForm> {
  final picker = ImagePicker();
  final _preferences = new Preferences();
  ArtistModel _tempArtist = new ArtistModel(
    artisticGenre: new ArtisticGenreModel()
  );
  File _profileImage;
  File _coverImage;
  bool _isSaving=false;
  bool showFilter = false;
  bool _isLoaded = false;
  bool _isLoading = true;
  bool _showErrors = false;
  Map<String, String> _errors = {
    'profileImage': 'Este campo es requerido',
    'coverImage': 'Este campo es requerido',
    'termAndConditions': 'Debe aceptar los términos y condiciones',
  };

  @override
  void didChangeDependencies() async {
    if (!_isLoaded) {
      _isLoading = true;
      final artistsProvider = Provider.of<ArtistsProvider>(context, listen: false);
      bool internet = await check(context);
      if(internet){
        await Future.wait([
          artistsProvider.getArtistDetail(_preferences.artistId),
          Provider.of<GenresProvider>(context, listen: false).getArtisticGenres(),
        ]);
      }else{
        showErrorMessage(context, "No tienes conexion a internet");
      }
      setState(() {
        _tempArtist = artistsProvider.artistDetail;
        _errors = {
          'categories': '',
          'date': '',
          'time': '',
          'place': '',
          'profileImage': 'Este campo es requerido',
          'coverImage': 'Este campo es requerido',
        };
      });
      setState(() {
        _isLoading = false;
      });
      _isLoaded = true;
    }
    super.didChangeDependencies();
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: _isLoading ? Center(
          child: CircularProgressIndicator(),
        ) : SafeArea(
        child: Stack(
          children: [
            Container(
              child: ListView(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, size: 28,),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        "Editar perfil del artista", 
                        style: TextStyle(
                          color: AppTheme.getTheme().colorScheme.secondary, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10,),
                        CustomTextfield(
                          keyboardType: TextInputType.number,
                          height: 55,
                          label:"DNI",
                          maxLength: 8,
                          numbersOnly: true,
                          verticalMargin: 5,
                          value: _tempArtist.dni,
                          onChanged: (value){
                            _tempArtist.dni = value;
                          },
                        ),
                        Divider(),
                        Consumer<GenresProvider>(
                          builder: (ctx, genresProvider, _){
                            return CustomDropdown(
                              label: "Género artístico",
                              height: 55,
                              value: _tempArtist.artisticGenre != null ? _tempArtist.artisticGenre.id.toString() : null,
                              items: genresProvider.artisticGenres.map((item) {
                                return {'value': item.id.toString(), 'label': item.name};
                              }).toList(),
                              onChanged: (value){
                                if (_tempArtist.artisticGenre == null ) {
                                  _tempArtist.artisticGenre = new ArtisticGenreModel();
                                }
                                _tempArtist.artisticGenre.id = int.parse(value);
                              },
                            );
                          }
                        ),
                        Divider(),
                        CustomTextfield(
                          height: 55,
                          label: "Nombre de perfil público",
                          value: _tempArtist.stageName,
                          verticalMargin: 5,
                          maxLength: 75,
                          onChanged: (value){
                            _tempArtist.stageName = value;
                          },
                        ),
                        Divider(),
                        CustomTextfield(
                          maxLines: 3,
                          height: 100,
                          label: "Descripción",
                          value: _tempArtist.description,
                          verticalMargin: 5,
                          maxLength: 160,
                          onChanged: (value){
                            _tempArtist.description = value;
                          },
                        ),
                        Divider(),

                        if(_tempArtist.profileImage == '') 
                          _iconFieldItem(Icons.attach_file, _profileImage == null ? "Adjuntar foto de perfil" : "Cambiar foto de perfil", _openGalleryProfile)
                        else 
                          Column(
                            children: [
                              Text("Foto de perfil", style: TextStyle(fontSize: 18),),
                              SizedBox(height: 15.0,),
                              _imageSlide(context, _tempArtist.profileImage, true)
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


                        if(_tempArtist.coverImage == '') 
                          _iconFieldItem(Icons.attach_file, _coverImage == null ? "Adjuntar foto de portada" : "Cambiar foto de portada", _openGalleryCover)
                        else 
                          Column(
                            children: [
                              Text("Foto de portada", style: TextStyle(fontSize: 18),),
                              SizedBox(height: 15.0,),
                              _imageSlide(context, _tempArtist.coverImage, false)
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

                        /*
                        _iconFieldItem(Icons.attach_file, _profileImage == null ? "Adjuntar foto de perfil" : "Cambiar foto de perfil", _openGalleryProfile),
                        if(_profileImage != null) 
                          Container(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25.0),
                              child: FadeInImage(
                                width: 150,
                                placeholder: AssetImage("assets/images/loading.gif"),
                                image: _profileImage != null 
                                ? FileImage(_profileImage) 
                                : (
                                  _tempArtist.profileImage != null 
                                  ? Image.network(_tempArtist.profileImage) 
                                  : AssetImage("assets/images/no-image.png")
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        Divider(),
                        _iconFieldItem(Icons.attach_file, _coverImage == null ? "Adjuntar foto de portada" : "Cambiar foto de portada", _openGalleryCover),
                          if(_coverImage != null) 
                          Container(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25.0),
                              child: FadeInImage(
                                width: 150,
                                placeholder: AssetImage("assets/images/loading.gif"),
                                image: _coverImage != null 
                                  ? FileImage(_coverImage) 
                                  : (
                                    _tempArtist.coverImage != null 
                                    ? Image.network(_tempArtist.coverImage) 
                                    : AssetImage("assets/images/no-image.png")
                                  ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          */
                        Divider(),
                        CustomTextfield(
                          height: 55,
                          label: "URL video",
                          verticalMargin: 8,
                          maxLength: 75,
                          value: _tempArtist.urlVideo != null && _tempArtist.urlVideo != 'null' ? _tempArtist.urlVideo : '',
                          onChanged: (value){
                            _tempArtist.urlVideo = value;
                          },
                        ),
                        SizedBox(height: 150,),
                      ],
                    ),
                  )
                ]
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: size.width,
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.all(10),
                child: CustomGeneralButton(
                  onPressed: ()=> _save(),
                  loading: _isSaving,
                  color: AppTheme.getTheme().colorScheme.primary,
                  text: "Editar perfil",
                  width: size.width*0.7,
                  height: 50,
                ),
              ),
            ),
          ]
        ),
      )
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
                      _tempArtist.profileImage = "";
                    }else{
                      _tempArtist.coverImage = "";
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

  Widget _iconFieldItem(IconData icon, String text, Function(BuildContext context) onPress){
    return GestureDetector(
      onTap: () => onPress(context),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
    }catch(error){
      print(error);
    }
  }

  void _save() async {
    bool internet = await check(context);
    if(internet){
      setState(() {
        _isSaving = true;
      });
      final resp = await Provider.of<ArtistsProvider>(context, listen: false).updateArtist(_tempArtist, _profileImage, _coverImage, _preferences.artistId);
      if (resp['success']) {
        showSuccessMessage(context, resp["message"]);
        await Future.delayed(const Duration(seconds: 3), (){});
        Navigator.of(context).pushNamed("artist-profile-options");
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