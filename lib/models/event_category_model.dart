class EventCategoryModel {
  EventCategoryModel({
    this.id,
    this.name,
  });

  int id;
  String name;

  factory EventCategoryModel.fromJson(Map<String, dynamic> json) => EventCategoryModel(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}