import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../models/event_category_model.dart';
import '../utils/preferences.dart';
import '../utils/constants.dart';

class CategoriesProvider extends ChangeNotifier {

  final _preferences = new Preferences();
  List<EventCategoryModel> _categories= [];
  List<EventCategoryModel> get categories {
    return [..._categories];
  }

  Future<void> getEventCategory() async {
    final Uri uri =developmentMode ? Uri.https(apiUrl, "api/categories", {}) : Uri.http(apiUrl, "api/categories", {});
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
      if (extractedData == null) {
        return;
      }
      final List<EventCategoryModel> tempItems = [];
      List envenCategory = extractedData['data'];
      envenCategory.forEach((element) {
        tempItems.add(EventCategoryModel.fromJson(element));
      });
      _categories = tempItems;
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
    }
  }

  Future<Map<String, dynamic>> storeEventCategory(String description) async {
    Map<String, dynamic> respJson = {};
    final Uri uri =developmentMode ? Uri.https(apiUrl, "api/categories", {}) : Uri.http(apiUrl, "api/categories", {});
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

  Future<Map<String, dynamic>> deleteCategoryEvent(int eventId) async {
    Map<String, dynamic> respJson = {};
    final Uri uri =developmentMode ? Uri.https(apiUrl, "api/categories/$eventId", {}) : Uri.http(apiUrl, "api/categories/$eventId", {});
    try {
      final response = await http.delete(
        uri, 
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_preferences.token}',
        }
      );
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

  Future<Map<String, dynamic>> updateCategoryEvent(int eventId, String description) async {
    Map<String, dynamic> respJson = {};
    final Uri uri =developmentMode ? Uri.https(apiUrl, "api/categories/$eventId", {}) : Uri.http(apiUrl, "api/categories/$eventId", {});
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

}