class ArtisticGenreModel {
  ArtisticGenreModel({
    this.id,
    this.name,
    this.description,
  });

  int id;
  String name;
  String description;

  factory ArtisticGenreModel.fromJson(Map<String, dynamic> json) => ArtisticGenreModel(
    id: json["id"],
    name: json["name"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
  };
}