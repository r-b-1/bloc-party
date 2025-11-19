// lib/model/itemview_model.dart
import 'package:blocparty/model/profile_model.dart';
import 'package:flutter/foundation.dart';
import 'package:blocparty/model/neighborhood_model.dart';
import 'package:blocparty/model/login_model/auth_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NeighborhoodViewModel extends ChangeNotifier {
  List<Neighborhood> neighborhoods = [];
  bool isLoading = false;
  String ?_error;
  final AuthViewModel _authViewModel;
  final ProfileViewModel _profileViewModel;

  NeighborhoodViewModel(this._authViewModel, this._profileViewModel) {
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

    //dont fetch neighborhoods that the current user is in? or or maybe make them unjoinable
    String currentUser = _authViewModel.user!.uid;

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('neighborhood').get();

      neighborhoods = snapshot.docs.map((doc) => Neighborhood.fromFirestore(doc)).toList();
      //removes all neighborhoods that has the current user in them
      for(String userNeighborhood in _profileViewModel.neighborhoods){
        neighborhoods.removeWhere(((x) => x.neighborhoodId == userNeighborhood));
      }

    } catch (e) {
      print('Error fetching neighborhoods: $e');
      // Keep empty list on error
    } finally {
      isLoading = false;
      notifyListeners(); // Update the UI
    }
  }

  // Add this method to create new items
  Future<void> addNeighborhood({required String neighborhoodIdToAdd,}) async {
    try {
      _error = null;
      isLoading = true;
      notifyListeners();

      /*if (_currentUser == null) {
        throw Exception('No user logged in');
      }*/

      // Creating a new document in firestore
      final docRef = FirebaseFirestore.instance.collection('neighborhood').doc();

      final QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('neighborhood').get();

      neighborhoods = snapshot.docs.map((doc) => Neighborhood.fromFirestore(doc)).toList();

      // Creating the item
      final newNeighborhood = Neighborhood(
        neighborhoodId: neighborhoodIdToAdd,
      );
      


      // Saving to Firestore
      await docRef.set(newNeighborhood.toFirestore());

      //join the neighborhood that is created
      joinNeighborhood(neighborhoodIdToJoin: neighborhoodIdToAdd);

      // Adding item to local list and update UI
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add item: $e';
      print('Error adding item: $e');
      notifyListeners();
      rethrow;
    }
  }



  // Add this method to create new items
  Future<void> joinNeighborhood({required String neighborhoodIdToJoin,}) async {
    try {
      _error = null;

      isLoading = true;
      notifyListeners();
      /*if (_currentUser == null) {
        throw Exception('No user logged in');
      }*/

      if(!_profileViewModel.neighborhoods.contains(neighborhoodIdToJoin)){
        // Creating a new document in firestore
        final docRef = FirebaseFirestore.instance.collection('users').doc(_authViewModel.user!.uid);

        //adds the neighborhoods to the users list of neighborhoods
        
        _profileViewModel.neighborhoods.add(neighborhoodIdToJoin);

        // set the current neighborhood
        await docRef.update({'neighborhoodId': _profileViewModel.neighborhoods,});

        // Adding item to local list and update UI
        isLoading = false;
      }
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
