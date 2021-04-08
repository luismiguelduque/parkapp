class RatingModel {
  RatingModel({
    this.id,
    this.rating,
    this.description,
  });

  int id;
  int rating;
  dynamic description;

  factory RatingModel.fromJson(Map<String, dynamic> json) => RatingModel(
    id: json["id"],
    rating: json["rating"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "rating": rating,
    "description": description,
  };
}