class UserTypeModel {
  UserTypeModel({
    this.id,
    this.name,
    this.description,
  });

  int id;
  String name;
  String description;

  factory UserTypeModel.fromJson(Map<String, dynamic> json) => UserTypeModel(
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