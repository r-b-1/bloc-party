import 'package:flutter/foundation.dart';
import 'package:blocparty/model/item_model.dart';

class ItemViewModel extends ChangeNotifier {
  // Your logic for managing items will go here.
  // For example, fetching items, adding new items, etc.

  List<Item> items = [];

ItemViewModel() {
  _initializeWithDummyData();
}
  void _initializeWithDummyData() {
    items = [
      Item(
        id: 'dummy_001',
        name: 'Sample Coffee Table',
        description: 'A beautiful wooden coffee table perfect for any living room. Great condition with minor wear.',
        isAvailable: true,
        userId: 'user_123',
        neighborhoodId: 'neighborhood_456',
        portability: ItemPortability.semiPortable,
        tags: ['furniture', 'wooden', 'living room', 'coffee table'],
      ),
      Item(
        id: 'dummy_002',
        name: 'Vintage Bookshelf',
        description: 'Tall wooden bookshelf with 5 shelves. Perfect for organizing books and displaying items.',
        isAvailable: true,
        userId: 'user_456',
        neighborhoodId: 'neighborhood_456',
        portability: ItemPortability.portable,
        tags: ['furniture', 'bookshelf', 'storage', 'vintage'],
      ),
      Item(
        id: 'dummy_003',
        name: 'Garden Tools Set',
        description: 'Complete set of garden tools including shovel, rake, and pruning shears.',
        isAvailable: false,
        userId: 'user_789',
        neighborhoodId: 'neighborhood_789',
        portability: ItemPortability.portable,
        tags: ['tools', 'garden', 'outdoor', 'gardening'],
      ),
    ];
  }

  void fetchItems() {
    //
  }
}
