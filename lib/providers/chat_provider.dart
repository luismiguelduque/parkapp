import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';
import '../utils/preferences.dart';
import '../models/conversation_model.dart';

class ChatProvider extends ChangeNotifier {

  final _preferences = new Preferences();

  int adminConversationsUserTotal;
  int adminConversationsArtistTotal;

  List<ConversationModel> _adminAllConversations= [];
  List<ConversationModel> get adminAllConversations {
    return [..._adminAllConversations];
  }
  List<ConversationModel> _adminConversations= [];
  List<ConversationModel> get adminConversations {
    return [..._adminConversations];
  }
  List<ConversationModel> _adminConversationsArtists = [];
  List<ConversationModel> get adminConversationsArtists {
    return [..._adminConversationsArtists];
  }
  List<ConversationModel> _adminConversationsUsers = [];
  List<ConversationModel> get adminConversationsUsers {
    return [..._adminConversationsUsers];
  }
  ConversationModel _userConversation = new ConversationModel();
  ConversationModel get userConversation {
    return _userConversation;
  }

  Future<void> getAdminAllConversation() async {
    
    try {
      final Uri uri =developmentMode ? Uri.https(apiUrl, "api/conversations", {
        "offset": "0",
        "limit": "1000"
      }) : Uri.http(apiUrl, "api/conversations", {
        "offset": "0",
        "limit": "1000"
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
      List conversations = extractedData['data'];
      final List<ConversationModel> tempItems = [];
      adminConversationsArtistTotal = extractedData['total'];
      conversations.forEach((element) {
        tempItems.add(ConversationModel.fromJson(element));
      });
      _adminAllConversations = tempItems;
      
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
    }
  }

  Future<void> getAdminConversation(String search, int offset, int limit, int userType) async {
    
    try {
      final Uri uri =developmentMode ? Uri.https(apiUrl, "api/conversations", {
        "search": "$search",
        "offset": "$offset",
        "limit": "$limit",
        "user_type": "$userType"
      }) : Uri.http(apiUrl, "api/conversations", {
        "search": "$search",
        "offset": "$offset",
        "limit": "$limit",
        "user_type": "$userType"
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
      List conversations = extractedData['data'];
      final List<ConversationModel> tempItems = [];
      if(userType == 1){
        adminConversationsUserTotal = extractedData['total'];
        if (offset > 0) {
          conversations.forEach((element) {
            _adminConversationsUsers.add(ConversationModel.fromJson(element));
          });
        } else {
          conversations.forEach((element) {
            tempItems.add(ConversationModel.fromJson(element));
          });
          _adminConversationsUsers = tempItems;
        }
      } else if(userType == 2) {
        adminConversationsArtistTotal = extractedData['total'];
        if (offset > 0) {
          conversations.forEach((element) {
            _adminConversationsArtists.add(ConversationModel.fromJson(element));
          });
        } else {
          conversations.forEach((element) {
            tempItems.add(ConversationModel.fromJson(element));
          });
          _adminConversationsArtists = tempItems;
        }
      }
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
    }
  }

  Future<void> getUserConversation() async {
    final Uri uri =developmentMode ? Uri.https(apiUrl, "api/conversations/user-session", {}) : Uri.http(apiUrl, "api/conversations/user-session", {});
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
      print("extractedData getUserConversation --");
      print(extractedData);
      List conversations = extractedData['data'];
      print(conversations.length);
      if(conversations.length > 0){
        _userConversation = ConversationModel.fromJson(extractedData['data'][0]);
      }else{
        _userConversation = new ConversationModel();
      }
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
    }
  }

  Future<Map<String, dynamic>> storeConversation(String conversationId) async {
    Map<String, dynamic> respJson = {};
    final Uri uri =developmentMode ? Uri.https(apiUrl, "api/conversations", {}) : Uri.http(apiUrl, "api/conversations", {});
    try {
      final response = await http.post(uri, headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${_preferences.token}',
      },
      body: json.encode({
        'conversation_id': conversationId,
      }),
      );
      final decodedResponse = json.decode(response.body) as Map<String, dynamic>;
      print("decodedResponse");
      print(decodedResponse);
      if (decodedResponse['success']) {
        respJson['success'] = true;
        respJson['message'] = decodedResponse['message'];
        respJson['id'] = decodedResponse['data']['id'];
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

  Future<Map<String, dynamic>> updateLastMessage(int conversationId, String message, int sender, int receiver) async {
    Map<String, dynamic> respJson = {};
    final bool isAdmin = _preferences.userTypeId == 3;
    final Uri uri =developmentMode ? Uri.https(apiUrl, "api/conversations/last-message", {}) : Uri.http(apiUrl, "api/conversations/last-message", {});
    try {
      final response = await http.post(
        uri, 
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_preferences.token}',
        },
        body: json.encode({
          'id': conversationId,
          'sender_user_id': sender,
          if(receiver != null) 'receiver_user_id': receiver,
          'message': message,
          'unread_user': isAdmin ? 1 : 2,
          'unread_admin': isAdmin ? 2 : 1,
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

  Future<Map<String, dynamic>> setRead(int conversationId) async {
    Map<String, dynamic> respJson = {}; 
    final Uri uri =developmentMode ? Uri.https(apiUrl, "api/conversations/read-messages", {
      "id": "$conversationId"
    }) : Uri.http(apiUrl, "api/conversations/read-messages", {
      "id": "$conversationId"
    });
    print(uri);
    try {
      final response = await http.get(
        uri, 
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_preferences.token}',
        }
      );
      final decodedResponse = json.decode(response.body) as Map<String, dynamic>;
      print("setRead");
      print(decodedResponse);
      if (decodedResponse['success']) {
        respJson['success'] = true;
        respJson['message'] = decodedResponse['message'];
        respJson['id'] = decodedResponse['data']['id'];
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