class EnrollmentModel {
  final int? id;
  final int userId;
  final int courseId;
  final String enrolledAt;
  final String? completedAt;
  final int progress; // 0-100
  final String status; // 'active', 'completed', 'dropped'

  EnrollmentModel({
    this.id,
    required this.userId,
    required this.courseId,
    required this.enrolledAt,
    this.completedAt,
    this.progress = 0,
    this.status = 'active',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'enrolled_at': enrolledAt,
      'completed_at': completedAt,
      'progress': progress,
      'status': status,
    };
  }

  factory EnrollmentModel.fromMap(Map<String, dynamic> map) {
    return EnrollmentModel(
      id: map['id'],
      userId: map['user_id'] ?? 0,
      courseId: map['course_id'] ?? 0,
      enrolledAt: map['enrolled_at'] ?? '',
      completedAt: map['completed_at'],
      progress: map['progress'] ?? 0,
      status: map['status'] ?? 'active',
    );
  }

  EnrollmentModel copyWith({
    int? id,
    int? userId,
    int? courseId,
    String? enrolledAt,
    String? completedAt,
    int? progress,
    String? status,
  }) {
    return EnrollmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      completedAt: completedAt ?? this.completedAt,
      progress: progress ?? this.progress,
      status: status ?? this.status,
    );
  }
}
