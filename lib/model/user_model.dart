import 'package:cloud_firestore/cloud_firestore.dart';

const String googleMapsApiKey = 'AIzaSyAkXgT0SlHd93wl19MHrijs7Hz85tA3OzI';

class AddUser {
  final String username;
  final String name;
  final String email;
  final List<String> addresses;
  final String? currentAddress;
  final String? phonenumber;
  final String? neighborhoodId;

  AddUser({
    required this.username,
    required this.name,
    required this.email,
    this.addresses = const [],
    this.currentAddress,
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

    // iterate through addresses list
    final addressesData = data['addresses'];
    List<String> addresses = [];
    if (addressesData is List) {
      addresses = addressesData
          .map((addr) => addr.toString())
          .where((addr) => addr.isNotEmpty)
          .toList();
    } else if (data['mainAddress'] != null) {
      // Makes sure the old address format is saved/works
      addresses.add(data['mainAddress'] as String);
      if (data['additionalAddresses'] is List) {
        addresses.addAll(
          (data['additionalAddresses'] as List)
              .map((addr) => addr.toString())
              .where((addr) => addr.isNotEmpty),
        );
      }
    }

    return AddUser(
      username: data['username'] ?? '',
      name: data['fullName'] ?? '',
      email: data['email'] ?? '',
      addresses: addresses,
      currentAddress: data['currentAddress'] as String?,
      phonenumber: data['phonenumber'] as String?,
      neighborhoodId: data['neighborhoodId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'fullName': name,
      'email': email,
      'addresses': addresses,
      if (currentAddress != null) 'currentAddress': currentAddress,
      if (phonenumber != null) 'phonenumber': phonenumber,
      if (neighborhoodId != null) 'neighborhoodId': neighborhoodId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Helper method to create a copy when updating user information
  AddUser copyWith({
    String? username,
    String? name,
    String? email,
    List<String>? addresses,
    String? currentAddress,
    String? phonenumber,
    String? neighborhoodId,
  }) {
    return AddUser(
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      addresses: addresses ?? this.addresses,
      currentAddress: currentAddress ?? this.currentAddress,
      phonenumber: phonenumber ?? this.phonenumber,
      neighborhoodId: neighborhoodId ?? this.neighborhoodId,
    );
  }
}