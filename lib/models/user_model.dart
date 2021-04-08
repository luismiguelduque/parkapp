import '../models/artist_model.dart';
import '../models/user_type_model.dart';

class UserModel {
  UserModel({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.userType,
    this.province,
    this.city,
    this.neighborhood,
    this.artist,
  });

  int id;
  String name;
  String password;
  String phone;
  String email;
  UserTypeModel userType;
  dynamic province;
  dynamic city;
  dynamic neighborhood;
  ArtistModel artist;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"],
    name: json["name"],
    phone: json["phone"],
    email: json["email"],
    userType: UserTypeModel.fromJson(json["user_type"]),
    province: json["province"],
    city: json["city"],
    neighborhood: json["neighborhood"],
    artist: json["artist"] != null ? ArtistModel.fromJson(json["artist"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "email": email,
    "user_type": userType.toJson(),
    "province": province,
    "city": city,
    "neighborhood": neighborhood,
    "artist": artist.toJson(),
  };
}