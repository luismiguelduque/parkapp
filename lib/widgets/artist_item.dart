//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parkapp/models/conversation_model.dart';
import 'package:parkapp/providers/chat_provider.dart';
import 'package:parkapp/utils/preferences.dart';
import 'package:parkapp/widgets/status_content.dart';

import 'package:provider/provider.dart';

import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/functions.dart';
import '../models/artist_model.dart';
import '../providers/artists_provider.dart';
import '../widgets/custom_general_button.dart';

class ArtistItem extends StatefulWidget {

  final ArtistModel artist;

  ArtistItem({
    this.artist
  });

  @override
  _ArtistItemState createState() => _ArtistItemState();
}

class _ArtistItemState extends State<ArtistItem> {

  bool isSaving = false;
  final _preferences = new Preferences();
  int _offset = 0;
  int _limit = 20;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.of(context).pushNamed("artist-detail", arguments: widget.artist.id);
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
                      image: widget.artist.profileImage != null 
                      ? NetworkImage(widget.artist.profileImage,) : AssetImage("assets/images/no-image.png"),
                      imageErrorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                        return Text('No se pudo cargar la imagen');
                      },
                      placeholder: AssetImage("assets/images/loading.gif"),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                if(_preferences.userTypeId == 3)
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if(widget.artist.complaintsCount > 0)
                          StatusContent(status: '4'),
                        if(widget.artist.status == "4")
                          StatusContent(status: '5'),
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
                  Text(widget.artist.stageName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: greyLightColor),),
                  SizedBox(height: 5,),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: AppTheme.getTheme().colorScheme.primary, size: 25,),
                      SizedBox(width: 5,),
                      Text("${widget.artist.city.name}", style: TextStyle(color: AppTheme.getTheme().disabledColor),),
                    ],
                  ),
                  SizedBox(height: 5,),
                  if(_preferences.userTypeId == 3)
                    Row(
                      children: [
                        Icon(Icons.event, color: AppTheme.getTheme().colorScheme.primary, size: 24,),
                        SizedBox(width: 5,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Solicitud ingresada ", style: TextStyle(color: AppTheme.getTheme().disabledColor),),
                            Text("${formaterDateTime(widget.artist.requestDate)} hs", style: TextStyle(color: AppTheme.getTheme().disabledColor, fontWeight: FontWeight.bold),),
                          ],
                        )
                      ],
                    ),
                ],
              ),
            ),
            SizedBox(height: 5,),
            if(_preferences.userTypeId == 3) 
              _adminOptions(),
            SizedBox(height: 5,),
          ],
        ),
      ),
  );
}

