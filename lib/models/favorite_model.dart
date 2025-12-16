class FavoriteModel {
  final int? id;
  final int userId;
  final int courseId;
  final String createdAt;

  FavoriteModel({
    this.id,
    required this.userId,
    required this.courseId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'created_at': createdAt,
    };
  }

  factory FavoriteModel.fromMap(Map<String, dynamic> map) {
    return FavoriteModel(
      id: map['id'],
      userId: map['user_id'] ?? 0,
      courseId: map['course_id'] ?? 0,
      createdAt: map['created_at'] ?? '',
    );
  }
}
