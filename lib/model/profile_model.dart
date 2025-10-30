import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:blocparty/model/user_model.dart';
import 'package:blocparty/model/item_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_places_autocomplete_widgets/address_autocomplete_widgets.dart';

class ProfileViewModel extends ChangeNotifier {
  AddUser? _currentUser;
  List<Item> _userItems = [];
  bool _isLoading = true;
  String? _error;

  AddUser? get currentUser => _currentUser;
  List<Item> get userItems => _userItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProfileViewModel() {
    _fetchUserDataAndItems();
  }

  Future<void> _fetchUserDataAndItems() async {
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

      // Store custom user data
      _currentUser = AddUser.fromFirestore(userDoc);

      // Fetch items from 'items' collection where userId matches username
      final itemsSnapshot = await FirebaseFirestore.instance
          .collection('items')
          .where('userId', isEqualTo: _currentUser!.username)
          .get();

      _userItems = itemsSnapshot.docs
          .map((doc) => Item.fromFirestore(doc))
          .toList();
    } catch (e) {
      _error = 'Failed to load profile: $e';
      print('Error in ProfileViewModel: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOutUser() async {
    await auth.FirebaseAuth.instance.signOut();
  }

  // Add this method to create new items
  Future<void> addItem({
    required String name,
    required String description,
    required ItemPortability portability,
    required List<String> tags,
  }) async {
    try {
      _error = null;
      notifyListeners();

      if (_currentUser == null) {
        throw Exception('No user logged in');
      }

      // Creating a new document in firestore
      final docRef = FirebaseFirestore.instance.collection('items').doc();

      // Creating the item
      final newItem = Item(
        id: docRef.id,
        name: name,
        description: description,
        isAvailable: true,
        userId: _currentUser!.username,
        neighborhoodId: 'defualt',
        portability: portability,
        tags: tags,
      );

      // Saving to Firestore
      await docRef.set(newItem.toFirestore());

      // Adding item to local list and update UI
      _userItems.add(newItem);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add item: $e';
      print('Error adding item: $e');
      notifyListeners();
      rethrow;
    }
  }

  // Adding method to delete items
  Future<void> deleteItem(String itemId) async {
    try {
      _error = null;
      notifyListeners();

      if (_currentUser == null) {
        throw Exception('No user logged in');
      }

      await FirebaseFirestore.instance.collection('items').doc(itemId).delete();

      _userItems.removeWhere((item) => item.id == itemId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete item: $e';
      print('Error deleting item: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refresh() async {
    await _fetchUserDataAndItems();
  }
}

class Name extends StatelessWidget {
  final TextEditingController controller;
  final String labelName;
  const Name({
    super.key,
    required this.controller,
    required this.labelName,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: labelName),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelName' ;
        }
        return null;
      },
    );
  }
}

class Address extends StatelessWidget {
  final TextEditingController controller;
  final String labelName;
  const Address({
    super.key,
    required this.controller,
    required this.labelName,
  }
  
  );

  @override
  Widget build(BuildContext context) {
    return AddressAutocompleteTextField(
      mapsApiKey: googleMapsApiKey,
      controller: controller,
      decoration: InputDecoration(labelText: labelName),
      onSuggestionClick: (place) {
        controller.text = place.formattedAddress ?? '';
      },
    );
  }
}
 


