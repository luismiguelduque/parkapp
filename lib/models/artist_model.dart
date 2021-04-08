import '../models/artistic_genres_model.dart';
import '../models/city_model.dart';
import '../models/complaint_model.dart';
import '../models/image_model.dart';

class ArtistModel {
  ArtistModel({
    this.id,
    this.userId,
    this.dni,
    this.stageName,
    this.description,
    this.profileImage,
    this.coverImage,
    this.urlVideo,
    this.status,
    this.requestDate,
    this.artisticGenre,
    this.city,
    this.followersCount,
    this.rating,
    this.complaints,
    this.complaintsCount,
    this.complained,
    this.rated,
    this.followed,
    this.images,
  });

  int id;
  int userId;
  String dni;
  String stageName;
  String description;
  String profileImage;
  String coverImage;
  String urlVideo;
  String status;
  DateTime requestDate;
  ArtisticGenreModel artisticGenre;
  CityModel city;
  int followersCount;
  double rating;
  List<ComplaintModel> complaints;
  int complaintsCount;
  int complained;
  int rated;
  int followed;
  List<dynamic> images;

  factory ArtistModel.fromJson(Map<String, dynamic> json) => ArtistModel(
    id: json["id"],
    userId: json["user_id"],
    dni: json["dni"],
    stageName: json["stage_name"],
    description: json["description"],
    profileImage: json["profile_image"],
    coverImage: json["cover_image"],
    urlVideo: json["url_video"],
    status: json["status"],
    requestDate: DateTime.parse(json["request_date"]),
    artisticGenre: json["artistic_genre"] != null ? ArtisticGenreModel.fromJson(json["artistic_genre"]) : null,
    city: CityModel.fromJson(json["city"]),
    followersCount: json["followers_count"],
    rating: double.parse(json["rating"].toString()),
    complaints: List<ComplaintModel>.from(json["complaints"].map((x) => ComplaintModel.fromJson(x))),
    complaintsCount: json["complaints_count"],
    complained: json["complained"],
    rated: json["rated"],
    followed: json["followed"],
    images: json["images"].length > 0 ? List<ImageModel>.from(json["images"].map((x) => ImageModel.fromJson(x))) : [],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "dni": dni,
    "stage_name": stageName,
    "description": description,
    "profile_image": profileImage,
    "cover_image": coverImage,
    "url_video": urlVideo,
    "status": status,
    "request_date": requestDate.toIso8601String(),
    "artistic_genre": artisticGenre.toJson(),
    "city": city.toJson(),
    "followers_count": followersCount,
    "rating": rating,
    "complaints": List<ComplaintModel>.from(complaints.map((x) => x.toJson())),
    "complaints_count": complaintsCount,
    "complained": complained,
    "images": List<ImageModel>.from(images.map((x) => x.toJson())),
  };
}