import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

import '../models/artist_model.dart';
import '../models/artist_indicator_model.dart';
import '../utils/constants.dart';
import '../utils/preferences.dart';

class ArtistsProvider extends ChangeNotifier {

  Map<String, String> requestHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json'
  };
  final _preferences = new Preferences();

  List<ArtistModel> _artists = [];
  List<ArtistModel> get artists {
    return [..._artists];
  }

  List<ArtistModel> _artistsRequests = [];
  List<ArtistModel> get artistsRequests {
    return [..._artistsRequests];
  }

  List<ArtistModel> _artistsSuspensions = [];
  List<ArtistModel> get artistsSuspensions {
    return [..._artistsSuspensions];
  }
  
  List<ArtistModel> get artistsComplaints {
    return _artists.where((element) => element.complaintsCount > 0).toList();
  }

  ArtistModel _artistDetail;
  ArtistModel get artistDetail {
    return _artistDetail;
  }
  
  ArtistIndicatorModel _artistIndicators;
  ArtistIndicatorModel get artistIndicators {
    return _artistIndicators;
  }

  int adminArtistTotal = 0;
  int adminArtistTotalSuspensions = 0;
  int adminArtistTotalRequests = 0;

  Future<Map<String, dynamic>> store(ArtistModel artist, File profileImage, File coverImage) async {
    Map<String, dynamic> respJson = {};
    final url = '$apiUrl/artists';
    try{
      var postUri = Uri.parse(url);
      var request = new http.MultipartRequest("POST", postUri);
      request.headers['Content-type'] = 'application/json';
      request.headers['Accept'] = 'application/json';
      request.headers['Authorization'] = 'Bearer ${ _preferences.token }';
      request.fields['user_id'] =  _preferences.userId.toString();
      request.fields['stage_name'] =  artist.stageName.toString();
      request.fields['description'] =  artist.description.toString();
      request.fields['artistic_genre_id'] =  artist.artisticGenre.id.toString();
      request.fields['dni'] =  artist.dni.toString();
      if(artist.urlVideo != null){
        request.fields['url_video'] =  artist.urlVideo.toString();
      }
      if(profileImage != null){
        request.files.add(new http.MultipartFile.fromBytes('profile_image', await File.fromUri(Uri.parse(profileImage.path)).readAsBytes(), filename: basename(profileImage.path), contentType: new MediaType('image', 'jpeg')));
      }
      if(coverImage != null){
        request.files.add(new http.MultipartFile.fromBytes('cover_image', await File.fromUri(Uri.parse(coverImage.path)).readAsBytes(), filename: basename(coverImage.path), contentType: new MediaType('image', 'jpeg')));
      }
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
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
          respJson['message'] = decodedResponse['message'];
        }
      }
      return respJson;
    }catch(error){
      if(error['message'] == 'The given data was invalid'){
        final Map<String, dynamic> errors = error['errors'];
        errors.forEach((key, value) {
          respJson['success'] = false;
          respJson['message'] = value.toString();
        });
      }else{
        respJson['success'] = false;
        respJson['message'] = 'No pudimos procesar tu petición. Por favor, intenta mas tarde';
      }
      return respJson;
    }
  }

