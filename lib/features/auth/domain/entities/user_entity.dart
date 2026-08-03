class UserEntity {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String role; // 'admin' or 'employee'

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.role = 'employee',
  });
}
