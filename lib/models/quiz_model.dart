class QuizModel {
  final int? id;
  final int courseId;
  final String title;
  final String description;
  final int duration;
  final int passingScore;
  final int totalQuestions;
  final String createdAt;
  final String updatedAt;

  QuizModel({
    this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.duration,
    required this.passingScore,
    required this.totalQuestions,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'description': description,
      'duration': duration,
      'passing_score': passingScore,
      'total_questions': totalQuestions,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory QuizModel.fromMap(Map<String, dynamic> map) {
    return QuizModel(
      id: map['id'] as int?,
      courseId: map['course_id'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      duration: (map['duration'] is int) ? map['duration'] as int : (map['duration'] as num?)?.toInt() ?? 0,
      passingScore: (map['passing_score'] is int) ? map['passing_score'] as int : (map['passing_score'] as num?)?.toInt() ?? 60,
      totalQuestions: (map['total_questions'] is int) ? map['total_questions'] as int : (map['total_questions'] as num?)?.toInt() ?? 0,
      createdAt: map['created_at'] as String? ?? '',
      updatedAt: map['updated_at'] as String? ?? '',
    );
  }
}

class QuizQuestionModel {
  final int? id;
  final int quizId;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;
  final String explanation;
  final int orderIndex;
  final String createdAt;
  final String updatedAt;

  QuizQuestionModel({
    this.id,
    required this.quizId,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    this.explanation = '',
    required this.orderIndex,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quiz_id': quizId,
      'question': question,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'option_d': optionD,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'order_index': orderIndex,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory QuizQuestionModel.fromMap(Map<String, dynamic> map) {
    return QuizQuestionModel(
      id: map['id'],
      quizId: map['quiz_id'] ?? 0,
      question: map['question'] ?? '',
      optionA: map['option_a'] ?? '',
      optionB: map['option_b'] ?? '',
      optionC: map['option_c'] ?? '',
      optionD: map['option_d'] ?? '',
      correctAnswer: map['correct_answer'] ?? 'A',
      explanation: map['explanation'] ?? '',
      orderIndex: map['order_index'] ?? 0,
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
    );
  }
}

class QuizResultModel {
  final int? id;
  final int userId;
  final int quizId;
  final int score;
  final int totalQuestions;
  final int timeTaken;
  final bool passed;
  final String completedAt;

  QuizResultModel({
    this.id,
    required this.userId,
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.timeTaken,
    required this.passed,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'quiz_id': quizId,
      'score': score,
      'total_questions': totalQuestions,
      'time_taken': timeTaken,
      'passed': passed ? 1 : 0,
      'completed_at': completedAt,
    };
  }

  factory QuizResultModel.fromMap(Map<String, dynamic> map) {
    return QuizResultModel(
      id: map['id'],
      userId: map['user_id'],
      quizId: map['quiz_id'],
      score: map['score'],
      totalQuestions: map['total_questions'],
      timeTaken: map['time_taken'],
      passed: map['passed'] == 1,
      completedAt: map['completed_at'],
    );
  }
}
