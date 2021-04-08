class CityModel {
  CityModel({
    this.id,
    this.name,
  });

  int id;
  String name;

  factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}