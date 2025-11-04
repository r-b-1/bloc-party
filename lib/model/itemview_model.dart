// lib/model/itemview_model.dart
import 'package:flutter/foundation.dart';
import 'package:blocparty/model/item_model.dart';
import 'package:blocparty/model/login_model/auth_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemViewModel extends ChangeNotifier {
  List<Item> items = [];
  bool isLoading = false;
  final AuthViewModel _authViewModel;

  ItemViewModel(this._authViewModel) {
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
          await FirebaseFirestore.instance.collection('items').get();

      items = snapshot.docs.map((doc) => Item.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching items: $e');
      // Keep empty list on error
    } finally {
      isLoading = false;
      notifyListeners(); // Update the UI
    }
  }

  @override
  void dispose() {
    _authViewModel.removeListener(_onAuthChanged);
    super.dispose();
  }
}
