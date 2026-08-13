import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmployeeModel {
  final String uid;
  final String email;
  final bool isEnabled;

  EmployeeModel({
    required this.uid,
    required this.email,
    required this.isEnabled,
  });

  EmployeeModel copyWith({
    String? uid,
    String? email,
    bool? isEnabled,
  }) {
    return EmployeeModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

class EmployeeListNotifier extends StateNotifier<List<EmployeeModel>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _subscription;

  EmployeeListNotifier() : super([]) {
    _listenToEmployees();
  }

  void _listenToEmployees() {
    _subscription = _firestore
        .collection('users')
        .where('role', isEqualTo: 'employee')
        .snapshots()
        .listen((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        final disabled = data['disabled'] ?? false;
        return EmployeeModel(
          uid: doc.id,
          email: data['email'] ?? '',
          isEnabled: !disabled,
        );
      }).toList();
      state = list;
    });
  }

  Future<void> addEmployee(String email, String password) async {
    try {
      // 1. Create a secondary Firebase App to create user account without signing out the admin
      final String appName = 'TempEmpApp_${DateTime.now().millisecondsSinceEpoch}';
      final FirebaseApp tempApp = await Firebase.initializeApp(
        name: appName,
        options: Firebase.app().options,
      );

      final FirebaseAuth tempAuth = FirebaseAuth.instanceFor(app: tempApp);
      final UserCredential cred = await tempAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Fetch current Admin's agencyId to satisfy Firestore security rules
      final currentAdminUid = FirebaseAuth.instance.currentUser?.uid;
      String? agencyId;
      if (currentAdminUid != null) {
        final adminDoc = await _firestore.collection('users').doc(currentAdminUid).get();
        agencyId = adminDoc.data()?['agencyId'];
      }

      // 3. Set employee user document with all required schema fields using the default Admin session
      final employeeData = {
        'uid': cred.user!.uid,
        'email': email,
        'displayName': email.split('@')[0],
        'role': 'employee',
        'photoUrl': null,
        'disabled': false,
        'isEnabled': true,
        'agencyId': agencyId ?? "o6wySfBbV3yMivNZ32Hp",
        'createdBy': currentAdminUid ?? "admin",
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Write directly via default Admin session
      await _firestore.collection('users').doc(cred.user!.uid).set(employeeData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleEmployeeAccess(String uid, bool currentStatus) async {
    try {
      // If currentStatus (isEnabled) was true, we want to disable them (disabled: true)
      // If currentStatus (isEnabled) was false, we want to enable them (disabled: false)
      await _firestore.collection('users').doc(uid).update({'disabled': currentStatus});
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final employeeListProvider =
    StateNotifierProvider<EmployeeListNotifier, List<EmployeeModel>>((ref) {
  return EmployeeListNotifier();
});
