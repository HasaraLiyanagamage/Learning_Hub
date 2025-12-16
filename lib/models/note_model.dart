class NoteModel {
  final int? id;
  final int userId;
  final int? courseId;
  final int? lessonId;
  final String title;
  final String content;
  final String? tags;
  final bool isFavorite;
  final String createdAt;
  final String updatedAt;

  NoteModel({
    this.id,
    required this.userId,
    this.courseId,
    this.lessonId,
    required this.title,
    required this.content,
    this.tags,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'lesson_id': lessonId,
      'title': title,
      'content': content,
      'tags': tags,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      userId: map['user_id'],
      courseId: map['course_id'],
      lessonId: map['lesson_id'],
      title: map['title'],
      content: map['content'],
      tags: map['tags'],
      isFavorite: map['is_favorite'] == 1,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}
