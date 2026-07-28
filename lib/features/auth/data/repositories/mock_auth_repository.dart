import 'dart:async';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  final StreamController<UserEntity?> _authStateController = StreamController<UserEntity?>.broadcast();
  UserEntity? _currentUser;

  MockAuthRepository() {
    // Start as logged out
    _authStateController.add(null);
  }

  @override
  Future<UserEntity?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Simulate simple password validation for safety
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters long.');
    }

    final displayName = email.split('@').first.toUpperCase();
    _currentUser = UserEntity(
      uid: 'mock_uid_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName,
      photoUrl: null,
    );
    
    _authStateController.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<UserEntity?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters long.');
    }

    _currentUser = UserEntity(
      uid: 'mock_uid_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName,
      photoUrl: null,
    );
    
    _authStateController.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Stream<UserEntity?> get authStateChanges => _authStateController.stream;

  void dispose() {
    _authStateController.close();
  }
}
