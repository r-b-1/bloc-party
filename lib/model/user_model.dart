import 'package:cloud_firestore/cloud_firestore.dart';

class AddUser {
  final String username;
  final String name;
  final String email;
  final String address;
  final String? address2;
  final String? phonenumber;

  final String? neighborhoodId;

  AddUser({
    required this.username,
    required this.name,
    required this.email,
    required this.address,
    this.address2,
    this.phonenumber,
    this.neighborhoodId,
  });

  factory AddUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (!doc.exists) {
      throw Exception('Document does not exist');
    }
    final data = doc.data();
    if (data == null) {
      throw Exception('Document data is null');
    }

    return AddUser(
      username: data['username'] ?? '',
      name: data['fullName'] ?? '',
      email: data['email'] ?? '',
      address: data['mainAddress'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'fullName': name,
      'mainAddress': address,
      'email': email,
      if (address2 != null) 'address2': address2,
      if (phonenumber != null) 'phonenumber': phonenumber,
      if (neighborhoodId != null) 'neighborhoodId': neighborhoodId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  
}
