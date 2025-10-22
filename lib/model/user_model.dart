class User {
  final String id;
  final String name;
  final String email;
  final String address;
  final String? address2;
  final String? phonenumber;

  User({required this.id, required this.name, required this.email, required this.address, this.address2, this.phonenumber});
}
