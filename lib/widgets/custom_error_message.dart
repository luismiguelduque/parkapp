import 'package:flutter/material.dart';

import 'package:parkapp/utils/constants.dart';

class CustomErrorMessage extends StatelessWidget {
  
  final String message;
  
  const CustomErrorMessage({
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if(message != null && message != '') {
    return Container(
      width: size.width,
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Text(
        message,
        style: text5.copyWith(color: redColor),
      ),
    );
  } 
    return Container();
  }
}