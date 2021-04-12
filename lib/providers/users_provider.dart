import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:parkapp/models/id_model.dart';
import 'package:parkapp/models/user_model.dart';

import '../utils/constants.dart';
import '../utils/preferences.dart';

class UsersProvider extends ChangeNotifier {
   Map<String, String> requestHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json'
  };
  final _preferences = new Preferences();
  
  UserModel _user;
  UserModel get user  {
    return _user;
  }

  List<IdModel> _eventsLikes;
  List<IdModel> get eventsLikes{
    return [..._eventsLikes];
  }

  Future<void> getUserEventsLikes() async {
    final Uri uri =developmentMode ? Uri.https(apiUrl, "api/users/events-likes", {}) : Uri.http(apiUrl, "api/users/events-likes", {});
    try {
      final response = await http.get(
        uri, 
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_preferences.token}',
        }
      );
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if(extractedData == null) return;
      final List<IdModel> tempItems = [];
      List ids = extractedData['data'];
      ids.forEach((element) {
        tempItems.add(IdModel.fromJson(element));
      });
      _eventsLikes = tempItems;
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
    }
  }
  
  Future<Map<String, dynamic>> changeDataUser(int userId, String name) async {
    Map<String, dynamic> respJson = {};
    final Uri uri =developmentMode ? Uri.https(apiUrl, "api/users/$userId", {}) : Uri.http(apiUrl, "api/users/$userId", {});
    try {
      final response = await http.put(
        uri, 
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_preferences.token}',
        },
        body: json.encode({
          'name': name,
        }),
      );
      final decodedResponse = json.decode(response.body) as Map<String, dynamic>;
      if (decodedResponse['success']) {
        _preferences.name = decodedResponse['data']['name'];
        respJson['success'] = true;
        respJson['message'] = decodedResponse['message'];
      } else {
        if(decodedResponse['message'] == 'The given data was invalid'){
          final Map<String, dynamic> errors = decodedResponse['errors'];
          errors.forEach((key, value) {
            respJson['success'] = false;
            respJson['message'] = value.toString();
          });
        }else{
          respJson['success'] = false;
          respJson['message'] = 'No pudimos procesar tu petición. Por favor, intenta mas tarde';
        }
      }
      return respJson;
    } catch (error) {
      respJson['success'] = false;
      respJson['message'] = 'No pudimos procesar tu petición. Por favor, intenta mas tarde';
      return respJson;
    }
  }

  Future<Map<String, dynamic>> setUserLocation(String lat, String long) async {
    Map<String, dynamic> respJson = {};
    final Uri uri =developmentMode ? Uri.https(apiUrl, "api/users/set-location", {}) : Uri.http(apiUrl, "api/users/set-location", {});
    try {
      final response = await http.put(
        uri, 
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_preferences.token}',
        },
        body: json.encode({
          'lat': lat,
          'long': long,
        }),
      );
      final decodedResponse = json.decode(response.body) as Map<String, dynamic>;
      if (decodedResponse['success']) {
        respJson['success'] = true;
        respJson['message'] = decodedResponse['message'];
      } else {
        if(decodedResponse['message'] == 'The given data was invalid'){
          final Map<String, dynamic> errors = decodedResponse['errors'];
          errors.forEach((key, value) {
            respJson['success'] = false;
            respJson['message'] = value.toString();
          });
        }else{
          respJson['success'] = false;
          respJson['message'] = 'No pudimos procesar tu petición. Por favor, intenta mas tarde';
        }
      }
      return respJson;
    }catch(error){
      respJson['success'] = false;
      respJson['message'] = 'No pudimos procesar tu petición. Por favor, intenta mas tarde';
      return respJson;
    }
  }

  Future<Map<String, dynamic>> setUserFCM(String key) async {
    Map<String, dynamic> respJson = {};
    final Uri uri =developmentMode ? Uri.https(apiUrl, "api/users/set-fcm", {}) : Uri.http(apiUrl, "api/users/set-fcm", {});
    try {
      final response = await http.put(
        uri, 
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_preferences.token}',
        },
        body: json.encode({
          'fcm_id': key,
        }),
      );
      final decodedResponse = json.decode(response.body) as Map<String, dynamic>;
      print("setUserFCM --------");
      print(key);
      print(decodedResponse);
      if (decodedResponse['success']) {
        respJson['success'] = true;
        respJson['message'] = decodedResponse['message'];
      } else {
        if(decodedResponse['message'] == 'The given data was invalid'){
          final Map<String, dynamic> errors = decodedResponse['errors'];
          errors.forEach((key, value) {
            respJson['success'] = false;
            respJson['message'] = value.toString();
          });
        }else{
          respJson['success'] = false;
          respJson['message'] = 'No pudimos procesar tu petición. Por favor, intenta mas tarde';
        }
      }
      return respJson;
    }catch(error){
      print(error);
      respJson['success'] = false;
      respJson['message'] = 'No pudimos procesar tu petición. Por favor, intenta mas tarde';
      return respJson;
    }
  }
}