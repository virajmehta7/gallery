import 'package:flutter/material.dart';

class MultipleSelectedImages extends ChangeNotifier {
  List<String> selectedImages = [];

  List<String> get getSelectedImages => selectedImages;

  selectImages(String id) {
    if (selectedImages.contains(id)) {
      selectedImages.remove(id);
    } else {
      selectedImages.add(id);
    }
    notifyListeners();
  }

  clearImages() {
    selectedImages.clear();
    notifyListeners();
  }
}