Widget _adminOptions(){
  final artistsProvider = Provider.of<ArtistsProvider>(context);
  return Consumer<ChatProvider>(
    builder: (ctx, chatProvider, _){
      return Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Wrap( 
          children: [
            if(widget.artist.status == "4")
              CustomGeneralButton(
                onPressed: () async { 
                  setState(() => isSaving = true);
                  final ConversationModel conversation = chatProvider.adminAllConversations.firstWhere((element) => element.user.id == widget.artist.userId);
                  final String _messageText = "¡Gracias por registrarte como artista! Para que el perfil de artista sea activado en tu celular es necesario cerrar sesión desde 'Perfil' y volver a iniciarla poniendo nuevamente usuario y contraseña. ¡Gracias!";
                  final artistsProvider = Provider.of<ArtistsProvider>(context, listen: false);
                  final resp = await artistsProvider.activateArtist(widget.artist.id);
                  setState(() => isSaving = false);
                  if (resp['success']) {
                    showSuccessMessage(context, resp["message"]);
                    await Future.wait([
                      artistsProvider.getArtists(null, _offset, _limit),
                      artistsProvider.getArtistsRequests(null, _offset, _limit),
                      artistsProvider.getArtistsSuspensions(null, _offset, _limit),
                      chatProvider.updateLastMessage(conversation.id, "¡Gracias por registrarte como artista! Para que el perfil de artista sea activado...", _preferences.userId, conversation.user.id),
                    ]);
                    /*
                    Firestore.instance.collection('conversations').document("${conversation.conversationId}").collection("messages").add({
                      'text': _messageText,
                      'created_at': Timestamp.now(),
                      'is_admin': _preferences.userTypeId == 3,
                    });
                    */
                  }else{ 
                    showErrorMessage(context, resp["message"]);
                  }
                },
                loading: isSaving,
                width: 125,
                color: greyColor,
                height: 35,
                text: "Aprobar",
                textStyle: text4.copyWith(color:whiteColor),
              ),
            if(widget.artist.status == "1")
              CustomGeneralButton(
                onPressed: () async {
                  setState(() => isSaving = true);
                  final resp = await artistsProvider.suspendArtist(widget.artist.id);
                  setState(() => isSaving = false);
                  if (resp['success']) {
                    showSuccessMessage(context, resp["message"]);
                    await Future.wait([
                      artistsProvider.getArtists(null, _offset, _limit),
                      artistsProvider.getArtistsRequests(null, _offset, _limit),
                      artistsProvider.getArtistsSuspensions(null, _offset, _limit),
                    ]);
                  }else{ 
                    showErrorMessage(context, resp["message"]);
                  }
                },
                loading: isSaving,
                width: 125,
                color: redColor,
                height: 35,
                text: "Suspender",
                textStyle: text4.copyWith(color:whiteColor),
              ),
            if(widget.artist.status == "3")
              Row(
                children: [
                  CustomGeneralButton(
                    onPressed: () async {
                      setState(() => isSaving = true);
                      final resp = await artistsProvider.reactivateArtist(widget.artist.id);
                      setState(() => isSaving = false);
                      if (resp['success']) {
                        showSuccessMessage(context, resp["message"]);
                        await Future.wait([
                          artistsProvider.getArtists(null, _offset, _limit),
                          artistsProvider.getArtistsRequests(null, _offset, _limit),
                          artistsProvider.getArtistsSuspensions(null, _offset, _limit),
                        ]);
                      }else{ 
                        showErrorMessage(context, resp["message"]);
                      }
                    },
                    loading: isSaving,
                    width: 125,
                    color: Colors.yellow,
                    height: 35,
                    text: "Reactivar",
                    textStyle: text4,
                  ),
                  SizedBox(width: 8,),
                  CustomGeneralButton(
                    onPressed: () async {
                      _deleteConfirmation(context);
                    },
                    loading: isSaving,
                    width: 125,
                    color: Colors.red,
                    height: 35,
                    text: "Eliminar",
                    textStyle: text4,
                  ),
                ],
              ),
            if(widget.artist.status == "2")
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomGeneralButton(
                        onPressed: () async {
                          setState(() => isSaving = true);
                          final artistsProvider = Provider.of<ArtistsProvider>(context, listen: false);
                          final resp = await artistsProvider.rejectArtist(widget.artist.id);
                          setState(() => isSaving = false);
                          if (resp['success']) {
                            showSuccessMessage(context, resp["message"]);
                            await Future.wait([
                              artistsProvider.getArtists(null, _offset, _limit),
                              artistsProvider.getArtistsRequests(null, _offset, _limit),
                              artistsProvider.getArtistsSuspensions(null, _offset, _limit),
                            ]);
                          }else{ 
                            showErrorMessage(context, resp["message"]);
                          }
                        },
                        loading: isSaving,
                        width: 120,
                        color: AppTheme.getTheme().colorScheme.secondary,
                        height: 35,
                        text: "Rechazar",
                      ),
                      CustomGeneralButton(
                        onPressed: () async { 
                          setState(() => isSaving = true);
                          final ConversationModel conversation = chatProvider.adminAllConversations.firstWhere((element) => element.user.id == widget.artist.userId);
                          final String _messageText = "¡Gracias por registrarte como artista! Para que el perfil de artista sea activado en tu celular es necesario cerrar sesión desde 'Perfil' y volver a iniciarla poniendo nuevamente usuario y contraseña. ¡Gracias!";
                          final artistsProvider = Provider.of<ArtistsProvider>(context, listen: false);
                          final resp = await artistsProvider.activateArtist(widget.artist.id);
                          setState(() => isSaving = false);
                          if (resp['success']) {
                            showSuccessMessage(context, resp["message"]);
                            await Future.wait([
                              artistsProvider.getArtists(null, _offset, _limit),
                              artistsProvider.getArtistsRequests(null, _offset, _limit),
                              artistsProvider.getArtistsSuspensions(null, _offset, _limit),
                              chatProvider.updateLastMessage(conversation.id, "¡Gracias por registrarte como artista! Para que el perfil de artista sea activado...", _preferences.userId, conversation.user.id),
                            ]);
                            /*
                            Firestore.instance.collection('conversations').document("${conversation.conversationId}").collection("messages").add({
                              'text': _messageText,
                              'created_at': Timestamp.now(),
                              'is_admin': _preferences.userTypeId == 3,
                            });
                            */
                          }else{ 
                            showErrorMessage(context, resp["message"]);
                          }
                        },
                        loading: isSaving,
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
      },
    );
  }

  _deleteConfirmation(BuildContext context) {
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
                  "¿Está seguro que desea eliminar a este artista?",
                  style: title2.copyWith(color: AppTheme.secondaryColors),
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
                              color: AppTheme.getTheme().colorScheme.surface,
                              textStyle: title3,
                              width: size.width*0.3,
                              onPressed: () async {
                                setState(() => isSaving = true);
                                final resp = await Provider.of<ArtistsProvider>(context, listen: false).deleteArtist(widget.artist.id);
                                setState(() => isSaving = false);
                                if (resp['success']) {
                                  showSuccessMessage(context, resp["message"]);
                                  await Future.wait([
                                    Provider.of<ArtistsProvider>(context, listen: false).getArtists(null, _offset, _limit),
                                    Provider.of<ArtistsProvider>(context, listen: false).getArtistsRequests(null, _offset, _limit),
                                    Provider.of<ArtistsProvider>(context, listen: false).getArtistsSuspensions(null, _offset, _limit),
                                  ]);
                                  Navigator.of(context).pushNamed("admin-artists");
                                }else{ 
                                  showErrorMessage(context, resp["message"]);
                                  await Future.delayed(const Duration(seconds: 3));
                                  Navigator.of(context).pushNamed("admin-artists"); 
                                }
                              }, 
                            ),
                            CustomGeneralButton(
                              text: "No",
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