// lib/providers/story_provider.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/travel_story.dart';
import '../services/api_service.dart';

class StoryProvider extends ChangeNotifier {
  List<TravelStory> _stories = [];
  bool _loading = false;

  List<TravelStory> get stories => _stories;
  bool get loading => _loading;

  Future<void> fetchAllStories() async {
    _loading = true;
    notifyListeners();
    _stories = await ApiService.getAllStories();
    _loading = false;
    notifyListeners();
  }

  Future<bool> addStory({
    required String title,
    required String story,
    required List<String> visitedLocation,
    required DateTime visitedDate,
    File? imageFile,
  }) async {
    String imageUrl = '';
    if (imageFile != null) {
      final uploaded = await ApiService.uploadImage(imageFile);
      imageUrl = uploaded ?? '';
    }

    final result = await ApiService.addStory(
      title: title,
      story: story,
      imageUrl: imageUrl,
      visitedLocation: visitedLocation,
      visitedDate: visitedDate,
    );

    if (result['success']) {
      await fetchAllStories();
      return true;
    }
    return false;
  }

  Future<bool> editStory({
    required String id,
    required String title,
    required String story,
    required String currentImageUrl,
    required List<String> visitedLocation,
    required DateTime visitedDate,
    File? newImageFile,
  }) async {
    String imageUrl = currentImageUrl;
    if (newImageFile != null) {
      final uploaded = await ApiService.uploadImage(newImageFile);
      imageUrl = uploaded ?? currentImageUrl;
    }

    final result = await ApiService.editStory(
      id: id,
      title: title,
      story: story,
      imageUrl: imageUrl,
      visitedLocation: visitedLocation,
      visitedDate: visitedDate,
    );

    if (result['success']) {
      await fetchAllStories();
      return true;
    }
    return false;
  }

  Future<bool> deleteStory(String id) async {
    final success = await ApiService.deleteStory(id);
    if (success) {
      _stories.removeWhere((s) => s.id == id);
      notifyListeners();
    }
    return success;
  }

  Future<void> toggleFavorite(TravelStory story) async {
    final newVal = !story.isFavorite;
    final success = await ApiService.updateFavorite(story.id, newVal);
    if (success) {
      final idx = _stories.indexWhere((s) => s.id == story.id);
      if (idx != -1) {
        _stories[idx] = story.copyWith(isFavorite: newVal);
        // Sort: favorites first
        _stories.sort((a, b) => b.isFavorite ? 1 : -1);
        notifyListeners();
      }
    }
  }

  Future<void> searchStories(String query) async {
    _loading = true;
    notifyListeners();
    _stories = await ApiService.searchStories(query);
    _loading = false;
    notifyListeners();
  }
}
