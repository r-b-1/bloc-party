import 'package:cloud_firestore/cloud_firestore.dart';

enum ItemPortability { portable, semiPortable, immovable }

class Item {
  final String id;
  final String name;
  final String description;
  final bool isAvailable;
  final String userId;
  final List<String> neighborhoodId;
  final ItemPortability portability;
  final List<String> tags;
  final String imagePath;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.isAvailable,
    required this.userId,
    required this.neighborhoodId,
    required this.portability,
    required this.tags,
    required this.imagePath,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'isAvailable': isAvailable,
      'userId': userId,
      'neighborhoodId': neighborhoodId,
      'portability': portability.name,
      'tags': tags,
      'imagePath': imagePath,
    };
  }

  factory Item.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (!doc.exists) {
      throw Exception('Document does not exist');
    }
    final data = doc.data();
    if (data == null) {
      throw Exception('Document data is null');
    }

    // Defensive parsing for portability enum
    final portabilityValue = data['portability'];
    ItemPortability portability;
    if (portabilityValue is String) {
      try {
        portability = ItemPortability.values.byName(portabilityValue);
      } catch (e) {
        portability = ItemPortability.portable;
      }
    } else {
      portability = ItemPortability.portable;
    }

    // Defensive casting for tags
    final tagsData = data['tags'];
    List<String> tags;
    if (tagsData is List) {
      tags = tagsData.map((e) => e.toString()).toList();
    } else {
      tags = [];
    }

    return Item(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      isAvailable: data['isAvailable'] ?? false,
      userId: data['userId'] ?? '',
      neighborhoodId: data['neighborhoodId'] ?? '',
      portability: portability,
      tags: tags,
      imagePath: data['imagePath'] ?? '',
    );
  }
}
