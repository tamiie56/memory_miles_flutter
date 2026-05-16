// lib/widgets/story_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/travel_story.dart';
import '../utils/theme.dart';

class StoryCard extends StatelessWidget {
  final TravelStory story;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onEdit;

  const StoryCard({
    super.key,
    required this.story,
    required this.onTap,
    required this.onFavorite,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final firstImage = story.firstImageUrl;
    final firstVideo =
    story.videoOnlyUrls.isNotEmpty ? story.videoOnlyUrls.first : null;
    final hasVideo = story.videoOnlyUrls.isNotEmpty;
    final totalMedia = story.mediaUrls.length;

    // ✅ Dark-aware colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final titleColor = isDark ? Colors.white : AppTheme.textDark;
    final subtitleColor = isDark ? Colors.grey.shade400 : AppTheme.textMid;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        // ✅ FIX: ClipRRect prevents content from overflowing card boundary
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.07),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Thumbnail ──────────────────────────────────────────
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12)),
                    child: firstImage != null
                        ? Image.network(
                      firstImage,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                        : firstVideo != null
                        ? _videoThumbnailPlaceholder()
                        : _placeholder(),
                  ),

                  // Media count badge
                  if (totalMedia > 1)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.photo_library,
                                color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text('$totalMedia',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),

                  // Video indicator
                  if (hasVideo)
                    Positioned(
                      bottom: 8,
                      right: 40,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.videocam,
                                color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text('Video',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),

                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          story.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: story.isFavorite
                              ? Colors.red
                              : AppTheme.textMid,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Content ────────────────────────────────────────────
              // ✅ FIX: Expanded + Spacer keeps location chip inside card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        story.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Date
                      Text(
                        DateFormat('dd MMM yyyy').format(story.visitedDate),
                        style:
                        TextStyle(fontSize: 11, color: subtitleColor),
                      ),
                      const SizedBox(height: 5),

                      // Story preview
                      Text(
                        story.story,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12,
                            color: subtitleColor,
                            height: 1.4),
                      ),

                      // Pushes location chip to bottom of card
                      const Spacer(),

                      // Location chips
                      if (story.visitedLocation.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: story.visitedLocation
                              .take(2)
                              .map(
                                (loc) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius:
                                BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 11,
                                      color: AppTheme.primary),
                                  const SizedBox(width: 2),
                                  Flexible(
                                    child: Text(
                                      loc,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.primary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                              .toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    height: 140,
    color: AppTheme.primaryLight,
    child: const Icon(Icons.image_outlined,
        color: AppTheme.primary, size: 40),
  );

  Widget _videoThumbnailPlaceholder() => Container(
    height: 140,
    color: Colors.black87,
    child: const Center(
      child: Icon(Icons.play_circle_fill,
          color: Colors.white, size: 50),
    ),
  );
}