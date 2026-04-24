// lib/providers/story_provider.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
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
    List<File>? mediaFiles,
    List<Uint8List>? mediaBytesList,
    List<String>? mediaFilenames,
  }) async {
    List<String> mediaUrls = [];

    if (kIsWeb && mediaBytesList != null && mediaBytesList.isNotEmpty) {
      mediaUrls = await ApiService.uploadMediaBytesList(
        mediaBytesList,
        mediaFilenames ?? List.generate(mediaBytesList.length, (i) => 'media_$i.jpg'),
      );
    } else if (mediaFiles != null && mediaFiles.isNotEmpty) {
      mediaUrls = await ApiService.uploadMediaFiles(mediaFiles);
    }

    final result = await ApiService.addStory(
      title: title,
      story: story,
      mediaUrls: mediaUrls,
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
    required List<String> currentMediaUrls,
    required List<String> visitedLocation,
    required DateTime visitedDate,
    List<File>? newMediaFiles,
    List<Uint8List>? newMediaBytesList,
    List<String>? newMediaFilenames,
  }) async {
    List<String> mediaUrls = List.from(currentMediaUrls);

    if (kIsWeb && newMediaBytesList != null && newMediaBytesList.isNotEmpty) {
      final uploaded = await ApiService.uploadMediaBytesList(
        newMediaBytesList,
        newMediaFilenames ?? List.generate(newMediaBytesList.length, (i) => 'media_$i.jpg'),
      );
      mediaUrls.addAll(uploaded);
    } else if (newMediaFiles != null && newMediaFiles.isNotEmpty) {
      final uploaded = await ApiService.uploadMediaFiles(newMediaFiles);
      mediaUrls.addAll(uploaded);
    }

    final result = await ApiService.editStory(
      id: id,
      title: title,
      story: story,
      mediaUrls: mediaUrls,
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