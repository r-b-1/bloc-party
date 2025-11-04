// lib/model/itemview_model.dart
import 'package:flutter/foundation.dart';
import 'package:blocparty/model/neighborhood_model.dart';
import 'package:blocparty/model/auth_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NeighborhoodViewModel extends ChangeNotifier {
  List<Neighborhood> neighborhoods = [];
  bool isLoading = false;
  final AuthViewModel _authViewModel;

  NeighborhoodViewModel(this._authViewModel) {
    _authViewModel.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  void _onAuthChanged() {
    if (_authViewModel.isSignedIn) {
      fetchItems();
    }
  }

  void fetchItems() async {
    isLoading = true;
    notifyListeners();
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('neighborhood').get();

      neighborhoods = snapshot.docs.map((doc) => Neighborhood.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching items: $e');
      // Keep empty list on error
    } finally {
      isLoading = false;
      notifyListeners(); // Update the UI
      print('ASDF');
    }
  }

  @override
  void dispose() {
    _authViewModel.removeListener(_onAuthChanged);
    super.dispose();
  }
}
