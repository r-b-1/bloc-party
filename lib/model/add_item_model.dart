import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blocparty/model/item_model.dart';

class AddItemViewModel extends ChangeNotifier {
  String? _error;
  bool _isLoading = false;

  String? get error => _error;
  bool get isLoading => _isLoading;

  // Add this method to create new items
  Future<void> addItem({
    required String name,
    required String description,
    required ItemPortability portability,
    required List<String> tags,
    required String username,
    required String imagePath,
    required List<String> neighborhoodId,
  }) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      // Creating a new document in firestore
      final docRef = FirebaseFirestore.instance.collection('items').doc();

      // Normalize neighborhood IDs and ensure the active one is present
      final normalizedNeighborhoodIds = neighborhoodId
          .map((id) => id.trim())
          .where((id) => id.isNotEmpty)
          .toList();

      if (normalizedNeighborhoodIds.isEmpty) {
        throw Exception(
          'A neighborhood must be selected before adding an item.',
        );
      }

      // Creating the item
      final newItem = Item(
        id: docRef.id,
        name: name,
        description: description,
        isAvailable: true,
        userId: username,
        neighborhoodId: normalizedNeighborhoodIds,
        portability: portability,
        tags: tags,
        imagePath: imagePath,
      );

      // Saving to Firestore
      await docRef.set(newItem.toFirestore());

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add item: $e';
      _isLoading = false;
      print('Error adding item: $e');
      notifyListeners();
      rethrow;
    }
  }
}
