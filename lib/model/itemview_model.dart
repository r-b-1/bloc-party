// lib/model/itemview_model.dart
import 'package:flutter/foundation.dart';
import 'package:blocparty/model/item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemViewModel extends ChangeNotifier {
  List<Item> items = [];

  ItemViewModel() {
    fetchItems();
  }

  void fetchItems() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('items').get();

      items = snapshot.docs.map((doc) => Item.fromFirestore(doc)).toList();

      notifyListeners(); // Update the UI
    } catch (e) {
      print('Error fetching items: $e');
      // Keep empty list on error
    }
  }
}
