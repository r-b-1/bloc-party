import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blocparty/model/item_model.dart';
import 'package:blocparty/flutter_backend/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  // Initialize Flutter bindings and Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print('=== Firebase Create, Read, and Delete Test ===\n');

  // Test constants
  const String testItemName = 'Test Car';
  const String testUserId = 'test_user';
  const String testImagePath = 'assets/images/pink_car.jpg';
  String testItemId = '';

  try {
    // Step 1: Create a test car item in Firebase
    print('--- Step 1: Creating car item in Firebase ---');
    final docRef = FirebaseFirestore.instance.collection('items').doc();

    final testCarItem = Item(
      id: docRef.id,
      name: testItemName,
      description: 'A test car item for integration testing',
      isAvailable: true,
      userId: testUserId,
      neighborhoodId: ['test_neighborhood'],
      portability: ItemPortability.immovable,
      tags: ['vehicle', 'car', 'test'],
      imagePath: testImagePath,
    );

    // Save to Firestore
    await docRef.set(testCarItem.toFirestore());
    testItemId = docRef.id;

    if (testItemId.isEmpty) {
      throw Exception('Item ID should be generated');
    }
    print('✓ Created car item with ID: $testItemId\n');

    // Step 2: Read and verify the car item exists in Firebase
    print('--- Step 2: Verifying car item exists in Firebase ---');

    // Wait a moment for Firestore to sync
    await Future.delayed(const Duration(milliseconds: 500));

    // Fetch the item from Firestore
    final docSnapshot = await FirebaseFirestore.instance
        .collection('items')
        .doc(testItemId)
        .get();

    // Verify the document exists
    if (!docSnapshot.exists) {
      throw Exception('Car item should exist in Firebase after creation');
    }

    // Parse the item from Firestore
    final retrievedItem = Item.fromFirestore(docSnapshot);

    // Verify all properties match
    if (retrievedItem.id != testItemId) {
      throw Exception('Retrieved item ID should match created item ID');
    }
    if (retrievedItem.name != testItemName) {
      throw Exception('Retrieved item name should match');
    }
    if (retrievedItem.userId != testUserId) {
      throw Exception('Retrieved item userId should match');
    }
    if (!retrievedItem.isAvailable) {
      throw Exception('Retrieved item should be available');
    }
    if (retrievedItem.portability != ItemPortability.immovable) {
      throw Exception('Retrieved item portability should match');
    }
    if (!retrievedItem.tags.contains('car')) {
      throw Exception('Retrieved item tags should contain "car"');
    }
    if (retrievedItem.imagePath != testImagePath) {
      throw Exception('Retrieved item image path should match');
    }

    print(
      '✓ Verified car item exists and all properties match expected values\n',
    );

    // Step 3: Delete the car item from Firebase
    print('--- Step 3: Deleting car item from Firebase ---');
    await FirebaseFirestore.instance
        .collection('items')
        .doc(testItemId)
        .delete();
    print('✓ Deleted car item from Firebase\n');

    // Step 4: Verify the car item is deleted from Firebase
    print('--- Step 4: Verifying car item is deleted from Firebase ---');

    // Wait a moment for Firestore to sync
    await Future.delayed(const Duration(milliseconds: 500));

    // Try to fetch the deleted item
    final deletedDocSnapshot = await FirebaseFirestore.instance
        .collection('items')
        .doc(testItemId)
        .get();

    // Verify the document does not exist
    if (deletedDocSnapshot.exists) {
      throw Exception('Car item should not exist in Firebase after deletion');
    }

    // Also verify by querying by name and userId
    final querySnapshot = await FirebaseFirestore.instance
        .collection('items')
        .where('name', isEqualTo: testItemName)
        .where('userId', isEqualTo: testUserId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      throw Exception(
        'No items with test name and user ID should exist after deletion',
      );
    }

    print('✓ Verified car item is deleted from Firebase');
    print('\n=== All test steps completed successfully! ===');
  } catch (e) {
    print('\n❌ ERROR: $e');

    // Cleanup: Try to delete the item if it was created
    if (testItemId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('items')
            .doc(testItemId)
            .delete();
        print('✓ Cleaned up test item from Firebase');
      } catch (cleanupError) {
        print('⚠ Warning: Could not clean up test item: $cleanupError');
      }
    }

    exit(1);
  }
}
