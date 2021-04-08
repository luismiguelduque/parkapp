import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:parkapp/utils/preferences.dart';

class ApiService {

  final _preferences = new Preferences();

  Future<Map<String, dynamic>> getRequest({@required Uri uri, @required Map<String, dynamic> data}) async { 
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_preferences.token}',
        },
        body: json.encode(data),
      );
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      return extractedData;
    } catch (error) {
      print(error);
      return {'success':false, 'message': 'han error has ocurred'};
    }
  }

  Future<Map<String, dynamic>> postRequest({@required Uri uri, @required Map<String, dynamic> data}) async { 
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_preferences.token}',
        },
        body: json.encode(data),
      );
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      return extractedData;
    } catch (error) {
      print(error);
      return {'success':false, 'message': 'han error has ocurred'};
    }
  }
}