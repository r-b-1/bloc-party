import 'package:flutter_test/flutter_test.dart';
import 'package:blocparty/model/item_model.dart';

void main() {
  group('Item Model Tests', () {
    test('Item constructor works correctly', () {
      // Creates a test item with sample data
      final item = Item(
        id: 'test123',
        name: 'Test Drill',
        description: 'Cordless drill for testing',
        isAvailable: true,
        userId: 'user1',
        neighborhoodId: ['neighborhood1'],
        portability: ItemPortability.portable,
        tags: ['tool', 'electric'],
        imagePath: 'images/drill.jpg',
      );

      // Checks that all properties are stored correctly
      expect(item.id, 'test123');
      expect(item.name, 'Test Drill');
      expect(item.description, 'Cordless drill for testing');
      expect(item.isAvailable, true);
      expect(item.userId, 'user1');
      expect(item.neighborhoodId.first, 'neighborhood1');
      expect(item.portability, ItemPortability.portable);
      expect(item.tags, contains('tool'));
      expect(item.tags, contains('electric'));
      expect(item.imagePath, 'images/drill.jpg');
    });

    test('Item.toFirestore creates correct map', () {
      // Creates an item to test the toFirestore method
      final item = Item(
        id: 'firestore123',
        name: 'Firestore Test',
        description: 'Testing toFirestore',
        isAvailable: false,
        userId: 'testuser',
        neighborhoodId: ['hood1', 'hood2'],
        portability: ItemPortability.semiPortable,
        tags: ['test', 'sample'],
        imagePath: 'test.jpg',
      );

      // Converts the item to Firestore 
      final firestoreData = item.toFirestore();

      // Verifies the firestore item contains all the correct data
      expect(firestoreData['name'], 'Firestore Test');
      expect(firestoreData['description'], 'Testing toFirestore');
      expect(firestoreData['isAvailable'], false);
      expect(firestoreData['userId'], 'testuser');
      expect(firestoreData['neighborhoodId'], ['hood1', 'hood2']);
      expect(firestoreData['portability'], 'semiPortable');
      expect(firestoreData['tags'], ['test', 'sample']);
      expect(firestoreData['imagePath'], 'test.jpg');
      expect(firestoreData.containsKey('id'), false);
    });

    test('ItemPortability enum parsing works', () {
      // Tests that the values have the correct string names
      expect(ItemPortability.portable.name, 'portable');
      expect(ItemPortability.semiPortable.name, 'semiPortable');
      expect(ItemPortability.immovable.name, 'immovable');

      // Tests that we can look up values by name
      expect(ItemPortability.values.byName('portable'), ItemPortability.portable);
      expect(ItemPortability.values.byName('semiPortable'), ItemPortability.semiPortable);
      expect(ItemPortability.values.byName('immovable'), ItemPortability.immovable);
    });

    test('Item with empty lists works', () {
      // Tests that items can be created with empty collections
      final item = Item(
        id: 'empty',
        name: 'Empty Item',
        description: 'Item with empty collections',
        isAvailable: true,
        userId: 'user2',
        neighborhoodId: [],
        portability: ItemPortability.immovable,
        tags: [],
        imagePath: '',
      );

      // Verifies the empty collections work correctly
      expect(item.neighborhoodId, isEmpty);
      expect(item.tags, isEmpty);
      expect(item.imagePath, '');
    });
  });
}