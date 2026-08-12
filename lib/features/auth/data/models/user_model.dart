import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.role = 'employee', // Forward role to super entity
  });

  // Factory constructor to construct model from Firebase User
  factory UserModel.fromFirebaseUser(
    firebase.User user, {
    String role = 'employee',
  }) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      role: role,
    );
  }

  // Convert to entity
  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      role: role,
    );
  }

  // To JSON Map (useful for saving user details in Firestore)
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role,
    };
  }

  // From JSON Map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      role: json['role'] ?? 'employee',
    );
  }
}
