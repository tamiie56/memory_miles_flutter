// lib/models/travel_story.dart

class TravelStory {
  final String id;
  final String title;
  final String story;
  final List<String> visitedLocation;
  final bool isFavorite;
  final String userId;
  final List<String> imageUrls;
  final DateTime visitedDate;
  final DateTime createdAt;

  TravelStory({
    required this.id,
    required this.title,
    required this.story,
    required this.visitedLocation,
    required this.isFavorite,
    required this.userId,
    required this.imageUrls,
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
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      visitedDate: json['visitedDate'] != null
          ? DateTime.parse(json['visitedDate'])
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  TravelStory copyWith({bool? isFavorite}) {
    return TravelStory(
      id: id,
      title: title,
      story: story,
      visitedLocation: visitedLocation,
      isFavorite: isFavorite ?? this.isFavorite,
      userId: userId,
      imageUrls: imageUrls,
      visitedDate: visitedDate,
      createdAt: createdAt,
    );
  }
}