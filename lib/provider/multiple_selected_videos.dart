import 'package:flutter/material.dart';

class MultipleSelectedVideos extends ChangeNotifier {
  List<String> selectedVideos = [];

  List<String> get getselectedVideos => selectedVideos;

  selectVideos(String id) {
    if (selectedVideos.contains(id)) {
      selectedVideos.remove(id);
    } else {
      selectedVideos.add(id);
    }
    notifyListeners();
  }

  clearVideos() {
    selectedVideos.clear();
    notifyListeners();
  }
}
