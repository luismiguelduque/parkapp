import 'package:flutter/material.dart';

import '../utils/functions.dart';
import '../models/complaint_model.dart';
import '../models/image_model.dart';
import '../models/artist_model.dart';
import '../models/event_category_model.dart';
import '../models/place_model.dart';
import '../models/rating_model.dart';

class EventModel {
  EventModel({
    this.id,
    this.name,
    this.description,
    this.profileImage,
    this.coverImage,
    this.urlVideo,
    this.date,
    this.start,
    this.end,
    this.fullEnd,
    this.distance,
    this.duration,
    this.rating,
    this.scheduled,
    this.rated,
    this.scheduledCount,
    this.status,
    this.draft,
    this.placeComments,
    this.favoritesCount,
    this.place,
    this.artist,
    this.categories,
    this.images,
    this.ratings,
    this.complaints,
    this.complaintsCount,
    this.complained,
  });

  int id;
  String name;
  String description;
  String profileImage;
  String coverImage;
  String urlVideo;
  DateTime date;
  TimeOfDay start;
  TimeOfDay end;
  DateTime fullEnd;
  String distance;
  String duration;
  double rating;
  int scheduled;
  int rated;
  int scheduledCount;
  String status;
  String draft;
  String placeComments;
  int favoritesCount;
  PlaceModel place;
  ArtistModel artist;
  List<EventCategoryModel> categories;
  List<RatingModel> ratings;
  List<ComplaintModel> complaints;
  int complaintsCount;
  int complained;
  List<ImageModel> images;

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    profileImage: json["profile_image"],
    coverImage: json["cover_image"],
    urlVideo: json["url_video"],
    date: DateTime.parse(json["date"]),
    start: stringToTimeOfDay(json["start"]),
    end: stringToTimeOfDay(json["end"]),
    fullEnd: DateTime.parse(json["full_end"]),
    distance: json["distance"],
    duration: json["duration"],
    rating: double.parse(json["rating"].toString()),
    scheduled: json["scheduled"],
    rated: json["rated"],
    scheduledCount: json["scheduled_count"],
    status: json["status"],
    draft: json["draft"],
    placeComments: json["place_comments"],
    favoritesCount: json["favorites_count"],
    place: PlaceModel.fromJson(json["place"]),
    artist: json["artist"] != null ? ArtistModel.fromJson(json["artist"]) : null,
    categories: List<EventCategoryModel>.from(json["categories"].map((x) => EventCategoryModel.fromJson(x))),
    ratings: List<RatingModel>.from(json["ratings"].map((x) => RatingModel.fromJson(x))),
    complaints: List<ComplaintModel>.from(json["complaints"].map((x) => ComplaintModel.fromJson(x))),
    complaintsCount: json["complaints_count"],
    complained: json["complained"],
    images: List<ImageModel>.from(json["images"].map((x) => ImageModel.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "profile_image": profileImage,
    "cover_image": coverImage,
    "url_video": urlVideo,
    "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    "start": start,
    "end": end,
    "full_end": fullEnd,
    "distance": distance,
    "duration": duration,
    "rating": rating,
    "scheduled": scheduled,
    "rated": rated,
    "scheduled_count": scheduledCount,
    "status": status,
    "draft": draft,
    "place_comments": placeComments,
    "favorites_count": favoritesCount,
    "place": place.toJson(),
    "artist": artist.toJson(),
    "categories": List<EventCategoryModel>.from(categories.map((x) => x.toJson())),
    "ratings": List<RatingModel>.from(ratings.map((x) => x.toJson())),
    "complaints": List<ComplaintModel>.from(complaints.map((x) => x.toJson())),
    "complaints_count": complaintsCount,
    "complained": complained,
    "images": List<ImageModel>.from(images.map((x) => x.toJson())),
  };
}