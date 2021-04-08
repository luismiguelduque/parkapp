import 'package:flutter/material.dart';
import 'dart:io';

import '../utils/constants.dart';

class ImagesSlideFiles extends StatelessWidget {
  
  final List<File> images;
  final Function(int index) onDeleteFunction;

  ImagesSlideFiles({
    @required this.images,
    this.onDeleteFunction,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scrollbar(
      child: Container(
        width: width,
        height: 150.0,
        padding: EdgeInsets.only(top: 25.0, bottom: 10.0),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: images.length,
          itemBuilder: (ctx, index) {
            return _imageSlide(context, images[index], index);
          }
        ),
      ),
    );
  }

  Container _imageSlide(BuildContext context, File img, int index) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        color: greyColor,
        borderRadius: BorderRadius.circular(25.0),
      ),
      margin: EdgeInsets.only(right: 10.0),
      padding: EdgeInsets.all(1.0),
      child: Container(
        width: width * 0.3,
        height: width * 0.3,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: FadeInImage(
                width: width * 0.3,
                placeholder: AssetImage("assets/images/loading.gif"),
                image: img != null ? FileImage(img) : AssetImage("assets/images/no-image.png"),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: -12,
              right: -12,
              child: IconButton(
                icon: Icon(Icons.cancel, size: 30, color: redColor.withOpacity(0.7),),
                onPressed: (){
                  onDeleteFunction(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}