import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String neighborhoodId;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.neighborhoodId,
  });

  Map<String, dynamic> toFirestore() {
    return {'name': name, 'email': email, 'neighborhoodId': neighborhoodId};
  }

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (!doc.exists) {
      throw Exception('Document does not exist');
    }
    final data = doc.data();
    if (data == null) {
      throw Exception('Document data is null');
    }

    return AppUser(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      neighborhoodId: data['neighborhoodId'] ?? '',
    );
  }
}
