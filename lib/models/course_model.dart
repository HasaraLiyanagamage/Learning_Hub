class CourseModel {
  final int? id;
  final String title;
  final String description;
  final String? thumbnail;
  final String? thumbnailUrl;
  final String instructor;
  final String category;
  final String difficulty;
  final String level;
  final String duration;
  final int lessonsCount;
  final int enrolledCount;
  final double rating;
  final bool isFeatured;
  final int? createdBy;
  final String createdAt;
  final String updatedAt;

  CourseModel({
    this.id,
    required this.title,
    required this.description,
    this.thumbnail,
    this.thumbnailUrl,
    this.instructor = '',
    required this.category,
    this.difficulty = 'Beginner',
    this.level = 'Beginner',
    this.duration = '0 hours',
    this.lessonsCount = 0,
    this.enrolledCount = 0,
    this.rating = 0.0,
    this.isFeatured = false,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'thumbnail_url': thumbnailUrl,
      'instructor': instructor,
      'category': category,
      'difficulty': difficulty,
      'level': level,
      'duration': duration,
      'lessons_count': lessonsCount,
      'enrolled_count': enrolledCount,
      'rating': rating,
      'is_featured': isFeatured ? 1 : 0,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory CourseModel.fromMap(Map<String, dynamic> map) {
    return CourseModel(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      thumbnail: map['thumbnail'],
      thumbnailUrl: map['thumbnail_url'],
      instructor: map['instructor'] ?? '',
      category: map['category'] ?? '',
      difficulty: map['difficulty'] ?? 'Beginner',
      level: map['level'] ?? map['difficulty'] ?? 'Beginner',
      duration: map['duration']?.toString() ?? '0 hours',
      lessonsCount: map['lessons_count'] ?? 0,
      enrolledCount: map['enrolled_count'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      isFeatured: map['is_featured'] == 1,
      createdBy: map['created_by'],
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
    );
  }

  CourseModel copyWith({
    int? id,
    String? title,
    String? description,
    String? thumbnail,
    String? thumbnailUrl,
    String? instructor,
    String? category,
    String? difficulty,
    String? level,
    String? duration,
    int? lessonsCount,
    int? enrolledCount,
    double? rating,
    bool? isFeatured,
    int? createdBy,
    String? createdAt,
    String? updatedAt,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      instructor: instructor ?? this.instructor,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      level: level ?? this.level,
      duration: duration ?? this.duration,
      lessonsCount: lessonsCount ?? this.lessonsCount,
      enrolledCount: enrolledCount ?? this.enrolledCount,
      rating: rating ?? this.rating,
      isFeatured: isFeatured ?? this.isFeatured,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
