import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../services/database_helper.dart';
import '../../../models/note_model.dart';
import '../../auth/providers/auth_provider.dart';

class AddNoteScreen extends StatefulWidget {
  final NoteModel? note;

  const AddNoteScreen({super.key, this.note});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  final DatabaseHelper _db = DatabaseHelper.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _tagsController.text = widget.note!.tags ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    if (userId == null) return;

    setState(() => _isLoading = true);

    final now = DateTime.now().toIso8601String();
    
    if (widget.note == null) {
      // Create new note
      final note = NoteModel(
        userId: userId,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        tags: _tagsController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );
      
      await _db.insert('notes', note.toMap());
    } else {
      // Update existing note
      await _db.update(
        'notes',
        {
          'title': _titleController.text.trim(),
          'content': _contentController.text.trim(),
          'tags': _tagsController.text.trim(),
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [widget.note!.id],
      );
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.note == null ? 'Note created!' : 'Note updated!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Add Note' : 'Edit Note'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                label: 'Title',
                hint: 'Enter note title',
                controller: _titleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Content',
                hint: 'Write your note here...',
                controller: _contentController,
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Tags (comma separated)',
                hint: 'e.g., flutter, dart, mobile',
                controller: _tagsController,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: widget.note == null ? 'Create Note' : 'Update Note',
                onPressed: _saveNote,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
