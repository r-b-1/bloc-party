import 'package:cloud_firestore/cloud_firestore.dart';

class Neighborhood {
  final String neighborhoodId;
  final List<String> neighborhoodUsers;

  Neighborhood({
    required this.neighborhoodId,
    required this.neighborhoodUsers,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'neighborhood ID': neighborhoodId,
      'user ID': neighborhoodUsers,
    };
  }

  factory Neighborhood.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (!doc.exists) {
      throw Exception('Document does not exist');
    }
    final data = doc.data();
    if (data == null) {
      throw Exception('Document data is null');
    }

    final usersData = data['user ID'];
    List<String> users;
    if (usersData is List) {
      users = usersData.map((e) => e.toString()).toList();
    } else {
      users = [];
    }

    return Neighborhood(
      neighborhoodId: data['neighborhood ID'] ?? '',
      neighborhoodUsers: users,
    );
  }
}
