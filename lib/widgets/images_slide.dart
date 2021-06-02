import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/events_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/functions.dart';
import '../models/image_model.dart';
import '../widgets/custom_general_button.dart';


class ImagesSlide extends StatefulWidget {
  
  final List<ImageModel> images;
  final bool isDeleted;
  final String deleteImage;
  final int id;

  ImagesSlide({
    @required this.images,
    this.isDeleted=false,
    this.deleteImage,
    this.id
  });

  @override
  _ImagesSlideState createState() => _ImagesSlideState();
}

class _ImagesSlideState extends State<ImagesSlide> {

  bool _isSaving=false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      height: 140.0,
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.images.length,
        itemBuilder: (ctx, index) {
          return _imageSlide(context, widget.images[index]);
        }
      ),
    );
  }

  Container _imageSlide(BuildContext context, ImageModel image) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        //color: greyVeryLightColor,
        borderRadius: BorderRadius.circular(15.0),
      ),
      margin: EdgeInsets.only(right: 10.0),
      padding: EdgeInsets.all(1.0),
      child: Container(
        width: width * 0.3,
        height: width * 0.3,
        child: Stack(
          children: [
            GestureDetector(
              onTap: (){
                _showDialog(context, image.image);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: FadeInImage(
                  width: width * 0.3,
                  placeholder: AssetImage("assets/images/loading.gif"),
                  image: image != null ? NetworkImage(image.image) : AssetImage("assets/images/no-image.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            /*
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: greyColor.withOpacity(0.2),
                child: IconButton(
                  icon: Icon(Icons.search,color: blackColor, size: 28),
                  onPressed: () {
                    _showDialog(context, image.image);
                  },
                ),
              ),
            ),
            */
            if(widget.isDeleted)
              Positioned(
                top: -12,
                right: -12,
                child: IconButton(
                  icon: Icon(Icons.cancel, size: 30, color: redColor.withOpacity(0.7),),
                  onPressed: ()async {
                    _showDialogDelete(context, image.id);
                  }, 
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  _showDialog(BuildContext context, String image) {
    final size = MediaQuery.of(context).size;
    if(Platform.isAndroid){
      return showDialog(
        context: context, 
        builder: (context){
          return AlertDialog(
            content: Container(
              height: size.height*0.4,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(image),
                  fit: BoxFit.contain
                )
              ),
            ),
            actions: [
              MaterialButton(
                elevation: 5,
                child: Text("Cerrar"),
                textColor: Colors.grey,
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        },
      );
    }

    showCupertinoDialog(
      context: context, 
      builder: (_){
        return CupertinoAlertDialog(
          content: Container(
            height: size.height*0.4,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.contain
              )
            ),
          ),
          actions: [
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text("Cerrar"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      }
    );
  }

  void _showDialogDelete(BuildContext context, int imageId) {
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
                              paddingButtonHorizontal: 10,
                              color: AppTheme.getTheme().colorScheme.surface,
                              textStyle: title3,
                              width: size.width*0.3,
                              loading: _isSaving,
                              onPressed: _isSaving ? null : () async {
                                setState((){
                                  _isSaving = true;
                                });
                                if(widget.deleteImage == 'event'){
                                  final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
                                  Map<String, dynamic> response = await eventsProvider.deleteEventImage(imageId);
                                  setState((){
                                    _isSaving = false;
                                  });
                                  Navigator.pop(context);
                                  if (response['success']) {
                                    showSuccessMessage(context, "Imagen borrada exitosamente");
                                    eventsProvider.getEventDetail(widget.id);
                                  } else {
                                    showErrorMessage(context, "Ha habido un problema al procesar su peticion. Por favor, intente nuevamente.");
                                  }
                                }
                                
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
}