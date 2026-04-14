// lib/screens/story/add_edit_story_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/travel_story.dart';
import '../../providers/story_provider.dart';
import '../../utils/theme.dart';

class AddEditStoryScreen extends StatefulWidget {
  final TravelStory? story; // null = add mode

  const AddEditStoryScreen({super.key, this.story});

  @override
  State<AddEditStoryScreen> createState() => _AddEditStoryScreenState();
}

class _AddEditStoryScreenState extends State<AddEditStoryScreen> {
  final _titleCtrl = TextEditingController();
  final _storyCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  DateTime _visitedDate = DateTime.now();
  List<String> _locations = [];
  File? _imageFile;
  bool _loading = false;
  String? _error;

  bool get isEdit => widget.story != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _titleCtrl.text = widget.story!.title;
      _storyCtrl.text = widget.story!.story;
      _visitedDate = widget.story!.visitedDate;
      _locations = List.from(widget.story!.visitedLocation);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _storyCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _visitedDate = picked);
  }

  void _addLocation() {
    final loc = _locationCtrl.text.trim();
    if (loc.isNotEmpty && !_locations.contains(loc)) {
      setState(() {
        _locations.add(loc);
        _locationCtrl.clear();
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter the title');
      return;
    }
    if (_storyCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter the story');
      return;
    }
    setState(() { _error = null; _loading = true; });

    final provider = context.read<StoryProvider>();
    bool success;

    if (isEdit) {
      success = await provider.editStory(
        id: widget.story!.id,
        title: _titleCtrl.text.trim(),
        story: _storyCtrl.text.trim(),
        currentImageUrl: widget.story!.imageUrl,
        visitedLocation: _locations,
        visitedDate: _visitedDate,
        newImageFile: _imageFile,
      );
    } else {
      success = await provider.addStory(
        title: _titleCtrl.text.trim(),
        story: _storyCtrl.text.trim(),
        visitedLocation: _locations,
        visitedDate: _visitedDate,
        imageFile: _imageFile,
      );
    }

    if (mounted) {
      setState(() => _loading = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEdit ? 'Story updated!' : 'Story added!'),
          backgroundColor: AppTheme.primary,
        ));
      } else {
        setState(() => _error = 'Something went wrong. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Update Story' : 'Add Story'),
        backgroundColor: AppTheme.white,
        actions: [
          TextButton(
            onPressed: _loading ? null : _handleSubmit,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                  )
                : Text(
                    isEdit ? 'UPDATE' : 'ADD',
                    style: const TextStyle(
                        color: AppTheme.primary, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_error!,
                    style: const TextStyle(color: AppTheme.danger, fontSize: 13)),
              ),

            // Title
            _label('TITLE'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              decoration: const InputDecoration(
                hintText: 'Once Upon A Time...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Date picker
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: AppTheme.primary, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      '${_visitedDate.day} ${_monthName(_visitedDate.month)} ${_visitedDate.year}',
                      style: const TextStyle(
                          color: AppTheme.primary, fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    const Icon(Icons.edit, color: AppTheme.primary, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Image selector
            _label('COVER IMAGE'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                ),
                clipBehavior: Clip.hardEdge,
                child: _imageFile != null
                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                    : (isEdit && widget.story!.imageUrl.isNotEmpty)
                        ? Image.network(widget.story!.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imagePlaceholder())
                        : _imagePlaceholder(),
              ),
            ),
            const SizedBox(height: 20),

            // Story
            _label('STORY'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _storyCtrl,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: 'Your Story...',
                  contentPadding: EdgeInsets.all(16),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Visited locations
            _label('VISITED LOCATIONS'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Add a location',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    onSubmitted: (_) => _addLocation(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addLocation,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(50, 50),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _locations
                  .map((loc) => Chip(
                        label: Text(loc),
                        backgroundColor: AppTheme.primaryLight,
                        labelStyle: const TextStyle(color: AppTheme.primary),
                        deleteIcon: const Icon(Icons.close,
                            size: 16, color: AppTheme.primary),
                        onDeleted: () =>
                            setState(() => _locations.remove(loc)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppTheme.textMid,
            letterSpacing: 1),
      );

  Widget _imagePlaceholder() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add_photo_alternate_outlined,
              color: AppTheme.primary, size: 36),
          SizedBox(height: 8),
          Text('Tap to add cover image',
              style: TextStyle(color: AppTheme.primary, fontSize: 13)),
        ],
      );

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}
