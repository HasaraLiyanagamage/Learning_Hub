class LessonModel {
  final int? id;
  final int courseId;
  final String title;
  final String description;
  final String content;
  final String videoUrl;
  final String duration;
  final int orderIndex;
  final int isCompleted;
  final String createdAt;
  final String updatedAt;

  LessonModel({
    this.id,
    required this.courseId,
    required this.title,
    this.description = '',
    required this.content,
    this.videoUrl = '',
    this.duration = '0 min',
    required this.orderIndex,
    this.isCompleted = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'description': description,
      'content': content,
      'video_url': videoUrl,
      'duration': duration,
      'order_index': orderIndex,
      'is_completed': isCompleted,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory LessonModel.fromMap(Map<String, dynamic> map) {
    return LessonModel(
      id: map['id'],
      courseId: map['course_id'] ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      content: map['content'] ?? '',
      videoUrl: map['video_url'] ?? '',
      duration: map['duration']?.toString() ?? '0 min',
      orderIndex: map['order_index'] ?? 0,
      isCompleted: map['is_completed'] ?? 0,
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
    );
  }
}
