// lib/model/itemview_model.dart
import 'package:flutter/foundation.dart';
import 'package:blocparty/model/neighborhood_model.dart';
import 'package:blocparty/model/auth_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NeighborhoodViewModel extends ChangeNotifier {
  List<Neighborhood> neighborhoods = [];
  bool isLoading = false;
  String ?_error;
  final AuthViewModel _authViewModel;

  NeighborhoodViewModel(this._authViewModel) {
    _authViewModel.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  void _onAuthChanged() {
    if (_authViewModel.isSignedIn) {
      fetchNeighborhoods();
    }
  }

  void fetchNeighborhoods() async {
    isLoading = true;
    notifyListeners();
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('neighborhood').get();

      neighborhoods = snapshot.docs.map((doc) => Neighborhood.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching neighborhoods: $e');
      // Keep empty list on error
    } finally {
      isLoading = false;
      notifyListeners(); // Update the UI
    }
  }

  // Add this method to create new items
  Future<void> addNeighborhood({
    required String neighborhoodId,
    required List<String> neighborhoodUsers,
  }) async {
    try {
      _error = null;
      notifyListeners();

      /*if (_currentUser == null) {
        throw Exception('No user logged in');
      }*/

      // Creating a new document in firestore
      final docRef = FirebaseFirestore.instance.collection('neighborhood').doc();

      // Creating the item
      final newNeighborhood = Neighborhood(
        neighborhoodId: "neighborhood",
        neighborhoodUsers: ["temp", "temp2"],
      );

      // Saving to Firestore
      await docRef.set(newNeighborhood.toFirestore());

      // Adding item to local list and update UI
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add item: $e';
      print('Error adding item: $e');
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _authViewModel.removeListener(_onAuthChanged);
    super.dispose();
  }
}
