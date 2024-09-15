class EmergencyContact {
  final String name;
  final String phone;
  final String email;
  final String image;

  EmergencyContact({
    required this.name,
    required this.phone,
    required this.email,
    required this.image,
  });

  factory EmergencyContact.fromFirestore(Map<String, dynamic> data) {
    return EmergencyContact(
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      image: data['image'] ?? '',
    );
  }
}
