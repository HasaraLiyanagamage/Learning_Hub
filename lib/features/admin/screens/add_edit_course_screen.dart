import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../services/database_helper.dart';
import '../../../models/course_model.dart';

class AddEditCourseScreen extends StatefulWidget {
  final CourseModel? course;

  const AddEditCourseScreen({super.key, this.course});

  @override
  State<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends State<AddEditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _instructorController;
  late TextEditingController _durationController;
  late TextEditingController _thumbnailController;
  
  String _selectedCategory = 'Programming';
  String _selectedLevel = 'Beginner';
  bool _isLoading = false;

  final List<String> _categories = [
    'Programming',
    'Design',
    'Business',
    'Marketing',
    'Data Science',
    'Mobile Development',
    'Web Development',
    'Database',
    'Other',
  ];

  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.course?.title ?? '');
    _descriptionController = TextEditingController(text: widget.course?.description ?? '');
    _instructorController = TextEditingController(text: widget.course?.instructor ?? '');
    _durationController = TextEditingController(text: widget.course?.duration ?? '');
    _thumbnailController = TextEditingController(text: widget.course?.thumbnailUrl ?? '');
    
    if (widget.course != null) {
      _selectedCategory = widget.course!.category;
      _selectedLevel = widget.course!.level;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructorController.dispose();
    _durationController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final courseData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'instructor': _instructorController.text.trim(),
      'duration': _durationController.text.trim(),
      'category': _selectedCategory,
      'level': _selectedLevel,
      'thumbnail_url': _thumbnailController.text.trim(),
      'rating': widget.course?.rating ?? 0.0,
      'enrolled_count': widget.course?.enrolledCount ?? 0,
      'lessons_count': widget.course?.lessonsCount ?? 0,
      'is_featured': widget.course?.isFeatured ?? 0,
      'created_at': widget.course?.createdAt ?? DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      if (widget.course == null) {
        // Create new course
        await _db.insert('courses', courseData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Course created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Update existing course
        await _db.update(
          'courses',
          courseData,
          where: 'id = ?',
          whereArgs: [widget.course!.id],
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Course updated successfully!'),
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
        title: Text(widget.course == null ? 'Add Course' : 'Edit Course'),
        backgroundColor: AppTheme.adminPrimaryColor,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _titleController,
              label: 'Course Title',
              hint: 'Enter course title',
              prefixIcon: Icons.title,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter course title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Enter course description',
              prefixIcon: Icons.description,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter course description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _instructorController,
              label: 'Instructor Name',
              hint: 'Enter instructor name',
              prefixIcon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter instructor name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _durationController,
              label: 'Duration',
              hint: 'e.g., 8 weeks, 20 hours',
              prefixIcon: Icons.access_time,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter course duration';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedLevel,
              decoration: InputDecoration(
                labelText: 'Difficulty Level',
                prefixIcon: const Icon(Icons.signal_cellular_alt),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _levels.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedLevel = value!);
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _thumbnailController,
              label: 'Thumbnail URL (Optional)',
              hint: 'Enter image URL',
              prefixIcon: Icons.image,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: widget.course == null ? 'Create Course' : 'Update Course',
              onPressed: _saveCourse,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
