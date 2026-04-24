// lib/models/travel_story.dart

class TravelStory {
  final String id;
  final String title;
  final String story;
  final List<String> visitedLocation;
  final bool isFavorite;
  final String userId;
  final List<String> mediaUrls;
  final DateTime visitedDate;
  final DateTime createdAt;

  TravelStory({
    required this.id,
    required this.title,
    required this.story,
    required this.visitedLocation,
    required this.isFavorite,
    required this.userId,
    required this.mediaUrls,
    required this.visitedDate,
    required this.createdAt,
  });

  factory TravelStory.fromJson(Map<String, dynamic> json) {
    return TravelStory(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      story: json['story'] ?? '',
      visitedLocation: List<String>.from(json['visitedLocation'] ?? []),
      isFavorite: json['isFavorite'] ?? false,
      userId: json['userId'] ?? '',
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
      visitedDate: json['visitedDate'] != null
          ? DateTime.parse(json['visitedDate'])
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // URL টা video কিনা check করার helper
  bool isVideo(String url) {
    final lower = url.toLowerCase();
    return lower.contains('/video/') ||
        lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi');
  }

  List<String> get imageOnlyUrls =>
      mediaUrls.where((url) => !isVideo(url)).toList();

  List<String> get videoOnlyUrls =>
      mediaUrls.where((url) => isVideo(url)).toList();

  String? get firstImageUrl =>
      imageOnlyUrls.isNotEmpty ? imageOnlyUrls.first : null;

  TravelStory copyWith({bool? isFavorite}) {
    return TravelStory(
      id: id,
      title: title,
      story: story,
      visitedLocation: visitedLocation,
      isFavorite: isFavorite ?? this.isFavorite,
      userId: userId,
      mediaUrls: mediaUrls,
      visitedDate: visitedDate,
      createdAt: createdAt,
    );
  }
}