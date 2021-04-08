import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../utils/preferences.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_general_button.dart';

class AlertGps extends StatefulWidget {
  @override
  _AlertGpsState createState() => _AlertGpsState();
}

class _AlertGpsState extends State<AlertGps> {

  bool _isLoaded = false;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void didChangeDependencies() async {
    if(!_isLoaded){
      _isLoading = true;
      setState(() {
        _isLoading = false;
        _isLoaded = true;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: _isLoading 
        ? Center(child: CircularProgressIndicator()) 
        : SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: size.height*0.05,),
                Icon(Icons.pin_drop, size: 80.0,),
                Container(
                  width: size.width,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Acceder a tu ubicación", textAlign: TextAlign.center, style: TextStyle(color: AppTheme.getTheme().colorScheme.secondary, fontSize: 32, fontWeight: FontWeight.bold),)
                ),
                SizedBox(height: 10,),
                Container(
                  width: size.width,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Text(
                    "Permitir a Park App acceder a tu ubicación para darte una experiencia completa y mostrarte los espectáculos cerca tuyo en cualquier lugar.", 
                    textAlign: TextAlign.center, 
                    style: TextStyle(
                      color: greyVeryLightColor, 
                      fontSize: 22.5, 
                    ),
                  )
                ),
                SizedBox(height: 20,),
                CustomGeneralButton(
                  height: 50,
                  loading: _isSaving,
                  width: size.width*0.8,
                  color: AppTheme.getTheme().colorScheme.primary,
                  text: "Confirmar",
                  onPressed: () async {
                    final prefs = new Preferences();
                    setState(() {
                      _isSaving = true;
                    });
                    await getCurrentUserLocation();
                    setState(() {
                      _isSaving = false;
                    });
                    if(prefs.userTypeId==1){
                      Navigator.of(context).pushNamed('audience-events');
                    }else if(prefs.userTypeId==2){
                      Navigator.of(context).pushNamed('artist-events');
                    }else if(prefs.userTypeId==3){
                      Navigator.of(context).pushNamed('admin-events');
                    }else{
                      Navigator.of(context).pushNamed('audience-events');
                    }
                  },
                ),
                SizedBox(height: 10,),
                CustomGeneralButton(
                  height: 50,
                  loading: _isSaving,
                  width: size.width*0.8,
                  color: greyVeryLightColor,
                  text: "En otro momento",
                  onPressed: () async {
                    final prefs = new Preferences();
                    if(prefs.userTypeId==1){
                      Navigator.of(context).pushNamed('audience-events');
                    }else if(prefs.userTypeId==2){
                      Navigator.of(context).pushNamed('artist-events');
                    }else if(prefs.userTypeId==3){
                      Navigator.of(context).pushNamed('admin-events');
                    }else{
                      Navigator.of(context).pushNamed('audience-events');
                    }
                  },
                ),
                SizedBox(height: size.height*0.1,),
              ],
            ),
          ),
        ),
    );
  }
}