Future<Map<String, dynamic>> updateArtist(ArtistModel artist, File profileImage, File coverImage, int artistId) async {
    Map<String, dynamic> respJson = {};
    final url = '$apiUrl/artists/$artistId';
    try{
      var postUri = Uri.parse(url);
      var request = new http.MultipartRequest("POST", postUri);
      request.headers['Content-type'] = 'application/json';
      request.headers['Accept'] = 'application/json';
      request.headers['Authorization'] = 'Bearer ${ _preferences.token }';
      request.fields['user_id'] =  _preferences.userId.toString();
      request.fields['stage_name'] =  artist.stageName.toString();
      request.fields['description'] =  artist.description.toString();
      request.fields['artistic_genre_id'] =  artist.artisticGenre.id.toString();
      request.fields['dni'] =  artist.dni.toString();
      if(artist.urlVideo != null){
        request.fields['url_video'] = artist.urlVideo.toString();
      }
      if(profileImage != null){
        request.files.add(new http.MultipartFile.fromBytes('profile_image', await File.fromUri(Uri.parse(profileImage.path)).readAsBytes(), filename: basename(profileImage.path), contentType: new MediaType('image', 'jpeg')));
      }
      if(coverImage != null){
        request.files.add(new http.MultipartFile.fromBytes('cover_image', await File.fromUri(Uri.parse(coverImage.path)).readAsBytes(), filename: basename(coverImage.path), contentType: new MediaType('image', 'jpeg')));
      }
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final decodedResponse = json.decode(response.body) as Map<String, dynamic>;
      if (decodedResponse['success']) {
        respJson['success'] = true;
        respJson['message'] = 'Registro guardado exitosamente';
        _preferences.artistName = decodedResponse['data']['stage_name'];
        _preferences.artistPhoto = decodedResponse['data']['profile_image'];
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
      if(error['message'] == 'The given data was invalid'){
        final Map<String, dynamic> errors = error['errors'];
        errors.forEach((key, value) {
          respJson['success'] = false;
          respJson['message'] = value.toString();
        });
      }else{
        respJson['success'] = false;
        respJson['message'] = 'No pudimos procesar tu petición. Por favor, intenta mas tarde';
      }
      return respJson;
    }
  }


  Future<void> getArtists(String search, int offset, int limit,) async {
    final Uri uri = Uri.https(apiUrl, "/artists", {
      "search": search,
      "offset": offset,
      "limit": limit
    });
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
      final List<ArtistModel> tempItems = [];
      List artists = extractedData['data'];
      adminArtistTotal = extractedData['total'];
      if(offset > 0){
        artists.forEach((element) {
          _artists.add(ArtistModel.fromJson(element));
        });
      }else{
        artists.forEach((element) {
          tempItems.add(ArtistModel.fromJson(element));
        });
        _artists = tempItems;
      }
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
    }
  }

  Future<void> getArtistsAudience(String search, int offset, int limit,) async {
    final Uri uri = Uri.https(apiUrl, "/artists-audience", {
      "search": search,
      "offset": offset,
      "limit": limit
    });
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
      print("artistas extractedData");
      print(extractedData);
      final List<ArtistModel> tempItems = [];
      List artists = extractedData['data'];
      adminArtistTotal = extractedData['total'];
      if(offset > 0){
        artists.forEach((element) {
          _artists.add(ArtistModel.fromJson(element));
        });
      }else{
        artists.forEach((element) {
          tempItems.add(ArtistModel.fromJson(element));
        });
        _artists = tempItems;
      }
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
    }
  }

  Future<void> getArtistsRequests(String search, int offset, int limit,) async {
    final Uri uri = Uri.https(apiUrl, "/artists/requests", {
      "search": search,
      "offset": offset,
      "limit": limit
    });
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
      final List<ArtistModel> tempItems = [];
      List artists = extractedData['data'];
      adminArtistTotalRequests = extractedData['total'];
      if(offset > 0){
        artists.forEach((element) {
          _artistsRequests.add(ArtistModel.fromJson(element));
        });
      }else{
        artists.forEach((element) {
          tempItems.add(ArtistModel.fromJson(element));
        });
        _artistsRequests = tempItems;
      }
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
    }
  }

  Future<void> getArtistsSuspensions(String search, int offset, int limit,) async {
    final Uri uri = Uri.https(apiUrl, "/artists/suspensions", {
      "search": search,
    });
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
      final List<ArtistModel> tempItems = [];
      List artists = extractedData['data'];
      adminArtistTotalSuspensions = extractedData['total'];
      if(offset > 0){
        artists.forEach((element) {
          _artistsSuspensions.add(ArtistModel.fromJson(element));
        });
      }else{
        artists.forEach((element) {
          tempItems.add(ArtistModel.fromJson(element));
        });
        _artistsSuspensions = tempItems;
      }
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
    }
  }

  Future<Map<String, dynamic>> activateArtist(int artistId) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "artists/activate/$artistId", {});
    try {
      final response = await http.post(
        uri, 
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_preferences.token}',
        }
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

  Future<Map<String, dynamic>> rejectArtist(int artistId) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "/artists/reject/$artistId", {});
    try {
      final response = await http.post(
        uri, 
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_preferences.token}',
        }
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

  Future<void> getArtistDetail(int id) async {
    final Uri uri = Uri.https(apiUrl, "/artists/$id", {});
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
      _artistDetail = ArtistModel.fromJson(extractedData['data']);
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
    }
  }
  
  Future<void> getArtistIndicators() async {
    final Uri uri = Uri.https(apiUrl, "/indicators/artists", {});
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
      _artistIndicators = ArtistIndicatorModel.fromJson(extractedData['data']);
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
    }
  }

  Future<Map<String, dynamic>> suspendArtist(int artistId) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "/artists/suspend/$artistId", {});
    try {
      final response = await http.put(
        uri, 
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_preferences.token}',
        },
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

  Future<Map<String, dynamic>> reactivateArtist(int artistId) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "/artists/reactivate/$artistId", {});
    try {
      final response = await http.put(
        uri, 
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_preferences.token}',
        },
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

  Future<Map<String, dynamic>> deleteArtist(int artistId) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "/artists/delete/$artistId", {});
    try {
      final response = await http.delete(
        uri, 
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_preferences.token}',
        },
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

  Future<Map<String, dynamic>> reportArtist(int eventId, String reason) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "/artists_complaint", {});
    try {
      final response = await http.post(
        uri, 
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_preferences.token}',
        },
        body: json.encode({
            'user_id': _preferences.userId,
          'artist_id': eventId,
          'reason': reason,
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

  Future<Map<String, dynamic>> followArtist(int artistId) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "/artists/follow", {});
    try {
      final response = await http.post(
        uri, 
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_preferences.token}',
        },
        body: json.encode({
          'artist_id': artistId,
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

  Future<Map<String, dynamic>> unFollowArtist(int artistId) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "/artists/unfollow", {});
    try {
      final response = await http.post(
        uri, 
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_preferences.token}',
        },
        body: json.encode({
          'artist_id': artistId,
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

  Future<Map<String, dynamic>> rateArtist(int artistId, String observation, double rating) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "/artists/add-user-rating", {});
    try {
      final response = await http.post(
        uri, 
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_preferences.token}',
        },
        body: json.encode({
          'artist_id': artistId,
          'description': observation,
          'rating': rating,
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
}