class ArtistIndicatorModel {
  ArtistIndicatorModel({
    this.rating,
    this.countEvents,
    this.countRatings,
    this.countComplaints,
    this.countScheduled,
  });

  double rating;
  int countEvents;
  int countRatings;
  int countComplaints;
  int countScheduled;

  factory ArtistIndicatorModel.fromJson(Map<String, dynamic> json) => ArtistIndicatorModel(
    rating: double.parse(json["rating"].toString()) ?? 0,
    countEvents: json["count_events"] ?? 0,
    countRatings: json["count_ratings"] ?? 0,
    countComplaints: json["count_complaints"] ?? 0,
    countScheduled: json["count_scheduled"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "rating": rating,
    "count_events": countEvents,
    "count_ratings": countRatings,
    "count_complaints": countComplaints,
    "count_scheduled": countScheduled,
  };
}