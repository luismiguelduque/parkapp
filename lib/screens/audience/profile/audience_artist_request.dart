import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:parkapp/utils/constants.dart';
import 'package:parkapp/widgets/custom_error_message.dart';
import 'dart:io';

import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/functions.dart';
import '../../../utils/app_theme.dart';
import '../../../models/artistic_genres_model.dart';
import '../../../models/artist_model.dart';
import '../../../providers/artists_provider.dart';
import '../../../providers/genres_provider.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/custom_dropdown.dart';
import '../../../widgets/custom_general_button.dart';

class AudienceArtistRequest extends StatefulWidget {
  @override
  _AudienceArtistRequestState createState() => _AudienceArtistRequestState();
}

class _AudienceArtistRequestState extends State<AudienceArtistRequest> {

  final GlobalKey<FormState> _formKey = GlobalKey();
  final picker = ImagePicker();
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
  bool _termAndConditions = false;
  Map<String, String> _errors = {
    'profileImage': 'Este campo es requerido',
    'coverImage': 'Este campo es requerido',
    'termAndConditions': 'Debe aceptar los términos y condiciones',
  };

  @override
  void didChangeDependencies() async {
    if (!_isLoaded) {
      _isLoading = true;
      await Provider.of<GenresProvider>(context, listen: false).getArtisticGenres();
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
            Form(
              key: _formKey,
              child: Container(
                child: ListView(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, size: 28,),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Text("Registro de artista", style: TextStyle(color: AppTheme.getTheme().colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 25),),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        children: [
                          SizedBox(height: 10,),
                          CustomTextfield(
                            keyboardType: TextInputType.number,
                            height: 55,
                            label:"DNI",
                            verticalMargin: 5,
                            maxLength: 8,
                            numbersOnly: true,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Este campo es requerido';
                              }
                              return null;
                            },
                            onChanged: (value){
                              _tempArtist.dni = value;
                            },
                          ),
                          Divider(),
                          Consumer<GenresProvider>(
                            builder: (ctx, genresProvider, _){
                              return CustomDropdown(
                                label: "Género artístico",
                                height: (_showErrors == true && _tempArtist.artisticGenre.id != null) ? 80 : 55,
                                items: genresProvider.artisticGenres.map((item) {
                                  return {'value': item.id.toString(), 'label': item.name};
                                }).toList(),
                                validator: (value) => value == null ? 'Este campo es requerido' : null,
                                onChanged: (value){
                                  _tempArtist.artisticGenre.id = int.parse(value);
                                },
                              );
                            }
                          ),
                          Divider(),
                          CustomTextfield(
                            height: 55,
                            label: "Nombre de perfil público",
                            verticalMargin: 5,
                            maxLength: 75,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Este campo es requerido';
                              }
                              return null;
                            },
                            onChanged: (value){
                              _tempArtist.stageName = value;
                            },
                          ),
                          Divider(),
                          CustomTextfield(
                            maxLines: 3,
                            height: 100,
                            label: "Descripción",
                            verticalMargin: 5,
                            maxLength: 160,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Este campo es requerido';
                              }
                              return null;
                            },
                            onChanged: (value){
                              _tempArtist.description = value;
                            },
                          ),
                          Divider(),
                          _iconFieldItem(Icons.attach_file, _profileImage == null ? "Adjuntar foto de perfil" : "Cambiar foto de perfil", _openGalleryProfile),
                          
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
                          Divider(),
                          _iconFieldItem(Icons.attach_file, _coverImage == null ? "Adjuntar foto de portada" : "Cambiar foto de portada", _openGalleryCover),
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
                            height: 55,
                            label: "URL video (Opcional)",
                            verticalMargin: 8,
                            maxLength: 75,
                            onChanged: (value){
                              _tempArtist.urlVideo = value;
                            },
                          ),
                          Row(
                            children: [
                              Checkbox(
                                checkColor: AppTheme.primaryColors,
                                activeColor: AppTheme.secondaryColors,
                                value: _termAndConditions,
                                onChanged: (value){ 
                                  _termAndConditions = value; 
                                  if(!value) {
                                    setState(() {
                                      _errors['termAndConditions'] = 'Debe aceptar los términos y condiciones';
                                    });
                                  } else {
                                    setState(() {
                                      _errors['termAndConditions'] = '';
                                    });
                                  }
                                },
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Aceptar ',
                                      style: title4.copyWith(color: AppTheme.getTheme().disabledColor),
                                    ),
                                    TextSpan(
                                      text: 'Términos y condiciones',
                                      style: title4.copyWith(color: secondaryColor),
                                      recognizer: TapGestureRecognizer()..onTap = () async {
                                        const url = 'http://ec2-54-184-105-143.us-west-2.compute.amazonaws.com/terms';
                                        if (await canLaunch(url)) {
                                          await launch(url);
                                        } else {
                                          throw 'Could not launch $url';
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          _showErrors == true ? CustomErrorMessage(message: _errors['termAndConditions']) : Container(),
                          SizedBox(height: 150,),
                        ],
                      ),
                    )
                  ]
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: size.width,
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.all(10),
                child: CustomGeneralButton(
                  onPressed: ()=> _save(context),
                  loading: _isSaving,
                  color: AppTheme.getTheme().colorScheme.primary,
                  text: "Confirmar",
                  width: size.width*0.7,
                  height: 50,
                ),
              ),
            ),
          ]
        )
      )
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
    final pickedFile = await picker.getImage(
      source: ImageSource.gallery,
      imageQuality: 95,
      maxWidth: 700,
    );
    setState(() {
      _profileImage = File(pickedFile.path);
    });
    if(_profileImage != null) {
      _errors['profileImage'] = '';
    }
  }

  void _openGalleryCover(BuildContext context) async {
    final pickedFile = await picker.getImage(
      source: ImageSource.gallery,
      imageQuality: 95,
      maxWidth: 700,
    );
    setState(() {
      _coverImage =  File(pickedFile.path);
    });
    
    if(_coverImage != null) {
      _errors['coverImage'] = '';
    }
  }

  void _save(BuildContext context) async {
    if (!_formKey.currentState.validate() || _profileImage == null || _coverImage == null || !_termAndConditions) {
      setState(() {_showErrors = true;});
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isSaving = true;
    });
    final resp = await Provider.of<ArtistsProvider>(context, listen: false).store(_tempArtist, _profileImage, _coverImage);
    if (resp['success']) {
      showSuccessMessage(context, resp["message"]);
      await Future.delayed(const Duration(seconds: 3), (){});
      Navigator.of(context).pushNamed("audience-profile");
    }else{ 
      showErrorMessage(context, resp["message"]);
    }
    setState(() {
      _isSaving = false;
    });
  }
}