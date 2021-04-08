import '../models/neighborhood_model.dart';

class PlaceModel {
  PlaceModel({
    this.id,
    this.name,
    this.description,
    this.address,
    this.lat,
    this.long,
    this.dailyLimit,
    this.restricted,
    this.retrictionStart,
    this.retrictionEnd,
    this.status,
    this.neighborhood,
  });

  int id;
  String name;
  String description;
  String address;
  String lat;
  String long;
  int dailyLimit;
  String restricted;
  dynamic retrictionStart;
  dynamic retrictionEnd;
  String status;
  NeighborhoodModel neighborhood;

  factory PlaceModel.fromJson(Map<String, dynamic> json) => PlaceModel(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    address: json["address"],
    lat: json["lat"],
    long: json["long"],
    dailyLimit: json["daily_limit"],
    restricted: json["restricted"],
    retrictionStart: json["retriction_start"],
    retrictionEnd: json["retriction_end"],
    status: json["status"],
    neighborhood: NeighborhoodModel.fromJson(json["neighborhood"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "address": address,
    "lat": lat,
    "long": long,
    "daily_limit": dailyLimit,
    "restricted": restricted,
    "retriction_start": retrictionStart,
    "retriction_end": retrictionEnd,
    "status": status,
    "neighborhood": neighborhood.toJson(),
  };
}