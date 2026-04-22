// lib/screens/story/view_story_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/travel_story.dart';
import '../../providers/story_provider.dart';
import '../../utils/theme.dart';
import 'add_edit_story_screen.dart';

class ViewStoryScreen extends StatelessWidget {
  final TravelStory story;

  const ViewStoryScreen({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: CustomScrollView(
        slivers: [
          // Hero image app bar
          SliverAppBar(
            expandedHeight: 280,
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
                child:
                const Icon(Icons.arrow_back, color: AppTheme.textDark),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AddEditStoryScreen(story: story)),
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
                  margin:
                  const EdgeInsets.only(right: 8, top: 8, bottom: 8),
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
              background: story.imageUrls.isNotEmpty
                  ? PageView.builder(
                itemCount: story.imageUrls.length,
                itemBuilder: (context, index) => Image.network(
                  story.imageUrls[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppTheme.primaryLight,
                    child: const Icon(Icons.image_outlined,
                        color: AppTheme.primary, size: 60),
                  ),
                ),
              )
                  : Container(
                color: AppTheme.primaryLight,
                child: const Icon(Icons.image_outlined,
                    color: AppTheme.primary, size: 60),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image count indicator
                  if (story.imageUrls.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.photo_library,
                              size: 14, color: AppTheme.textMid),
                          const SizedBox(width: 4),
                          Text(
                            '${story.imageUrls.length} photos — swipe to view',
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textMid),
                          ),
                        ],
                      ),
                    ),

                  Text(
                    story.title,
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
                        DateFormat('dd MMM yyyy').format(story.visitedDate),
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.textMid),
                      ),
                      const Spacer(),
                      if (story.visitedLocation.isNotEmpty)
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
                                story.visitedLocation.join(', '),
                                style: const TextStyle(
                                    fontSize: 12, color: AppTheme.primary),
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
                    story.story,
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
      await context.read<StoryProvider>().deleteStory(story.id);
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