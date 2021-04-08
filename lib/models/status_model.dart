class StatusModel {
  StatusModel({
    this.id,
    this.name,
    this.description,
  });

  int id;
  String name;
  String description;

  factory StatusModel.fromJson(Map<String, dynamic> json) => StatusModel(
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