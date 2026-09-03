/// Matches the `delivery_man` shape returned by the backend
/// (`{id, name, phone_number, is_active}`).
class Driver {
  const Driver({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.isActive,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
        id: json['id'] as int,
        name: json['name'] as String,
        phoneNumber: json['phone_number'] as String,
        isActive: json['is_active'] as bool,
      );

  final int id;
  final String name;
  final String phoneNumber;
  final bool isActive;
}
