import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../services/database_helper.dart';
import '../../../models/quiz_model.dart';

class AddEditQuestionScreen extends StatefulWidget {
  final QuizModel quiz;
  final QuizQuestionModel? question;
  final int orderIndex;

  const AddEditQuestionScreen({
    super.key,
    required this.quiz,
    this.question,
    required this.orderIndex,
  });

  @override
  State<AddEditQuestionScreen> createState() => _AddEditQuestionScreenState();
}

class _AddEditQuestionScreenState extends State<AddEditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  late TextEditingController _questionController;
  late TextEditingController _optionAController;
  late TextEditingController _optionBController;
  late TextEditingController _optionCController;
  late TextEditingController _optionDController;
  late TextEditingController _explanationController;
  
  String _correctAnswer = 'A';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.question?.question ?? '');
    _optionAController = TextEditingController(text: widget.question?.optionA ?? '');
    _optionBController = TextEditingController(text: widget.question?.optionB ?? '');
    _optionCController = TextEditingController(text: widget.question?.optionC ?? '');
    _optionDController = TextEditingController(text: widget.question?.optionD ?? '');
    _explanationController = TextEditingController(text: widget.question?.explanation ?? '');
    
    if (widget.question != null) {
      _correctAnswer = widget.question!.correctAnswer;
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _optionAController.dispose();
    _optionBController.dispose();
    _optionCController.dispose();
    _optionDController.dispose();
    _explanationController.dispose();
    super.dispose();
  }

  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final questionData = {
      'quiz_id': widget.quiz.id,
      'question': _questionController.text.trim(),
      'option_a': _optionAController.text.trim(),
      'option_b': _optionBController.text.trim(),
      'option_c': _optionCController.text.trim(),
      'option_d': _optionDController.text.trim(),
      'correct_answer': _correctAnswer,
      'explanation': _explanationController.text.trim(),
      'order_index': widget.orderIndex,
      'created_at': widget.question?.createdAt ?? DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      if (widget.question == null) {
        // Create new question
        await _db.insert('quiz_questions', questionData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Question added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Update existing question
        await _db.update(
          'quiz_questions',
          questionData,
          where: 'id = ?',
          whereArgs: [widget.question!.id],
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Question updated successfully!'),
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
        title: Text(widget.question == null ? 'Add Question' : 'Edit Question'),
        backgroundColor: AppTheme.adminPrimaryColor,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _questionController,
              label: 'Question',
              hint: 'Enter the question',
              prefixIcon: Icons.help_outline,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the question';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Options',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildOptionField('A', _optionAController),
            const SizedBox(height: 12),
            _buildOptionField('B', _optionBController),
            const SizedBox(height: 12),
            _buildOptionField('C', _optionCController),
            const SizedBox(height: 12),
            _buildOptionField('D', _optionDController),
            const SizedBox(height: 24),
            const Text(
              'Correct Answer',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _correctAnswer,
                  isExpanded: true,
                  items: ['A', 'B', 'C', 'D'].map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text('Option $option'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _correctAnswer = value!);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _explanationController,
              label: 'Explanation (Optional)',
              hint: 'Explain why this is the correct answer',
              prefixIcon: Icons.lightbulb_outline,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: widget.question == null ? 'Add Question' : 'Update Question',
              onPressed: _saveQuestion,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionField(String letter, TextEditingController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 56,
          decoration: BoxDecoration(
            color: _correctAnswer == letter
                ? Colors.green.shade100
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              letter,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _correctAnswer == letter
                    ? Colors.green.shade700
                    : Colors.grey.shade700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomTextField(
            controller: controller,
            label: 'Option $letter',
            hint: 'Enter option $letter',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter option $letter';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
