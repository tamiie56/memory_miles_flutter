// lib/screens/story/add_edit_story_screen.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../models/travel_story.dart';
import '../../providers/story_provider.dart';
import '../../utils/theme.dart';

class AddEditStoryScreen extends StatefulWidget {
  final TravelStory? story;

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

  // existing media (edit mode)
  List<String> _existingMediaUrls = [];

  // new media to upload
  List<File> _newMediaFiles = [];
  List<Uint8List> _newMediaBytes = [];
  List<String> _newMediaFilenames = [];
  List<bool> _newMediaIsVideo = []; // track which are videos

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
      _existingMediaUrls = List.from(widget.story!.mediaUrls);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _storyCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    // Show bottom sheet to choose image or video
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library,
                  color: AppTheme.primary),
              title: const Text('Add Images'),
              onTap: () {
                Navigator.pop(context);
                _pickImages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam,
                  color: AppTheme.primary),
              title: const Text('Add Video'),
              subtitle: const Text('Max 30 seconds recommended',
                  style: TextStyle(fontSize: 11)),
              onTap: () {
                Navigator.pop(context);
                _pickVideo();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      if (kIsWeb) {
        for (final xfile in picked) {
          final bytes = await xfile.readAsBytes();
          setState(() {
            _newMediaBytes.add(bytes);
            _newMediaFilenames.add(xfile.name);
            _newMediaIsVideo.add(false);
          });
        }
      } else {
        setState(() {
          for (final xfile in picked) {
            _newMediaFiles.add(File(xfile.path));
            _newMediaIsVideo.add(false);
          }
        });
      }
    }
  }

  Future<void> _pickVideo() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          setState(() {
            _newMediaBytes.add(file.bytes!);
            _newMediaFilenames.add(file.name);
            _newMediaIsVideo.add(true);
          });
        }
      }
    } else {
      final picker = ImagePicker();
      final picked = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 60),
      );
      if (picked != null) {
        setState(() {
          _newMediaFiles.add(File(picked.path));
          _newMediaIsVideo.add(true);
        });
      }
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
    setState(() {
      _error = null;
      _loading = true;
    });

    final provider = context.read<StoryProvider>();
    bool success;

    if (isEdit) {
      success = await provider.editStory(
        id: widget.story!.id,
        title: _titleCtrl.text.trim(),
        story: _storyCtrl.text.trim(),
        currentMediaUrls: _existingMediaUrls,
        visitedLocation: _locations,
        visitedDate: _visitedDate,
        newMediaFiles: _newMediaFiles.isNotEmpty ? _newMediaFiles : null,
        newMediaBytesList: _newMediaBytes.isNotEmpty ? _newMediaBytes : null,
        newMediaFilenames: _newMediaFilenames.isNotEmpty ? _newMediaFilenames : null,
      );
    } else {
      success = await provider.addStory(
        title: _titleCtrl.text.trim(),
        story: _storyCtrl.text.trim(),
        visitedLocation: _locations,
        visitedDate: _visitedDate,
        mediaFiles: _newMediaFiles.isNotEmpty ? _newMediaFiles : null,
        mediaBytesList: _newMediaBytes.isNotEmpty ? _newMediaBytes : null,
        mediaFilenames: _newMediaFilenames.isNotEmpty ? _newMediaFilenames : null,
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

  int get _totalMedia =>
      _existingMediaUrls.length +
          (kIsWeb ? _newMediaBytes.length : _newMediaFiles.length);

  bool _isVideoUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('/video/') ||
        lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi');
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
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppTheme.primary),
            )
                : Text(
              isEdit ? 'UPDATE' : 'ADD',
              style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold),
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
                    style: const TextStyle(
                        color: AppTheme.danger, fontSize: 13)),
              ),

            _label('TITLE'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
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
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    const Icon(Icons.edit,
                        color: AppTheme.primary, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Media section
            _label('PHOTOS & VIDEOS ($_totalMedia selected)'),
            const SizedBox(height: 8),

            if (_totalMedia > 0) ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _totalMedia,
                itemBuilder: (context, index) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildMediaPreview(index),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeMedia(index),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickMedia,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppTheme.primary.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                    color: AppTheme.primaryLight,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          color: AppTheme.primary, size: 18),
                      SizedBox(width: 6),
                      Text('Add More Photos/Videos',
                          style: TextStyle(
                              color: AppTheme.primary, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ] else
              GestureDetector(
                onTap: _pickMedia,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.primary.withOpacity(0.3)),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          color: AppTheme.primary, size: 36),
                      SizedBox(height: 8),
                      Text('Tap to add photos or videos',
                          style: TextStyle(
                              color: AppTheme.primary, fontSize: 13)),
                    ],
                  ),
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
                labelStyle:
                const TextStyle(color: AppTheme.primary),
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

  Widget _buildMediaPreview(int index) {
    // Existing media
    if (index < _existingMediaUrls.length) {
      final url = _existingMediaUrls[index];
      if (_isVideoUrl(url)) {
        return Container(
          color: Colors.black87,
          child: const Center(
            child: Icon(Icons.play_circle_fill,
                color: Colors.white, size: 36),
          ),
        );
      }
      return Image.network(url, fit: BoxFit.cover);
    }

    // New media
    final newIndex = index - _existingMediaUrls.length;
    if (kIsWeb) {
      final isVideo = newIndex < _newMediaIsVideo.length
          ? _newMediaIsVideo[newIndex]
          : false;
      if (isVideo) {
        return Container(
          color: Colors.black87,
          child: const Center(
            child: Icon(Icons.play_circle_fill,
                color: Colors.white, size: 36),
          ),
        );
      }
      return Image.memory(_newMediaBytes[newIndex], fit: BoxFit.cover);
    } else {
      final isVideo = newIndex < _newMediaIsVideo.length
          ? _newMediaIsVideo[newIndex]
          : false;
      if (isVideo) {
        return Container(
          color: Colors.black87,
          child: const Center(
            child: Icon(Icons.play_circle_fill,
                color: Colors.white, size: 36),
          ),
        );
      }
      return Image.file(_newMediaFiles[newIndex], fit: BoxFit.cover);
    }
  }

  void _removeMedia(int index) {
    setState(() {
      if (index < _existingMediaUrls.length) {
        _existingMediaUrls.removeAt(index);
      } else {
        final newIndex = index - _existingMediaUrls.length;
        if (kIsWeb) {
          _newMediaBytes.removeAt(newIndex);
          if (newIndex < _newMediaFilenames.length) {
            _newMediaFilenames.removeAt(newIndex);
          }
          if (newIndex < _newMediaIsVideo.length) {
            _newMediaIsVideo.removeAt(newIndex);
          }
        } else {
          _newMediaFiles.removeAt(newIndex);
          if (newIndex < _newMediaIsVideo.length) {
            _newMediaIsVideo.removeAt(newIndex);
          }
        }
      }
    });
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppTheme.textMid,
        letterSpacing: 1),
  );

  String _monthName(int month) {
    const months = [
      '',
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}