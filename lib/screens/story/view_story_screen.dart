// lib/screens/story/view_story_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../models/travel_story.dart';
import '../../providers/story_provider.dart';
import '../../utils/theme.dart';
import 'add_edit_story_screen.dart';

class ViewStoryScreen extends StatefulWidget {
  final TravelStory story;

  const ViewStoryScreen({super.key, required this.story});

  @override
  State<ViewStoryScreen> createState() => _ViewStoryScreenState();
}

class _ViewStoryScreenState extends State<ViewStoryScreen> {
  int _currentMediaIndex = 0;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initMediaForIndex(0);
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  void _disposeVideo() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
  }

  bool _isVideo(String url) {
    final lower = url.toLowerCase();
    return lower.contains('/video/') ||
        lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi');
  }

  Future<void> _initMediaForIndex(int index) async {
    if (index >= widget.story.mediaUrls.length) return;
    final url = widget.story.mediaUrls[index];

    if (_isVideo(url)) {
      _disposeVideo();
      final controller =
      VideoPlayerController.networkUrl(Uri.parse(url));
      await controller.initialize();
      final chewie = ChewieController(
        videoPlayerController: controller,
        autoPlay: false,
        looping: false,
        aspectRatio: controller.value.aspectRatio,
      );
      if (mounted) {
        setState(() {
          _videoController = controller;
          _chewieController = chewie;
        });
      }
    } else {
      _disposeVideo();
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.story.mediaUrls;

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.white,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back,
                    color: AppTheme.textDark),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          AddEditStoryScreen(story: widget.story)),
                ),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 16, color: AppTheme.primary),
                      SizedBox(width: 4),
                      Text('Edit',
                          style: TextStyle(
                              color: AppTheme.primary, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _confirmDelete(context),
                child: Container(
                  margin: const EdgeInsets.only(
                      right: 8, top: 8, bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.delete_outline,
                          size: 16, color: AppTheme.danger),
                      SizedBox(width: 4),
                      Text('Delete',
                          style: TextStyle(
                              color: AppTheme.danger, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: media.isEmpty
                  ? Container(
                color: AppTheme.primaryLight,
                child: const Icon(Icons.image_outlined,
                    color: AppTheme.primary, size: 60),
              )
                  : _buildMediaViewer(media),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Media dots indicator
                  if (media.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          media.length,
                              (i) => Container(
                            width: i == _currentMediaIndex ? 16 : 8,
                            height: 8,
                            margin:
                            const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: i == _currentMediaIndex
                                  ? AppTheme.primary
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),

                  Text(
                    widget.story.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy')
                            .format(widget.story.visitedDate),
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.textMid),
                      ),
                      const Spacer(),
                      if (widget.story.visitedLocation.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on,
                                  size: 13, color: AppTheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                widget.story.visitedLocation.join(', '),
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.primary),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  Text(
                    widget.story.story,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textDark,
                      height: 1.7,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaViewer(List<String> media) {
    return PageView.builder(
      itemCount: media.length,
      onPageChanged: (index) {
        setState(() => _currentMediaIndex = index);
        _initMediaForIndex(index);
      },
      itemBuilder: (context, index) {
        final url = media[index];
        if (_isVideo(url)) {
          if (index == _currentMediaIndex &&
              _chewieController != null) {
            return Chewie(controller: _chewieController!);
          }
          return Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }
        return Image.network(url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppTheme.primaryLight,
              child: const Icon(Icons.image_outlined,
                  color: AppTheme.primary, size: 60),
            ));
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Story'),
        content:
        const Text('Are you sure you want to delete this story?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style:
            TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success =
      await context.read<StoryProvider>().deleteStory(widget.story.id);
      if (context.mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Story deleted successfully'),
              backgroundColor: AppTheme.primary,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete story'),
              backgroundColor: AppTheme.danger,
            ),
          );
        }
      }
    }
  }
}