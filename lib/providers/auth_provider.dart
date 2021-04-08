import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/preferences.dart';

class AuthProvider with ChangeNotifier {
  
  Map<String, String> requestHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json'
  };
  final _preferences = new Preferences();
  UserModel _user;

  UserModel get user  {
    return _user;
  }

  Future<void> getUser() async {
    final Uri uri = Uri.https(apiUrl, "api/users/${_preferences.userId}", {});
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
      _user = UserModel.fromJson(extractedData['data']);
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
    }
  }

  Future<Map<String, dynamic>> logInFacebook(String token) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "api/auth/sign-in-with-facebook", {});
    try {
      final response = await http.post(
        uri, 
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'token': token,
        }),
      );
      final decodedResponse = json.decode(response.body) as Map<String, dynamic>;
      print("decodedResponse logInFacebook");
      print(decodedResponse);
      if (decodedResponse['success'] && decodedResponse.containsKey('token')) {
        setPreferences(decodedResponse);
        respJson['success'] = true;
        respJson['message'] = 'Bienvenido de vuelta';
      } else {
        if(decodedResponse['message'] == 'The given data was invalid'){
          final Map<String, dynamic> errors = decodedResponse['errors'];
          errors.forEach((key, value) {
            respJson['success'] = false;
            respJson['message'] = value.toString();
          });
        }else if(decodedResponse['message'] == 'Datos de acceso incorrectos'){
          respJson['success'] = false;
          respJson['message'] = decodedResponse['message'];
        }else{
          respJson['success'] = false;
          respJson['message'] = 'No pudimos procesar tu petición. Por favor, intenta mas tarde';
        }
      }
      return respJson;
    } catch (error) {
      print(error);
      return {};
    }
  }

  Future<Map<String, dynamic>> logInInstagram(String token) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "api/auth/sign-in-with-instagram", {});
    try {
      final response = await http.post(
        uri, 
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'token': token,
        }),
      );
      final decodedResponse = json.decode(response.body) as Map<String, dynamic>;
      if (decodedResponse['success'] && decodedResponse.containsKey('token')) {
        setPreferences(decodedResponse);
        respJson['success'] = true;
        respJson['message'] = 'Bienvenido de vuelta';
      } else {
        if(decodedResponse['message'] == 'The given data was invalid'){
          final Map<String, dynamic> errors = decodedResponse['errors'];
          errors.forEach((key, value) {
            respJson['success'] = false;
            respJson['message'] = value.toString();
          });
        }else if(decodedResponse['message'] == 'Datos de acceso incorrectos'){
          respJson['success'] = false;
          respJson['message'] = decodedResponse['message'];
        }else{
          respJson['success'] = false;
          respJson['message'] = 'No pudimos procesar tu petición. Por favor, intenta mas tarde';
        }
      }
      return respJson;
    } catch (error) {
      print(error);
      return {};
    }
  }

  Future<Map<String, dynamic>> changePassword(String currentPassword, String password, String repeatPassword) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "api/auth/change-password", {});
    try {
      final response = await http.post(
        uri, 
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_preferences.token}',
        },
        body: json.encode({
          'new_password': password,
          'repeat_new_password': repeatPassword,
          'current_password': currentPassword,
        }),
      );
      final decodedResponse = json.decode(response.body) as Map<String, dynamic>;
      print("decodedResponse");
      print(decodedResponse);
      if (decodedResponse['success']) {
        respJson['success'] = true;
        respJson['message'] = decodedResponse['message'];
      } else {
        respJson['success'] = false;
        respJson['message'] = decodedResponse['message'] ?? 'No pudimos procesar tu petición. Por favor, intenta mas tarde';
      }
      return respJson;
    } catch (error) {
      print(error);
      return {};
    }
  }

  Future<Map<String, dynamic>> forgetPassword(String email) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "api/auth/resset-password/$email", {});
    try {
      final response = await http.post(
        uri, 
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
      );
      final decodedResponse = json.decode(response.body) as Map<String, dynamic>;
      print("decodedResponse");
      print(decodedResponse);
      if (!decodedResponse['success']) {
        respJson['success'] = false;
        respJson['message'] = decodedResponse['message'] ?? 'No pudimos procesar tu petición. Por favor, intenta mas tarde';
      } else {
        respJson['success'] = true;
        respJson['message'] = 'Revisa tu correo electrónico para confirmar tu solicitud para reestablecer contraseña';
      }
      return respJson;
    } catch (error) {
      print(error);
      return {};
    }
  }

  Future<Map<String, dynamic>> logIn(String email, String password) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "api/auth/login", {});
    try {
      final response = await http.post(
        uri,
        headers: requestHeaders,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ); 
      final decodedResponse = json.decode(response.body) as Map<String, dynamic>;
      if (decodedResponse['success'] && decodedResponse.containsKey('token')) {
        setPreferences(decodedResponse);
        respJson['success'] = true;
        respJson['message'] = 'Bienvenido de vuelta';
      } else {
        if(decodedResponse['message'] == 'The given data was invalid'){
          final Map<String, dynamic> errors = decodedResponse['errors'];
          errors.forEach((key, value) {
            respJson['success'] = false;
            respJson['message'] = value.toString();
          });
        }else if(decodedResponse['message'] == 'Datos de acceso incorrectos'){
          respJson['success'] = false;
          respJson['message'] = decodedResponse['message'];
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

  Future<Map<String, dynamic>> signUp(UserModel user) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "api/auth/register", {});
    try{
      final response = await http.post(
        uri, 
        headers: requestHeaders,
        body: json.encode({
          'user_type_id': 1,
          'name': user.name,
          'email': user.email,
          'password': user.password,
        }),
      );
      final decodedResponse = json.decode(response.body) as Map<String, dynamic>;
      print("decodedResponse");
      print(decodedResponse);
      if (decodedResponse['success']) {
        setPreferences(decodedResponse);
        respJson['success'] = true;
        respJson['message'] = 'Tu cuenta ha sido creada exitosamente';
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

  Future<Map<String, dynamic>> logOut() async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "api/auth/logout", {});
    try{
      final response = await http.post(
        uri, 
        headers: { 
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${ _preferences.token }',
        },
      );
      final decodedResponse = json.decode(response.body) as Map<String, dynamic>;
      if (decodedResponse['success']) {
        setPreferences(null);
        _user = null;
        respJson['success'] = true;
        respJson['message'] = 'sesión cerrada';
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
 
  void setPreferences(Map<String, dynamic> decodedResponse){
    if(decodedResponse != null){
      _preferences.token = decodedResponse['token'];
      //_preferences.expireToken = decodedResponse['expires_in'];
      _preferences.name = decodedResponse['user']['name'] ?? "";
      _preferences.email = decodedResponse['user']['email'] ?? "";
      _preferences.phone = decodedResponse['user']['phone'] ?? "";
      _preferences.userId = decodedResponse['user']['id'];
      _preferences.userTypeId= decodedResponse['user']['user_type']['id'];
      _preferences.userType = decodedResponse['user']['user_type']['name'];
      
      if(decodedResponse['user']['province'] != null){
        _preferences.provinceId = decodedResponse['user']['province']['id'];
      }
      if(decodedResponse['user']['city'] != null){
        _preferences.cityId = decodedResponse['user']['city']['id'];
      }
      if(decodedResponse['user']['neighborhood'] != null){
        _preferences.neighborhoodId = decodedResponse['user']['neighborhood']['id'];
      }
      if(decodedResponse['user']['artist'] != null){
        _preferences.artistId = decodedResponse['user']['artist']['id'];
      }
      if(decodedResponse['user']['artist'] != null){
        _preferences.artistName = decodedResponse['user']['artist']['stage_name'];
      }
      if(decodedResponse['user']['artist'] != null){
        _preferences.artistPhoto = decodedResponse['user']['artist']['profile_image'];
      }
    }else{
      _preferences.token = null;
      _preferences.expireToken = null;
      _preferences.name = null;
      _preferences.email = null;
      _preferences.phone = null;
      _preferences.userId = null;
      _preferences.provinceId = null;
      _preferences.cityId = null;
      _preferences.neighborhoodId = null;
    }
  }

  void setPreferencesUserData(Map<String, dynamic> user){
    _preferences.name = user['user']['name'];
    _preferences.email = user['user']['email'];
    _preferences.phone = user['user']['phone'];
    _preferences.userId = user['user']['id'];
    _preferences.userTypeId= user['user']['user_type']['id'];
    _preferences.userType = user['user']['user_type']['name'];
    if(user['user']['province'] != null){
      _preferences.provinceId = user['user']['province']['id'];
    }
    if(user['user']['city'] != null){
      _preferences.cityId = user['user']['city']['id'];
    }
    if(user['user']['neighborhood'] != null){
      _preferences.neighborhoodId = user['user']['neighborhood']['id'];
    }
    if(user['user']['artist'] != null){
      _preferences.artistId = user['user']['artist']['id'];
    }
    if(user['user']['artist'] != null){
      _preferences.artistName = user['user']['artist']['stage_name'];
    }
    if(user['user']['artist'] != null){
      _preferences.artistPhoto = user['user']['artist']['profile_image'];
    }
  }
}