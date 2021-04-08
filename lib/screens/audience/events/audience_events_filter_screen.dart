import 'package:flutter/material.dart';
import 'package:parkapp/utils/app_theme.dart';
import 'package:parkapp/utils/constants.dart';

class AudienceEventsFilterScreen extends StatefulWidget {
  @override
  _AudienceEventsFilterScreenState createState() => _AudienceEventsFilterScreenState();
}

class _AudienceEventsFilterScreenState extends State<AudienceEventsFilterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        leading: IconButton(
          onPressed: (){
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: greyColor,),
        ),
        centerTitle: false,
        title: Text("Filtrar", style: AppTheme.getTheme().textTheme.headline1,),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    
                  ],
                )
              ),
            ]
          ),
        ),
      )
    );
  }
}