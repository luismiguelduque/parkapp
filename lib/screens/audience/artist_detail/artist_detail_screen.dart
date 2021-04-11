import 'package:flutter/material.dart';

import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/functions.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/constants.dart';
import '../../../models/artist_model.dart';
import '../../../providers/artists_provider.dart';
import '../../../widgets/custom_material_textfield.dart';
import '../../../widgets/custom_general_button.dart';
import '../../../widgets/custom_rating_widget.dart';

class ArtistDetailScreen extends StatefulWidget {
  @override
  _ArtistDetailScreenState createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {

  bool _isLoaded = false;
  bool _isLoading = false;
  bool _isSaving = false;
  PageController _pageController;
  String _report;
  String _description;
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
      final artistId = ModalRoute.of(context).settings.arguments;
      final artistsProvider = Provider.of<ArtistsProvider>(context, listen: false);
      bool internet = await check(context);
      if(internet){
        await Future.wait([
          artistsProvider.getArtistDetail(artistId),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? Center(
          child: CircularProgressIndicator(),
        ) : Container(
        child: Consumer<ArtistsProvider>(
          builder: (ctx, artistsProvider, _){
            return PageView(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              children: <Widget>[
                _topPage(context, artistsProvider.artistDetail),
                _bottomPage(context, artistsProvider.artistDetail)
              ],
            );
          },
        ),
      ),
    );
  }

  _topPage(BuildContext context, ArtistModel artist) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
        Container(
          width: double.infinity,
          height: double.infinity,
          child: FadeInImage(
            image: artist.coverImage != null ? NetworkImage(artist.coverImage) : AssetImage("assets/images/no-image.png"),
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
                      "Perfil del artista",
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
                        FlutterOpenWhatsapp.sendSingleMessage("", "¡Hey!, te invito a conocer a ${artist.stageName}.%0A%0ADescubre este y muchos otros artistas en la nueva app www.parkapp.com.ar");
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
                    Container(
                      alignment: Alignment.topCenter,
                      width: size.width*0.60,
                      child: Text("${artist.stageName}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),),
                    ),
                    SizedBox(height: 5,),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppTheme.getTheme().colorScheme.primary.withOpacity(0.2),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: artist.artisticGenre != null ? Text("${artist.artisticGenre.name}", style: TextStyle(fontSize: 20, color: AppTheme.getTheme().colorScheme.primary, fontWeight: FontWeight.bold),) : Text(""),
                    ),
                    SizedBox(height: 5,),
                    if(artist.city != null)
                      Row(
                        children: [
                          Icon(Icons.location_on, color: AppTheme.getTheme().colorScheme.primary, size: 25,),
                          SizedBox(width: 5,),
                          Container(
                            width: size.width*0.60,
                            child: Text("${artist.city.name}", style: TextStyle(color: Colors.white),)
                          ),
                          SizedBox(width: 10,),
                        ],
                      ),
                    SizedBox(height: 8,),
                    Row(
                      children: [
                        CustomRatingWidget(height: 40, ranking: artist.rating),
                      ],
                    ),
                    SizedBox(height: 10,),
                    artist.followed == 2 ? CustomGeneralButton(
                      height: 45,
                      width: size.width*0.7,
                      onPressed: ()=>_followArtist(artist.id),
                      loading: _isSaving,
                      color: AppTheme.getTheme().colorScheme.secondary,
                      text: "Seguir a este artista",
                    ): CustomGeneralButton(
                      height: 45,
                      width: size.width*0.7,
                      onPressed: ()=>_unFollowArtist(artist.id),
                      loading: _isSaving,
                      color: AppTheme.getTheme().colorScheme.secondary,
                      text: "Siguiendo",
                    ),
                    SizedBox(height: 10,),
                    artist.rated == 2 ? CustomGeneralButton(
                      height: 45,
                      width: size.width*0.7,
                      onPressed: (){
                        _rateArtist(artist.id);
                      },
                      color: AppTheme.getTheme().colorScheme.primary,
                      text: "Calificar a este artista",
                    ) : Container(),
                    SizedBox(height: 10,),
                    artist.complained == 2 ? FlatButton(
                      onPressed: (){
                        _reportEvent(artist.id);
                      },
                      child: Text("Denunciar artista", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: whiteColor),),
                    ) : Text("Artista denunciado", style: title3.copyWith(color: whiteColor),),
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
                  width: 250,
                  decoration: BoxDecoration(
                    color: greyColor.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(30)
                  ),
                  padding: EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Más información", style: TextStyle(fontSize: 18, color: whiteColor),),
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

  _followArtist(int id) async {
    bool internet = await check(context);
    if(internet){
      setState(() => _isSaving = true );
      final resp = await Provider.of<ArtistsProvider>(context, listen: false).followArtist(id);
      await Provider.of<ArtistsProvider>(context, listen: false).getArtistDetail(id);
      if (resp['success']) {
        showSuccessMessage(context, resp["message"]);
      }else{ 
        showErrorMessage(context, resp["message"]);
      }
      setState(() => _isSaving = false );
    }else{
      showErrorMessage(context, "No tienes conexion a internet");
    }
  }

  _unFollowArtist(int id) async {
    bool internet = await check(context);
    if(internet){
      setState(() => _isSaving = true );
      final resp = await Provider.of<ArtistsProvider>(context, listen: false).unFollowArtist(id);
      await Provider.of<ArtistsProvider>(context, listen: false).getArtistDetail(id);
      if (resp['success']) {
        showSuccessMessage(context, resp["message"]);
      }else{ 
        showErrorMessage(context, resp["message"]);
      }
      setState(() => _isSaving = false );
    }else{
      showErrorMessage(context, "No tienes conexion a internet");
    }
  }

  _bottomPage(BuildContext context, ArtistModel artist) {
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
                      width: 240,
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
              Text("¿Quiénes somos?", style: TextStyle(color: AppTheme.getTheme().colorScheme.primary, fontSize: 25, fontWeight: FontWeight.bold),),
              SizedBox(height: 10.0 ),
              Text("Perfil del artista:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.getTheme().colorScheme.secondary),),
              SizedBox(height: 5,),
              Text("${artist.description}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: greyLightColor),),
              SizedBox(height: 10,),
              Divider(),
              SizedBox(height: 10,),
              Text("¿Qué hacemos?", style: TextStyle(color: AppTheme.getTheme().colorScheme.primary, fontSize: 25, fontWeight: FontWeight.bold),),
              SizedBox(height: 10.0 ),
              Text("Disciplinas:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.getTheme().colorScheme.secondary),),
              SizedBox(height: 5,),
              artist.artisticGenre != null ? Text("${artist.artisticGenre.name}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: greyLightColor),) : Text(""),
              SizedBox(height: 10,),
              Text("Imágenes:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.getTheme().colorScheme.secondary),),
              SizedBox(height: 5,),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 100,
                  height: 110,
                  child: FadeInImage(
                    image: artist.profileImage != null ? NetworkImage(artist.profileImage) : AssetImage("assets/images/no-image.png"),
                    placeholder: AssetImage("assets/images/loading.gif"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              if(artist.urlVideo != null)
                _videoSection(artist),
              SizedBox(height: 50,),
            ],
          ),
        )
      ),
    );
  }

  _videoSection(ArtistModel artist){
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
            child: Text("${artist.urlVideo}", style: text4),
            onTap: () async {
              String url = "${artist.urlVideo}";
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            },
          ),
        ),
      ],
    );
  }

  _rateArtist(int id) {
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
                  "Califica el artista",
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
                                final ordersProvider = Provider.of<ArtistsProvider>(context, listen: false);
                                Map<String, dynamic> response = await ordersProvider.rateArtist(id, _description, _rating);
                                await Provider.of<ArtistsProvider>(context, listen: false).getArtistDetail(id);
                                setState((){
                                  _isSaving = false;
                                  _rating = 0;
                                });
                                Navigator.pop(context);
                                if (response['success']) {
                                  showSuccessMessage(context, "Calificación del artista guardada exitosamente");
                                } else {
                                  showErrorMessage(context, "Ha habido un problema al procesar su peticion. Por favor, intente nuevamente.");
                                }
                              } else {
                                showErrorMessage(context, "Dale una calificación al artista");
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
                  "¿Está seguro querer denunciar este artista?",
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
                                  final ordersProvider = Provider.of<ArtistsProvider>(context, listen: false);
                                  Map<String, dynamic> response = await ordersProvider.reportArtist(id, _report);
                                  await Provider.of<ArtistsProvider>(context, listen: false).getArtistDetail(id);
                                  setState((){
                                    _isSaving = false;
                                  }); 
                                  Navigator.pop(context);
                                  if (response['success']) {
                                    showSuccessMessage(context, "Artista denunciado exitosamente");
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