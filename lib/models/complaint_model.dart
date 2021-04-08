class ComplaintModel {
  ComplaintModel({
    this.id,
    this.userId,
    this.reason,
  });

  int id;
  int userId;
  String reason;

  factory ComplaintModel.fromJson(Map<String, dynamic> json) => ComplaintModel(
    id: json["id"],
    userId: json["user_id"],
    reason: json["reason"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "reason": reason,
  };
}