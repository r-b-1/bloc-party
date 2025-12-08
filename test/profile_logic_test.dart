import 'package:flutter_test/flutter_test.dart';
import 'package:blocparty/model/item_model.dart';

void main() {
  group('Profile Logic Tests', () {
    test('Item availability toggle creates correct new item', () {
      // Creates an item to test availability toggling
      final originalItem = Item(
        id: 'item123',
        name: 'Original Item',
        description: 'Original description',
        isAvailable: true,
        userId: 'owner1',
        neighborhoodId: ['neighborhood1'],
        portability: ItemPortability.portable,
        tags: ['tool'],
        imagePath: 'image.jpg',
      );

      // Simulates toggling availability from true to false
      final toggledItem = Item(
        id: originalItem.id,
        name: originalItem.name,
        description: originalItem.description,
        isAvailable: false, // This gets toggled
        userId: originalItem.userId,
        neighborhoodId: originalItem.neighborhoodId,
        portability: originalItem.portability,
        tags: originalItem.tags,
        imagePath: originalItem.imagePath,
      );

      // Checks that availability was correctly toggled
      expect(originalItem.isAvailable, true);
      expect(toggledItem.isAvailable, false);
      
      // Checks that all other properties stayed the same
      expect(toggledItem.id, originalItem.id);
      expect(toggledItem.name, originalItem.name);
      expect(toggledItem.userId, originalItem.userId);
      expect(toggledItem.tags, originalItem.tags);
    });

    test('Address validation helper functions', () {
      // Helper function to validate addresses
      bool isValidAddress(String address) {
        final trimmed = address.trim();
        return trimmed.isNotEmpty && trimmed.length >= 3;
      }

      // Helper function to check for duplicate addresses
      bool isDuplicateAddress(String newAddress, List<String> existingAddresses) {
        return existingAddresses.any((addr) => addr == newAddress.trim());
      }

      // Tests address validation
      expect(isValidAddress(''), false);
      expect(isValidAddress('   '), false);
      expect(isValidAddress('ab'), false); // Too short
      expect(isValidAddress('123 Main St'), true);
      expect(isValidAddress('456 Oak Ave'), true);

      // Tests duplicate address detection
      final addresses = ['123 Main St', '456 Oak Ave'];
      expect(isDuplicateAddress('123 Main St', addresses), true);
      expect(isDuplicateAddress('  123 Main St  ', addresses), true); // With spaces
      expect(isDuplicateAddress('789 New St', addresses), false);
    });

    test('Item filtering excludes current user items', () {
      // Simulates filtering logic from ItemViewModel
      final currentUser = 'current_user';
      
      // Creates a mix of items from current user and other users
      final items = [
        Item(
          id: '1',
          name: 'User\'s Item',
          description: 'Desc',
          isAvailable: true,
          userId: currentUser, // Same as current user
          neighborhoodId: ['neighborhood1'],
          portability: ItemPortability.portable,
          tags: [],
          imagePath: '',
        ),
        Item(
          id: '2',
          name: 'Other User Item',
          description: 'Desc',
          isAvailable: true,
          userId: 'other_user', // Different user
          neighborhoodId: ['neighborhood1'],
          portability: ItemPortability.portable,
          tags: [],
          imagePath: '',
        ),
      ];

      // Filters out current user's items 
      final filtered = items.where((item) => item.userId != currentUser).toList();

      // Checks that only other user's items remain
      expect(filtered.length, 1);
      expect(filtered[0].userId, 'other_user');
      expect(filtered[0].name, 'Other User Item');
    });
  });
}