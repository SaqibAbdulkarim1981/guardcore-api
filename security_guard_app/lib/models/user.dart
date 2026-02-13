
class AppUser {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  DateTime? expiryDate;
  bool isBlocked;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    DateTime? createdAt,
    this.expiryDate,
    this.isBlocked = false,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isExpired => expiryDate != null && DateTime.now().isAfter(expiryDate!);

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    DateTime? expiryDate,
    bool? isBlocked,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      expiryDate: expiryDate ?? this.expiryDate,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}
