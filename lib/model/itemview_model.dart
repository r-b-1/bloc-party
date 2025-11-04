// lib/model/itemview_model.dart
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:blocparty/model/item_model.dart';
import 'package:blocparty/model/auth_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemViewModel extends ChangeNotifier {
  List<Item> items = [];
  bool isLoading = false;
  final AuthViewModel _authViewModel;

  // Filter state properties
  String _searchText = '';
  List<String> _selectedTags = [];


  String get searchText => _searchText;
  List<String> get selectedTags => UnmodifiableListView(_selectedTags);

  ItemViewModel(this._authViewModel) {
    _authViewModel.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  void _onAuthChanged() {
    // Clear items immediately if user is null to avoid showing stale items
    if (_authViewModel.user == null) {
      items = [];
      notifyListeners();
    }

    fetchItems();
  }

  List<Item> get filteredItems {
    List<Item> filtered = items;


    if (_searchText.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.name.toLowerCase().contains(_searchText.toLowerCase());
      }).toList();
    }

    if (_selectedTags.isNotEmpty) {
      filtered = filtered.where((item) {
        return _selectedTags.every((tag) => item.tags.contains(tag));
      }).toList();
    }

    return filtered;
  }

  List<String> getAvailableTags() {
    Set<String> uniqueTags = {};
    for (var item in items) {
      uniqueTags.addAll(item.tags);
    }
    return uniqueTags.toList();
  }

  // Update search text
  void updateSearchText(String searchText) {
    _searchText = searchText;
    notifyListeners();
  }

  // Update selected tags
  void updateSelectedTags(List<String> tags) {
    _selectedTags = tags;
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _searchText = '';
    _selectedTags = [];
    notifyListeners();
  }

  // Guard selected tags against becoming stale after items are updated
  void _guardSelectedTags() {
    final available = getAvailableTags().toSet();
    final filteredSelected = _selectedTags
        .where((tag) => available.contains(tag))
        .toList();
    if (filteredSelected.length != _selectedTags.length) {
      _selectedTags = filteredSelected;
      notifyListeners();
    }
  }

  void fetchItems() async {
    isLoading = true;
    notifyListeners();
    try {
      // Get the current user
      final user = _authViewModel.user;
      if (user == null) {
        items = [];
        _guardSelectedTags();
        isLoading = false;
        notifyListeners();
        return;
      }

      // Always fetch user's neighborhoodId to ensure we get the latest value
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final neighborhoodId = userDoc.data()?['neighborhoodId'] as String?;

      // If user hasn't selected a neighborhood yet, return empty list
      if (neighborhoodId == null) {
        items = [];
        _guardSelectedTags();
        isLoading = false;
        notifyListeners();
        return;
      }

      // Query items filtered by neighborhoodId
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('items')
              .where('neighborhoodId', isEqualTo: neighborhoodId)
              .get();

      items = snapshot.docs.map((doc) => Item.fromFirestore(doc)).toList();

      // Guard selected tags against becoming stale after a refresh/fetch
      _guardSelectedTags();
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
