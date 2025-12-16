import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/quiz_model.dart';
import '../../../services/database_helper.dart';
import '../../../services/notification_service.dart';
import '../../auth/providers/auth_provider.dart';

class QuizDetailScreen extends StatefulWidget {
  final QuizModel quiz;

  const QuizDetailScreen({super.key, required this.quiz});

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<QuizQuestionModel> _questions = [];
  bool _isLoading = true;
  bool _quizStarted = false;
  int _currentQuestionIndex = 0;
  final Map<int, String> _selectedAnswers = {};
  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    
    final questionsData = await _db.query(
      'quiz_questions',
      where: 'quiz_id = ?',
      whereArgs: [widget.quiz.id],
      orderBy: 'order_index ASC',
    );
    
    final questions = questionsData.map((e) => QuizQuestionModel.fromMap(e)).toList();
    
    setState(() {
      _questions = questions;
      _isLoading = false;
    });
  }

  void _startQuiz() {
    setState(() {
      _quizStarted = true;
      _remainingSeconds = widget.quiz.duration;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _submitQuiz();
      }
    });
  }

  void _submitQuiz() {
    _timer?.cancel();
    
    int correctAnswers = 0;
    for (var i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i].correctAnswer) {
        correctAnswers++;
      }
    }
    
    final score = (correctAnswers / _questions.length * 100).round();
    final passed = score >= widget.quiz.passingScore;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizResultScreen(
          quiz: widget.quiz,
          score: score,
          correctAnswers: correctAnswers,
          totalQuestions: _questions.length,
          passed: passed,
          timeTaken: widget.quiz.duration - _remainingSeconds,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_quizStarted) {
      return _buildQuizIntro();
    }

    return _buildQuizContent();
  }

  Widget _buildQuizIntro() {
    return Scaffold(
      appBar: AppBar(title: Text(widget.quiz.title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quiz Instructions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildInfoRow(Icons.question_answer, 'Total Questions', '${widget.quiz.totalQuestions}'),
            _buildInfoRow(Icons.timer, 'Duration', '${widget.quiz.duration ~/ 60} minutes'),
            _buildInfoRow(Icons.check_circle, 'Passing Score', '${widget.quiz.passingScore}%'),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Important Notes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('• Answer all questions before submitting'),
                  const Text('• You cannot go back once submitted'),
                  const Text('• Timer will start when you begin'),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _startQuiz,
                child: const Text(
                  'Start Quiz',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizContent() {
    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_currentQuestionIndex + 1}/${_questions.length}'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_remainingSeconds ~/ 60}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: progress, minHeight: 4),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.question,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 24),
                  _buildOptionTile('A', question.optionA),
                  _buildOptionTile('B', question.optionB),
                  _buildOptionTile('C', question.optionC),
                  _buildOptionTile('D', question.optionD),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _currentQuestionIndex--);
                      },
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentQuestionIndex < _questions.length - 1) {
                        setState(() => _currentQuestionIndex++);
                      } else {
                        _submitQuiz();
                      }
                    },
                    child: Text(
                      _currentQuestionIndex < _questions.length - 1 ? 'Next' : 'Submit',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(String option, String text) {
    final isSelected = _selectedAnswers[_currentQuestionIndex] == option;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAnswers[_currentQuestionIndex] = option;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class QuizResultScreen extends StatefulWidget {
  final QuizModel quiz;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final bool passed;
  final int timeTaken;

  const QuizResultScreen({
    super.key,
    required this.quiz,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.passed,
    required this.timeTaken,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  final NotificationService _notificationService = NotificationService();
  final DatabaseHelper _db = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _saveResultAndNotify();
  }

  Future<void> _saveResultAndNotify() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    if (userId == null) return;

    // Save quiz result to database
    final now = DateTime.now().toIso8601String();
    await _db.insert('quiz_results', {
      'user_id': userId,
      'quiz_id': widget.quiz.id,
      'score': widget.score,
      'total_questions': widget.totalQuestions,
      'time_taken': widget.timeTaken,
      'passed': widget.passed ? 1 : 0,
      'completed_at': now,
    });

    // Send notification
    await _notificationService.createQuizCompletionNotification(
      userId: userId,
      quizTitle: widget.quiz.title,
      score: widget.score,
      passed: widget.passed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Result'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.passed ? Icons.check_circle : Icons.cancel,
                size: 100,
                color: widget.passed ? AppTheme.successColor : AppTheme.errorColor,
              ),
              const SizedBox(height: 24),
              Text(
                widget.passed ? 'Congratulations!' : 'Keep Trying!',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.passed ? 'You passed the quiz!' : 'You didn\'t pass this time',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '${widget.score}%',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: widget.passed ? AppTheme.successColor : AppTheme.errorColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildResultRow('Correct Answers', '${widget.correctAnswers}/${widget.totalQuestions}'),
                    _buildResultRow('Time Taken', '${widget.timeTaken ~/ 60}:${(widget.timeTaken % 60).toString().padLeft(2, '0')}'),
                    _buildResultRow('Passing Score', '${widget.quiz.passingScore}%'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
