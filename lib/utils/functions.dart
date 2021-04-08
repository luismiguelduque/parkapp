import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:location_permissions/location_permissions.dart';
//import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:date_format/date_format.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flushbar/flushbar.dart';
//import 'package:firebase_auth/firebase_auth.dart';

import '../utils/preferences.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_general_button.dart';
import './constants.dart';
import '../screens/admin/events/admin_events_screen.dart';
import '../screens/artist/events/artist_events_screen.dart';
import '../screens/audience/events/audience_events_screen.dart';
import '../screens/common/ask_location.dart';


String formatTimeOfDay(TimeOfDay tod) {
  if(tod != null){
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat('HH:mm');  //"6:00 AM"
    return format.format(dt);
  }else{
    return "";
  }
}

String formaterDateTime(DateTime fecha) {
  if(fecha != null){
    return formatDate(fecha, [dd, '/', mm, '/', yyyy, ' - ', HH, ':', nn]).toString();
  }
  return "";
}

String formaterDate(DateTime fecha) {
  if(fecha != null){
    return formatDate(fecha, [dd, '-', mm, '-', yyyy]).toString();
  }
  return "";
}

bool validateEmail(String email) {
  return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
}

showErrorMessage(BuildContext context, message){
  
  Flushbar(
    title:  "¡Atención!",
    message:  message,
    duration:  Duration(seconds: 8),
    backgroundColor: redColor.withOpacity(0.7),
  )..show(context);
  
}

showWarningMessage(BuildContext context, message){
  
  Flushbar(
    title:  "¡Atención!",
    message:  message,
    duration:  Duration(seconds: 8),
    backgroundColor: redColor.withOpacity(0.7),
  )..show(context);
  
}

showSuccessMessage(BuildContext context, message){
  
  Flushbar(
    title:  "¡Fantástico!",
    message:  message,
    duration:  Duration(seconds: 8),
    backgroundColor: greenColor.withOpacity(0.7),
  )..show(context);
  
}

logOutConfirmation(BuildContext context) {
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
                "¿Está seguro que desea cerrar la sesión?",
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
                              await Provider.of<AuthProvider>(context, listen: false).logOut();
                              Navigator.of(context).pushReplacementNamed("wellcome");
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

TimeOfDay stringToTimeOfDay(String tod) {
  return TimeOfDay(hour: int.parse(tod.split(":")[0]), minute: int.parse(tod.split(":")[1]));
}

Future<Position> getCurrentUserLocation() async {
  bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    PermissionStatus permission = await LocationPermissions().requestPermissions();
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.deniedForever) {
    return Future.delayed(Duration(milliseconds: 1)).then((value) => Position(latitude: -34.61315, longitude: -58.37723));
    //return Future.error('Location permissions are permantly denied, we cannot request permissions.');
  }
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
      return Future.delayed(Duration(milliseconds: 1)).then((value) => Position(altitude: -34.61315, longitude: -58.37723));
      //return Future.error('Location permissions are denied (actual value: $permission).');
    }
  }
  return await Geolocator.getCurrentPosition();
}

/*
Future loginWithFacebook(BuildContext context) async {
  final _auth = FirebaseAuth.instance;
  final fbLogin = FacebookLogin();
  final FacebookLoginResult result = await fbLogin.logIn(["email"]);
  if(result.errorMessage == null){
    final String token = result.accessToken.token;
    final resp = await Provider.of<AuthProvider>(context, listen: false).logInFacebook(token);
    if (resp['success']) {
      await _auth.signInAnonymously();
      showSuccessMessage(context, resp["message"]);
      await Future.delayed(const Duration(seconds: 3), (){});
      final prefs = new Preferences();
      if(prefs.token!="0" && prefs.token!=null){
        if(prefs.cityId < 1 || prefs.neighborhoodId < 1){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AskLocation()));
        }else{
          if(prefs.userTypeId==1){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AudienceEventsScreen()));
          }else if(prefs.userTypeId==2){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => ArtistEventsScreen()));
          }else if(prefs.userTypeId==2){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AdminEventsScreen()));
          }else{
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AudienceEventsScreen()));
          }
        }
      }
    }else{ 
      showErrorMessage(context, resp["message"]);
    }
  }else{
    showErrorMessage(context, "Lo sentimos, ha habido un problema. Por favor intente nuevamente mas tarde o use otro método de inicio de sesión");
  }
}
*/