class ContactModel {
  const ContactModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.position,
    this.department,
  });

  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? position;
  final String? department;

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      position: json['position'] as String?,
      department: json['department'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      if (email != null) 'email': email,
      if (position != null) 'position': position,
      if (department != null) 'department': department,
    };
  }
}
