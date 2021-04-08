import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../utils/preferences.dart';
import '../utils/constants.dart';
import '../models/artistic_genres_model.dart';


class GenresProvider extends ChangeNotifier {

  Map<String, String> requestHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json'
  };
  final _preferences = new Preferences();

  List<ArtisticGenreModel> _artisticGenres = [];
  List<ArtisticGenreModel> get artisticGenres {
    return [..._artisticGenres];
  }
  
  Future<void> getArtisticGenres() async {
    final Uri uri = Uri.https(apiUrl, "api/artistic-genre", {});
    try {
      final response = await http.get(uri, headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${_preferences.token}',
      });
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final List<ArtisticGenreModel> tempItems = [];
      List artisticGenres = extractedData['data'];
      artisticGenres.forEach((element) {
        tempItems.add(ArtisticGenreModel.fromJson(element));
      });
      _artisticGenres = tempItems;
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
    }
  }
  
  Future<Map<String, dynamic>> storeEventCatGenre(String description) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "api/artistic-genre", {});
    try {
      final response = await http.post(uri, headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${_preferences.token}',
      },
      body: json.encode({
        'name': description,
        'description': description,
      }),
      );
      final decodedResponse = json.decode(response.body) as Map<String, dynamic>;
      print("decodedResponse ------ ");
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

  Future<Map<String, dynamic>> deleteCategoryGenre(int genreId) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "api/artistic-genre/$genreId", {});
    try {
      final response = await http.delete(uri, headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${_preferences.token}',
      });
      final decodedResponse = json.decode(response.body) as Map<String, dynamic>;
      print("decodedResponse");
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

  Future<Map<String, dynamic>> updateCategoryGenre(int genreId, String description) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "api/artistic-genre/$genreId", {});
    try {
      final response = await http.put(
        uri, 
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_preferences.token}',
        },
        body: json.encode({
          'name': description,
          'description': description,
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
      print(error);
      respJson['success'] = false;
      respJson['message'] = 'No pudimos procesar tu petición. Por favor, intenta mas tarde';
      return respJson;
    }
  }
}