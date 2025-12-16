import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../services/database_helper.dart';
import '../../../models/lesson_model.dart';
import '../../../models/course_model.dart';

class AddEditLessonScreen extends StatefulWidget {
  final List<CourseModel> courses;
  final LessonModel? lesson;

  const AddEditLessonScreen({
    super.key,
    required this.courses,
    this.lesson,
  });

  @override
  State<AddEditLessonScreen> createState() => _AddEditLessonScreenState();
}

class _AddEditLessonScreenState extends State<AddEditLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _contentController;
  late final TextEditingController _durationController;
  late final TextEditingController _videoUrlController;
  late final TextEditingController _orderController;
  
  int? _selectedCourseId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.lesson?.title ?? '');
    _descriptionController = TextEditingController(text: widget.lesson?.description ?? '');
    _contentController = TextEditingController(text: widget.lesson?.content ?? '');
    _durationController = TextEditingController(text: widget.lesson?.duration ?? '');
    _videoUrlController = TextEditingController(text: widget.lesson?.videoUrl ?? '');
    _orderController = TextEditingController(
      text: widget.lesson?.orderIndex.toString() ?? '1',
    );
    
    _selectedCourseId = widget.lesson?.courseId ?? (widget.courses.isNotEmpty ? widget.courses.first.id : null);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _durationController.dispose();
    _videoUrlController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _saveLesson() async {
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

    final lessonData = {
      'course_id': _selectedCourseId,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'content': _contentController.text.trim(),
      'duration': _durationController.text.trim(),
      'video_url': _videoUrlController.text.trim(),
      'order_index': int.parse(_orderController.text.trim()),
      'is_completed': widget.lesson?.isCompleted ?? 0,
      'created_at': widget.lesson?.createdAt ?? DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      if (widget.lesson == null) {
        // Create new lesson
        await _db.insert('lessons', lessonData);
        
        // Update course lessons count
        final course = widget.courses.firstWhere((c) => c.id == _selectedCourseId);
        await _db.update(
          'courses',
          {'lessons_count': course.lessonsCount + 1},
          where: 'id = ?',
          whereArgs: [_selectedCourseId],
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lesson created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Update existing lesson
        await _db.update(
          'lessons',
          lessonData,
          where: 'id = ?',
          whereArgs: [widget.lesson!.id],
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lesson updated successfully!'),
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
        title: Text(widget.lesson == null ? 'Add Lesson' : 'Edit Lesson'),
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
              label: 'Lesson Title',
              hint: 'Enter lesson title',
              prefixIcon: Icons.title,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter lesson title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descriptionController,
              label: 'Lesson Description',
              hint: 'Brief description of the lesson',
              prefixIcon: Icons.description,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter lesson description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _contentController,
              label: 'Lesson Content',
              hint: 'Enter detailed lesson content',
              prefixIcon: Icons.article,
              maxLines: 8,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter lesson content';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _durationController,
              label: 'Duration',
              hint: 'e.g., 15 min, 1 hour',
              prefixIcon: Icons.access_time,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter lesson duration';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _videoUrlController,
              label: 'Video URL (Optional)',
              hint: 'Enter YouTube or video URL',
              prefixIcon: Icons.video_library,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _orderController,
              label: 'Order Index',
              hint: 'Enter lesson order number',
              prefixIcon: Icons.format_list_numbered,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter order index';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: widget.lesson == null ? 'Create Lesson' : 'Update Lesson',
              onPressed: _saveLesson,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
