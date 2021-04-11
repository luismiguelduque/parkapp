import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

import '../utils/preferences.dart';
import '../utils/constants.dart';
import '../models/event_model.dart';

class EventsProvider extends ChangeNotifier {

  Map<String, String> requestHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json'
  };
  final _preferences = new Preferences();
  
  List<EventModel> _artistEvents = [];
  List<EventModel> get artistEvents {
    return [..._artistEvents.where((item) => item.draft == "2").toList()];
  }

  List<EventModel> get artistEventsDraft {
    return _artistEvents.where((item) => item.draft == "1").toList();
  }

  int get artistEventsAmount {
    return _artistEvents.length;
  }

  List<EventModel> _audienceEventsClose = [];
  List<EventModel> get audienceEventsClose {
    return [..._audienceEventsClose];
  }

  List<EventModel> _audienceEventsNow = [];
  List<EventModel> get audienceEventsNow {
    return [..._audienceEventsNow];
  }

  List<EventModel> _audienceEventsWeekend = [];
  List<EventModel> get audienceEventsWeekend {
    return [..._audienceEventsWeekend];
  }

  List<EventModel> _audienceEventsAll = [];
  List<EventModel> get audienceEventsAll {
    return [..._audienceEventsAll];
  }

  List<EventModel> _adminEventsAll = [];
  List<EventModel> get adminEventsAll {
    return [..._adminEventsAll];
  }

  List<EventModel> _adminEventsPending = [];
  List<EventModel> get adminEventsPending {
    return [..._adminEventsPending];
  }

  List<EventModel> _adminEventsComplaints = [];
  List<EventModel> get adminEventsComplaints {
    return [..._adminEventsComplaints];
  }

  EventModel _eventDetail;
  EventModel get eventDetail {
    return _eventDetail;
  }
  
  set eventDetail(value) {
    _eventDetail = value;
  }

  List<EventModel> _scheduledEvents;
  List<EventModel> get scheduledEvents{
    DateTime _now = DateTime.now();
    if(sheduledActiveOnly){
      return _scheduledEvents.where((e){ 
        //DateTime _dateEvent = DateTime(e.date.year, e.date.month, e.date.day, e.end.hour, e.end.minute);
        return _now.isBefore(e.fullEnd);
      }).toList();
    }
    return [..._scheduledEvents];
  }
  bool sheduledActiveOnly = true;

  int audienceAllEventstotalItems = 0;
  int adminEventsAllTotal = 0;
  int adminEventsPendingTotal = 0;
  int adminEventsComplaintsTotal = 0;
  
  Future<void> getArtistEvents() async {
    final Uri uri = Uri.https(apiUrl, "api/events/artist/${_preferences.artistId}", {});
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
      final List<EventModel> tempItems = [];
      List events = extractedData['data'];
      events.forEach((element) {
        tempItems.add(EventModel.fromJson(element));
      });
      _artistEvents = tempItems;
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
    }
  }

  Future<void> getAudienceEventsClose() async {
    final Uri uri = Uri.https(apiUrl, "api/events/audience/close", {});
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
      print("getAudienceEventsClose");
      print(extractedData);
      final List<EventModel> tempItems = [];
      List events = extractedData['data'];
      events.forEach((element) {
        tempItems.add(EventModel.fromJson(element));
      });
      _audienceEventsClose = tempItems;
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
    }
  }

  Future<void> getAudienceEventsNow() async {
    final Uri uri = Uri.https(apiUrl, "api/events/audience/now", {});
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
      final List<EventModel> tempItems = [];
      List events = extractedData['data'];
      events.forEach((element) {
        tempItems.add(EventModel.fromJson(element));
      });
      _audienceEventsNow = tempItems;
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
    }
  }

  Future<void> getAudienceEventsWeekend() async {
    final Uri uri = Uri.https(apiUrl, "api/events/audience/weekend", {});
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
      final List<EventModel> tempItems = [];
      List events = extractedData['data'];
      events.forEach((element) {
        tempItems.add(EventModel.fromJson(element));
      });
      _audienceEventsWeekend = tempItems;
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
    }
  }

  Future<void> getAudienceEventsAll({offset, limit, search, fromDate, toDate, fromTime, toTime, neighborhoods, artists, rating, categories, distance}) async {
    if(fromDate != null) fromDate = fromDate.toString().split(" ")[0];
    if(toDate != null) toDate = toDate.toString().split(" ")[0];
    if(fromTime != null) fromTime = "${fromTime.hour}:${fromTime.minute}";
    if(toTime != null) toTime = "${toTime.hour}:${toTime.minute}";
    //var url = "$apiUrl/events/audience/all?offset=$offset&limit=$limit&fromDate=$fromDate&toDate=$toDate&fromTime=$fromTime&toTime=$toTime&neighborhoods=$neighborhoods&artists=$artists&rating=$rating&categories=$categories&distance=$distance";
    final Uri uri = Uri.https(apiUrl, "api/artists", {
      "search": search==null?"":search,
      "offset": "$offset",
      "limit": "$limit",
      "fromDate": "$fromDate",
      "toDate": "$toDate",
      "fromTime": "$fromTime",
      "toTime": "$toTime",
      "neighborhoods": "$neighborhoods",
      "artists": "$artists",
      "rating": "$rating",
      "categories": "$categories",
      "distance": "$distance"
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
      final List<EventModel> tempItems = [];
      List events = extractedData['data'];
      if(offset > 0){
        events.forEach((element) {
          _audienceEventsAll.add(EventModel.fromJson(element));
        });
      }else{
        events.forEach((element) {
          tempItems.add(EventModel.fromJson(element));
        });
        _audienceEventsAll = tempItems; 
      }
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
    }
  }

  Future<void> getAdminEventsAll({int offset, int limit, String search}) async {
    try {
      final uri = Uri.https(apiUrl, 'api/events/admin', {
        "search": search==null?"":search,
        "offset": "$offset",
        "limit": "$limit"
      });
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
      print("extractedData getAdminEventsAll");
      print(extractedData);
      final List<EventModel> tempItems = [];
      List events = extractedData['data'];
      adminEventsAllTotal = extractedData['total'];
      if(offset > 0){
        events.forEach((element) {
          _adminEventsAll.add(EventModel.fromJson(element));
        });
      }else{
        events.forEach((element) {
          tempItems.add(EventModel.fromJson(element));
        });
        _adminEventsAll = tempItems;
      }
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
    }
  }

  Future<void> getAdminEventsPending({int offset, int limit, String search}) async {
    try {
      final Uri uri = Uri.https(apiUrl, "api/events/admin", {
        "search": search==null?"":search,
        "offset": "$offset",
        "limit": "$limit",
        "pending": "true",
      });
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
      print("extractedData getAdminEventsPending");
      print(extractedData);
      final List<EventModel> tempItems = [];
      List events = extractedData['data'];
      adminEventsPendingTotal = extractedData['total'];
      if(offset > 0){
        events.forEach((element) {
          _adminEventsPending.add(EventModel.fromJson(element));
        });
      }else{
        events.forEach((element) {
          tempItems.add(EventModel.fromJson(element));
        });
        _adminEventsPending = tempItems;
      }
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
    }
  }

  Future<void> getAdminEventsComplained({int offset, int limit, String search}) async {
    
    try {
      final Uri uri = Uri.https(apiUrl, "api/events/admin", {
        "search": search==null?"":search,
        "offset": "$offset",
        "limit": "$limit",
        "denounced": "true",
      });
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
      print("extractedData getAdminEventsComplained");
      print(extractedData);
      final List<EventModel> tempItems = [];
      List events = extractedData['data'];
      adminEventsComplaintsTotal = extractedData['total'];
      if(offset > 0){
        events.forEach((element) {
          _adminEventsComplaints.add(EventModel.fromJson(element));
        });
      }else{
        events.forEach((element) {
          tempItems.add(EventModel.fromJson(element));
        });
        _adminEventsComplaints = tempItems;
      }
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
    }
  }

  Future<void> getEventDetail(int id) async {
    final Uri uri = Uri.https(apiUrl, "api/events/$id", {});
    try {
      final response = await http.get(uri, headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${_preferences.token}',
      });
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      print("extractedData getEventDetail");
      print(extractedData);
      if (extractedData == null) {
        return;
      }
      _eventDetail = EventModel.fromJson(extractedData['data']);
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
    }
  }

  Future<Map<String, dynamic>> store(EventModel event, File profileImage, File coverImage, List<int> categories, List<File> images) async {
    final url = "https://$apiUrl/api/events";
    Map<String, dynamic> respJson = {};
    try{
      var postUri = Uri.parse(url);
      var request = new http.MultipartRequest("POST", postUri);
      request.headers['Content-type'] = 'application/json';
      request.headers['Accept'] = 'application/json';
      request.headers['Authorization'] = 'Bearer ${ _preferences.token }';
      request.fields['artist_id'] =  _preferences.artistId.toString();
      request.fields['place_id'] =  event.place.id.toString();
      request.fields['name'] =  event.name;
      request.fields['date'] =  event.date.toString().split(" ")[0];
      request.fields['start'] =  "${event.start.hour}:${event.start.minute}";
      request.fields['end'] =  "${event.end.hour}:${event.end.minute}";
      request.fields['user_id'] =  _preferences.userId.toString();
      request.fields['description'] =  event.description.toString();
      if(event.place.restricted == "1"){
        request.fields['status'] =  "2";
      }else{
        request.fields['status'] =  "1";
      }
      request.fields['draft'] =  event.draft;
      request.fields['categories'] = categories.map((i) => i.toString()).join(",");
      if(event.placeComments != null){
        request.fields['place_comments'] =  event.placeComments;
      }
      if(event.urlVideo != null){
        request.fields['url_video'] =  event.urlVideo.toString();
      }
      request.files.add(new http.MultipartFile.fromBytes('profile_image', await File.fromUri(Uri.parse(profileImage.path)).readAsBytes(), filename: basename(profileImage.path), contentType: new MediaType('image', 'jpeg')));
      request.files.add(new http.MultipartFile.fromBytes('cover_image', await File.fromUri(Uri.parse(coverImage.path)).readAsBytes(), filename: basename(coverImage.path), contentType: new MediaType('image', 'jpeg')));
      for(var i=0; i<images.length; i++){
        request.files.add(new http.MultipartFile.fromBytes('images[]', await File.fromUri(Uri.parse(images[i].path)).readAsBytes(), filename: basename(images[i].path), contentType: new MediaType('image', 'jpeg')));
      }
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final decodedResponse = json.decode(response.body) as Map<String, dynamic>;
      print("decodedResponse"); 
      print(decodedResponse);
      if (decodedResponse['success']) {
        respJson['success'] = true;
        respJson['message'] = 'Registro guardado exitosamente';
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

  Future<Map<String, dynamic>> updateEvent(EventModel event, File profileImage, File coverImage, List<int> categories, int eventId, List<File> images) async {
    final url = "https://$apiUrl/api/events/$eventId";
    Map<String, dynamic> respJson = {};
    try{
      var postUri = Uri.parse(url);
      var request = new http.MultipartRequest("POST", postUri);
      request.headers['Content-type'] = 'application/json';
      request.headers['Accept'] = 'application/json';
      request.headers['Authorization'] = 'Bearer ${ _preferences.token }';
      request.fields['artist_id'] =  _preferences.artistId.toString();
      request.fields['place_id'] =  event.place.id.toString();
      request.fields['name'] =  event.name;
      request.fields['date'] =  event.date.toString().split(" ")[0];
      request.fields['start'] =  "${event.start.hour}:${event.start.minute}:00";
      request.fields['end'] =  "${event.end.hour}:${event.end.minute}:00";
      request.fields['user_id'] =  _preferences.userId.toString();
      request.fields['description'] =  event.description.toString();
      if(event.place.restricted == "1"){
        request.fields['status'] =  "2";
      }else{
        request.fields['status'] =  "1";
      }
      request.fields['draft'] =  event.draft;
      request.fields['categories'] = categories.map((i) => i.toString()).join(",");
      if(profileImage != null){
        request.files.add(new http.MultipartFile.fromBytes('profile_image', await File.fromUri(Uri.parse(profileImage.path)).readAsBytes(), filename: basename(profileImage.path), contentType: new MediaType('image', 'jpeg')));
      }
      if(coverImage != null){
        request.files.add(new http.MultipartFile.fromBytes('cover_image', await File.fromUri(Uri.parse(coverImage.path)).readAsBytes(), filename: basename(coverImage.path), contentType: new MediaType('image', 'jpeg')));
      }
      for(var i=0; i<images.length; i++){
        request.files.add(new http.MultipartFile.fromBytes('images[]', await File.fromUri(Uri.parse(images[i].path)).readAsBytes(), filename: basename(images[i].path), contentType: new MediaType('image', 'jpeg')));
      }
      if(event.placeComments != null) {
        request.fields['place_comments'] =  event.placeComments;
      }
      if(event.urlVideo != null) {
        request.fields['url_video'] =  event.urlVideo.toString();
      }
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final decodedResponse = json.decode(response.body) as Map<String, dynamic>;
      print("decodedResponse"); 
      print(decodedResponse);
      if (decodedResponse['success']) {
        respJson['success'] = true;
        respJson['message'] = 'Registro guardado exitosamente';
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

  Future<Map<String, dynamic>> deleteEvent(int eventId) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "api/events/$eventId", {});
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
  
  Future<Map<String, dynamic>> deleteEventImage(int eventId) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "api/events/delete-image/$eventId", {});
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

  Future<Map<String, dynamic>> publicateEvent(int eventId) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "api/events/publicate/$eventId", {});
    try {
      final response = await http.post(uri, headers: {
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

  Future<Map<String, dynamic>> scheduleEvent(int eventId, int userId) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "api/events/schedule", {});
    try {
      final response = await http.post(
        uri, 
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_preferences.token}',
        },
        body: json.encode({
          'event_id': eventId,
          'user_id': userId,
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

  Future<Map<String, dynamic>> unScheduleEvent(int eventId) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "api/events/cancel-schedule", {});
    try {
      final response = await http.post(
        uri, 
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_preferences.token}',
        },
        body: json.encode({
          'event_id': eventId,
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

  Future<void> getUserSheduledEvent() async {
    final Uri uri = Uri.https(apiUrl, "api/users/sheduled-events", {});
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
      final List<EventModel> tempItems = [];
      List events = extractedData['data'];
      events.forEach((element) {
        tempItems.add(EventModel.fromJson(element));
      });
      _scheduledEvents = tempItems;
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
    }
  }

  Future<Map<String, dynamic>> blockEvent(int eventId) async {
    final Uri uri = Uri.https(apiUrl, "api/events/block/$eventId", {});
    Map<String, dynamic> respJson = {};
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

  Future<Map<String, dynamic>> rateEvent(int eventId, String observation, double rating) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "api/events/add-user-rating", {});
    try {
      final response = await http.post(
        uri, 
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_preferences.token}',
        },
        body: json.encode({
          'event_id': eventId,
          'description': observation,
          'rating': rating,
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

  Future<Map<String, dynamic>> reportEvent(int eventId, String reason) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "api/complaints/events", {});
    try {
      final response = await http.post(
        uri, 
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_preferences.token}',
        },
        body: json.encode({
          'event_id': eventId,
          'reason': reason,
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

  Future<Map<String, dynamic>> unBlockEvent(int eventId) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "api/events/unblock/$eventId", {});
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

  Future<Map<String, dynamic>> storeEventCategory(String description) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "api/events/publicate", {});
    try {
      final response = await http.post(uri, headers: {
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

  Future<Map<String, dynamic>> deleteCategoryEvent(int eventId) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "api/events/$eventId", {});
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

  Future<Map<String, dynamic>> updateCategoryEvent(int eventId, String description) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "api/events/block/$eventId", {});
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

  Future<Map<String, dynamic>> activateEvent(int eventId) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "api/events/activate/$eventId", {});
    try {
      final response = await http.post(uri, headers: {
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

  Future<Map<String, dynamic>> rejectEvent(int eventId) async {
    Map<String, dynamic> respJson = {};
    final Uri uri = Uri.https(apiUrl, "api/events/reject/$eventId", {});
    try {
      final response = await http.post(uri, headers: {
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