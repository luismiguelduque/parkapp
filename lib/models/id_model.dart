class IdModel {
  IdModel({
    this.id,
  });

  int id;

  factory IdModel.fromJson(Map<String, dynamic> json) => IdModel(
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
  };
}