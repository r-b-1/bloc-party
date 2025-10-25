import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String username;
  final String name;
  final String email;
  final String address;
  final String? address2;
  final String? phonenumber;

  final String? neighborhoodId;

  User({required this.username, required this.name, required this.email, required this.address, this.address2, this.phonenumber, this.neighborhoodId});


  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (!doc.exists) {
      throw Exception('Document does not exist');
    }
    final data = doc.data();
    if (data == null) {
      throw Exception('Document data is null');
    }

    return User(
      username: data['username'] ?? '',
      name: data['fullName'] ?? '',
      email: data['email'] ?? '',
      address:  data['mainAddress'] ?? '',
    );
  }
}
