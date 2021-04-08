class ImageModel {
  ImageModel({
    this.id,
    this.image,
    this.url,
  });

  int id;
  String image;
  String url;

  factory ImageModel.fromJson(Map<String, dynamic> json) => ImageModel(
    id: json["id"],
    image: json["image"],
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image": image,
    "url": url,
  };
}