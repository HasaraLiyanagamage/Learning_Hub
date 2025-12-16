import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../services/database_helper.dart';
import '../../../models/quiz_model.dart';
import '../../../models/course_model.dart';

class AddEditQuizScreen extends StatefulWidget {
  final List<CourseModel> courses;
  final QuizModel? quiz;

  const AddEditQuizScreen({
    super.key,
    required this.courses,
    this.quiz,
  });

  @override
  State<AddEditQuizScreen> createState() => _AddEditQuizScreenState();
}

class _AddEditQuizScreenState extends State<AddEditQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _durationController;
  late TextEditingController _passingScoreController;
  
  int? _selectedCourseId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.quiz?.title ?? '');
    _descriptionController = TextEditingController(text: widget.quiz?.description ?? '');
    _durationController = TextEditingController(
      text: widget.quiz != null ? (widget.quiz!.duration ~/ 60).toString() : '20',
    );
    _passingScoreController = TextEditingController(
      text: widget.quiz?.passingScore.toString() ?? '60',
    );
    
    _selectedCourseId = widget.quiz?.courseId ?? widget.courses.first.id;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _passingScoreController.dispose();
    super.dispose();
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a course'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final durationInSeconds = int.parse(_durationController.text.trim()) * 60;
    
    final quizData = {
      'course_id': _selectedCourseId,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'duration': durationInSeconds,
      'passing_score': int.parse(_passingScoreController.text.trim()),
      'total_questions': widget.quiz?.totalQuestions ?? 0,
      'created_at': widget.quiz?.createdAt ?? DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      if (widget.quiz == null) {
        // Create new quiz
        await _db.insert('quizzes', quizData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quiz created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Update existing quiz
        await _db.update(
          'quizzes',
          quizData,
          where: 'id = ?',
          whereArgs: [widget.quiz!.id],
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quiz updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz == null ? 'Add Quiz' : 'Edit Quiz'),
        backgroundColor: AppTheme.adminPrimaryColor,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<int>(
              initialValue: _selectedCourseId,
              decoration: InputDecoration(
                labelText: 'Select Course',
                prefixIcon: const Icon(Icons.school),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: widget.courses.map((course) {
                return DropdownMenuItem(
                  value: course.id,
                  child: Text(course.title),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCourseId = value);
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a course';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _titleController,
              label: 'Quiz Title',
              hint: 'Enter quiz title',
              prefixIcon: Icons.quiz,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quiz title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Enter quiz description',
              prefixIcon: Icons.description,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quiz description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _durationController,
              label: 'Duration (minutes)',
              hint: 'e.g., 20',
              prefixIcon: Icons.timer,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter duration';
                }
                final duration = int.tryParse(value);
                if (duration == null || duration <= 0) {
                  return 'Please enter a valid duration';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _passingScoreController,
              label: 'Passing Score (%)',
              hint: 'e.g., 60',
              prefixIcon: Icons.percent,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter passing score';
                }
                final score = int.tryParse(value);
                if (score == null || score < 0 || score > 100) {
                  return 'Please enter a valid score (0-100)';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: widget.quiz == null ? 'Create Quiz' : 'Update Quiz',
              onPressed: _saveQuiz,
              isLoading: _isLoading,
            ),
            if (widget.quiz == null) ...[
              const SizedBox(height: 16),
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
                          'Next Steps',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'After creating the quiz, you can add questions by clicking the "Questions" button on the quiz card.',
                      style: TextStyle(fontSize: 14, color: Colors.blue.shade900),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
