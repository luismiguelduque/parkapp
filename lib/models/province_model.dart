class ProvinceModel {
  
  ProvinceModel({
    this.id,
    this.name,
  });

  int id;
  String name;

  factory ProvinceModel.fromJson(Map<String, dynamic> json) => ProvinceModel(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}