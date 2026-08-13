import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/rendering.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> signOut();

  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firebasestore = FirebaseFirestore.instance;

  AuthRemoteDataSourceImpl({firebase.FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? firebase.FirebaseAuth.instance;

  // Helper method to fetch role from Firestore
  Future<String> _getUserRole(String uid) async {
    try {
      final doc = await _firebasestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()?['role'] ?? 'employee';
      }
    } catch (e) {
      debugPrint('Print Fetching user role: $e');
    }
    return 'employee'; //default fallback
  }

  @override
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        final doc = await _firebasestore.collection('users').doc(credential.user!.uid).get();
        if (doc.exists && doc.data() != null) {
          final disabled = doc.data()?['disabled'] ?? false;
          if (disabled) {
            await _firebaseAuth.signOut();
            throw firebase.FirebaseAuthException(
              code: 'user-disabled',
              message: 'Your access has been disabled by the admin.',
            );
          }
          final role = doc.data()?['role'] ?? 'employee';
          return UserModel.fromFirebaseUser(credential.user!, role: role);
        }
        return UserModel.fromFirebaseUser(credential.user!, role: 'employee');
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
        // Reload user to sync updated display name
        await credential.user!.reload();
        final updatedUser = _firebaseAuth.currentUser;
        await _firebasestore.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'email': email,
          'displayName': displayName,
          'role': 'employee', // Default new signups to employee
          'photoUrl': updatedUser?.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return UserModel.fromFirebaseUser(
          updatedUser ?? credential.user!,
          role: 'employee',
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user != null) {
        final role = await _getUserRole(user.uid);
        return UserModel.fromFirebaseUser(user, role: role);
      }
      return null;
    });
  }
}
