import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../services/database_helper.dart';
import '../../../models/quiz_model.dart';
import 'add_edit_question_screen.dart';

class ManageQuizQuestionsScreen extends StatefulWidget {
  final QuizModel quiz;

  const ManageQuizQuestionsScreen({super.key, required this.quiz});

  @override
  State<ManageQuizQuestionsScreen> createState() => _ManageQuizQuestionsScreenState();
}

class _ManageQuizQuestionsScreenState extends State<ManageQuizQuestionsScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<QuizQuestionModel> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
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
    
    // Update quiz total questions count
    await _db.update(
      'quizzes',
      {'total_questions': questions.length},
      where: 'id = ?',
      whereArgs: [widget.quiz.id],
    );
    
    setState(() {
      _questions = questions;
      _isLoading = false;
    });
  }

  Future<void> _deleteQuestion(int questionId) async {
    await _db.delete('quiz_questions', where: 'id = ?', whereArgs: [questionId]);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question deleted successfully'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.quiz.title} - Questions'),
        backgroundColor: AppTheme.adminPrimaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.question_answer_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No questions yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to add your first question',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final question = _questions[index];
                    return _buildQuestionCard(question, index + 1);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditQuestionScreen(
                quiz: widget.quiz,
                orderIndex: _questions.length + 1,
              ),
            ),
          );
          _loadQuestions();
        },
        backgroundColor: AppTheme.adminPrimaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuestionCard(QuizQuestionModel question, int number) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.adminPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.adminPrimaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.question,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildOption('A', question.optionA, question.correctAnswer == 'A'),
                      const SizedBox(height: 6),
                      _buildOption('B', question.optionB, question.correctAnswer == 'B'),
                      const SizedBox(height: 6),
                      _buildOption('C', question.optionC, question.correctAnswer == 'C'),
                      const SizedBox(height: 6),
                      _buildOption('D', question.optionD, question.correctAnswer == 'D'),
                      if (question.explanation.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  question.explanation,
                                  style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditQuestionScreen(
                          quiz: widget.quiz,
                          question: question,
                          orderIndex: question.orderIndex,
                        ),
                      ),
                    );
                    _loadQuestions();
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.adminPrimaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Question'),
                        content: const Text(
                          'Are you sure you want to delete this question?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteQuestion(question.id!);
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String letter, String text, bool isCorrect) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect ? Colors.green.shade300 : Colors.grey.shade300,
          width: isCorrect ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCorrect ? Colors.green.shade600 : Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                letter,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: isCorrect ? Colors.green.shade900 : Colors.grey.shade800,
                fontWeight: isCorrect ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          if (isCorrect)
            Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
        ],
      ),
    );
  }
}
