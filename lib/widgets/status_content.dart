import 'package:flutter/material.dart';
import 'package:parkapp/utils/constants.dart';

import '../utils/app_theme.dart';

class StatusContent extends StatelessWidget {

  final String status;

  StatusContent({
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    if(status == '1'){
      color = Colors.green;
      text = "";
    }else if(status == '2'){
      color = AppTheme.getTheme().colorScheme.primary;
      text = "Pendiente";
    }
    else if(status == '3'){
      color = Colors.red;
      text = "Bloqueado";
    }
    else if(status == '4'){
      color = Colors.redAccent;
      text = "Denunciado";
    }
    else if(status == '5'){
      color = greyColor;
      text = "Rechazado";
    }
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15)
      ),
      child: Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),),
    );
  }
}