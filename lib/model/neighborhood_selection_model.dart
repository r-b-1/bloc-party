import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class NeighborhoodSelectionModel extends ChangeNotifier {
  List<String> _userNeighborhoods = [];
  bool _isLoading = true;
  String? _error;
  // callback to notify when neighborhood changes
  VoidCallback? _onNeighborhoodChanged;

  List<String> get userNeighborhoods => _userNeighborhoods;
  bool get isLoading => _isLoading;
  String? get error => _error;

  NeighborhoodSelectionModel({VoidCallback? onNeighborhoodChanged}) {
    _onNeighborhoodChanged = onNeighborhoodChanged;
    // uses Future.microtask to defer initialization until after build
    Future.microtask(() => _fetchUserNeighborhoods());
  }

  // Fetch user's neighborhoods from Firestore
  Future<void> _fetchUserNeighborhoods() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get the Firebase auth user
      final authUser = auth.FirebaseAuth.instance.currentUser;
      if (authUser == null) {
        throw Exception('No user logged in');
      }

      // Fetch user data from 'users' collection
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(authUser.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User document not found');
      }

      final userData = userDoc.data();

      // Extract neighborhoods from user data
      final neighborhoodData = userData?['neighborhoodId'];
      if (neighborhoodData is List) {
        _userNeighborhoods = neighborhoodData
            .map((value) => value.toString())
            .where((value) => value.isNotEmpty)
            .toList();
      } else if (neighborhoodData is String && neighborhoodData.isNotEmpty) {
        _userNeighborhoods = [neighborhoodData];
      } else {
        _userNeighborhoods = [];
      }
    } catch (e) {
      _error = 'Failed to load neighborhoods: $e';
      print('Error in NeighborhoodSelectionModel: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to set the current neighborhood by swapping it to the first position
  Future<void> setCurrentNeighborhood(String neighborhood) async {
    try {
      _error = null;
      notifyListeners();

      final authUser = auth.FirebaseAuth.instance.currentUser;
      if (authUser == null) {
        throw Exception('No user logged in');
      }

      // Verify the neighborhood exists in user's neighborhoods
      if (!_userNeighborhoods.contains(neighborhood)) {
        throw Exception('Neighborhood not found in user neighborhoods');
      }

      // Don't do anything if it's already the first element
      if (_userNeighborhoods.first == neighborhood) {
        return;
      }

      // Create a new list with the selected neighborhood moved to first position
      final List<String> updatedNeighborhoods = [neighborhood];
      for (final hood in _userNeighborhoods) {
        if (hood != neighborhood) {
          updatedNeighborhoods.add(hood);
        }
      }

      // Update local state
      _userNeighborhoods = updatedNeighborhoods;

      // Update Firestore with the reordered neighborhoodId array
      await FirebaseFirestore.instance
          .collection('users')
          .doc(authUser.uid)
          .update({'neighborhoodId': _userNeighborhoods});

      // ADD: Call the callback to notify about neighborhood change
      _onNeighborhoodChanged?.call();

      notifyListeners();
    } catch (e) {
      _error = 'Failed to set current neighborhood: $e';
      print('Error setting current neighborhood: $e');
      notifyListeners();
      rethrow;
    }
  }

  // Get the current neighborhood (first element in the list)
  String? get currentNeighborhood {
    return _userNeighborhoods.isNotEmpty ? _userNeighborhoods.first : null;
  }

  // Refresh neighborhoods data
  Future<void> refresh() async {
    await _fetchUserNeighborhoods();
  }
}
