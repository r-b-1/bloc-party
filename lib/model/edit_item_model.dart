import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blocparty/model/item_model.dart';

class EditItemViewModel extends ChangeNotifier {
  String? _error;
  bool _isLoading = false;

  String? get error => _error;
  bool get isLoading => _isLoading;

  // Method to update existing items
  Future<void> updateItem({
    required String itemId,
    required String name,
    required String description,
    required ItemPortability portability,
    required List<String> tags,
    required List<String> neighborhoodId,
    required String imagePath,
  }) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      // Validate neighborhood selection
      if (neighborhoodId.isEmpty) {
        throw Exception(
          'A neighborhood must be selected before updating the item.',
        );
      }

      // Update the item in Firestore
      await FirebaseFirestore.instance.collection('items').doc(itemId).update({
        'name': name,
        'description': description,
        'portability': portability.name,
        'tags': tags,
        'neighborhoodId': neighborhoodId,
        'imagePath': imagePath,
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update item: $e';
      _isLoading = false;
      print('Error updating item: $e');
      notifyListeners();
      rethrow;
    }
  }
}