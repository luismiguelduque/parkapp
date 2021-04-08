import 'package:parkapp/models/user_model.dart';

class ConversationModel {
  ConversationModel({
    this.id,
    this.conversationId,
    this.lastMessage,
    this.user,
    this.unreadAdmin,
    this.unreadUser,
  });

  int id;
  String conversationId;
  String lastMessage;
  UserModel user;
  String unreadAdmin;
  String unreadUser;

  factory ConversationModel.fromJson(Map<String, dynamic> json) => ConversationModel(
    id: json["id"],
    conversationId: json["conversation_id"],
    lastMessage: json["last_message"],
    user: UserModel.fromJson(json["user"]),
    unreadAdmin: json["unread_admin"],
    unreadUser: json["unread_user"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "conversation_id": conversationId,
    "last_message": lastMessage,
    "user": user.toJson(),
    "unread_admin": unreadAdmin,
    "unread_user": unreadUser,
  };
}