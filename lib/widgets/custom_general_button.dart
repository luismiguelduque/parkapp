import 'package:flutter/material.dart';

import '../utils/constants.dart';

class CustomGeneralButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color borderColor;
  final double height;
  final double width;
  final Function onPressed;
  final TextStyle textStyle;
  final double marginHorizontal;
  final double marginVertical;
  final double paddingButtonHorizontal;
  final double paddingButtonVertical;
  final bool loading;
  final Color loadingColor;
  //final Color border;

  CustomGeneralButton({
    this.text,
    this.color = Colors.transparent,
    this.borderColor = Colors.transparent,
    this.height,
    this.width,
    this.onPressed,
    this.textStyle = title3,
    this.marginHorizontal = 0.0,
    this.marginVertical = 0.0,
    this.paddingButtonHorizontal = 0.0,
    this.paddingButtonVertical = 0.0,
    //this.border = primaryColor,
    this.loading = false,
    this.loadingColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: EdgeInsets.symmetric(horizontal: marginHorizontal, vertical: marginVertical),
      child: RaisedButton(
        color: color,
        padding: EdgeInsets.symmetric(
          horizontal: paddingButtonHorizontal, 
          vertical: paddingButtonVertical
        ),
        onPressed: !loading ? onPressed : (){},
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          side: BorderSide(
            color: borderColor,
            width: 2.0,
            style: BorderStyle.solid,
          ),
        ),
        child: loading 
        ? CircularProgressIndicator(
          backgroundColor: loadingColor,
        )
        : Text( text,style: textStyle) ?? Container()
      ),
    );
  }
}
