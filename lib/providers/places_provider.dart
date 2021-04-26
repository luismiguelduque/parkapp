import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../models/city_model.dart';
import '../models/neighborhood_model.dart';
import '../models/place_model.dart';
import '../models/province_model.dart';
import '../utils/constants.dart';
import '../utils/preferences.dart';

class PlacesProvider extends ChangeNotifier {

  final _preferences = new Preferences();

  List<PlaceModel> _places = [];
  List<PlaceModel> get places{
    return [..._places];
  }

  List<PlaceModel> get placesRestricted{
    return _places.where((element) => element.restricted == '1' ).toList();
  }

  List<ProvinceModel> _provinces = [];
  List<ProvinceModel> get provinces{
    return [..._provinces];
  }

  List<CityModel> _cities = [];
  List<CityModel> get cities{
    return [..._cities];
  }

  List<NeighborhoodModel> _neighborhoods = [];
  List<NeighborhoodModel> get neighborhoods{
    return [..._neighborhoods];
  }

  Future<void> getPlaces() async {
    final Uri uri =developmentMode ? Uri.https(apiUrl, "api/places", {}) : Uri.http(apiUrl, "api/places", {});
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
      final List<PlaceModel> tempItems = [];
      List places = extractedData['data'];
      places.forEach((element) {
        tempItems.add(PlaceModel.fromJson(element));
      });
      _places = tempItems;
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
    }
  }

  Future<void> getProvinces() async {
    final Uri uri =developmentMode ? Uri.https(apiUrl, "api/provinces", {}) : Uri.http(apiUrl, "api/provinces", {});
    try {
      final response = await http.get(uri, headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${_preferences.token}',
      });
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      print("extractedData");
      print(extractedData);
      if (extractedData == null) {
        return;
      }
      final List<ProvinceModel> tempItems = [];
      List provinces = extractedData['data'];
      provinces.forEach((element) {
        tempItems.add(ProvinceModel.fromJson(element));
      });
      _provinces = tempItems;
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
    }
  }

  Future<void> getCities() async {
    final Uri uri =developmentMode ? Uri.https(apiUrl, "api/cities", {}) : Uri.http(apiUrl, "api/cities", {});
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
      final List<CityModel> tempItems = [];
      List cities = extractedData['data'];
      cities.forEach((element) {
        tempItems.add(CityModel.fromJson(element));
      });
      _cities = tempItems;
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
    }
  }

  Future<void> getNeighborhoods() async {
    final Uri uri =developmentMode ? Uri.https(apiUrl, "api/neighborhoods", {}) : Uri.http(apiUrl, "api/neighborhoods", {});
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
      final List<NeighborhoodModel> tempItems = [];
      List neighborhoods = extractedData['data'];
      neighborhoods.forEach((element) {
        tempItems.add(NeighborhoodModel.fromJson(element));
      });
      _neighborhoods = tempItems;
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
    }
  }

  Future<Map<String, dynamic>> updateUserLocation(int provinceId, int cityId, int neighborhoodId) async {
    Map<String, dynamic> respJson = {};
    final Uri uri =developmentMode ? Uri.https(apiUrl, "api/users/update-location", {}) : Uri.http(apiUrl, "api/users/update-location", {});
    try{
      final response = await http.post(
        uri, 
        headers: { 
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${ _preferences.token }',
        },
        body: json.encode({
          'user_id': _preferences.userId,
          'province_id': provinceId,
          'city_id': cityId,
          'neighborhood_id': neighborhoodId,
        }),
      );
      final decodedResponse = json.decode(response.body) as Map<String, dynamic>;
      print("decodedResponse");
      print(decodedResponse);
      if (decodedResponse['success']) {

        _preferences.provinceId = provinceId;
        _preferences.cityId = cityId;
        _preferences.neighborhoodId = neighborhoodId;

        respJson['success'] = true;
        respJson['message'] = 'Datos guardados exitosamente';
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

  Future<Map<String, dynamic>> savePlace(PlaceModel placeModel) async {
    print("savePlace");
    Map<String, dynamic> respJson = {};
    final Uri uri =developmentMode ? Uri.https(apiUrl, "api/places", {}) : Uri.http(apiUrl, "api/places", {});
    try {
      final response = await http.post(
        uri, 
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_preferences.token}',
        },
        body: json.encode({
          'name': placeModel.name,
          'description': placeModel.description,
          'address': placeModel.address,
          'lat': placeModel.lat,
          'long': placeModel.long,
          'neighborhood_id': placeModel.neighborhood.id,
          'daily_limit': placeModel.dailyLimit, 
          'restricted': placeModel.restricted,
        }),
      );
      final decodedResponse = json.decode(response.body) as Map<String, dynamic>;
      print("decodedResponse savePlace");
      print(decodedResponse);
      if (decodedResponse['success']) {
        respJson['success'] = true;
        respJson['message'] = decodedResponse['message'];
      } else {
        print("-----");
        print(decodedResponse['message']);
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

  Future<Map<String, dynamic>> updatePlace(PlaceModel placeModel) async {
    print("updatePlace");
    final Uri uri =developmentMode ? Uri.https(apiUrl, "api/places/${placeModel.id}", {}) : Uri.http(apiUrl, "api/places/${placeModel.id}", {});
    Map<String, dynamic> respJson = {};
    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_preferences.token}',
        },
        body: json.encode({
          'name': placeModel.name,
          'description': placeModel.description,
          'address': placeModel.address,
          'lat': placeModel.lat,
          'long': placeModel.long,
          'neighborhood_id': placeModel.neighborhood.id,
          'daily_limit': placeModel.dailyLimit, 
          'restricted': placeModel.restricted,
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

  Future<Map<String, dynamic>> deletePlace(int placeId) async {
    final Uri uri =developmentMode ? Uri.https(apiUrl, "api/places/$placeId", {}) : Uri.http(apiUrl, "api/places/$placeId", {});
    Map<String, dynamic> respJson = {};
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

}