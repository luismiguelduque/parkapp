class NeighborhoodModel {
  
  NeighborhoodModel({
    this.id,
    this.name,
  });

  int id;
  String name;

  factory NeighborhoodModel.fromJson(Map<String, dynamic> json) => NeighborhoodModel(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}