import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmployeeModel {
  final String email;
  final String password;
  final bool isEnabled;

  EmployeeModel({
    required this.email,
    required this.password,
    required this.isEnabled,
  });

  EmployeeModel copyWith({
    String? email,
    String? password,
    bool? isEnabled,
  }) {
    return EmployeeModel(
      email: email ?? this.email,
      password: password ?? this.password,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

class EmployeeListNotifier extends StateNotifier<List<EmployeeModel>> {
  EmployeeListNotifier() : super(_generateInitialEmployees());

  void addEmployee(String email, String password) {
    state = [
      ...state,
      EmployeeModel(email: email, password: password, isEnabled: true),
    ];
  }

  void toggleEmployeeAccess(String email) {
    state = [
      for (final emp in state)
        if (emp.email == email) emp.copyWith(isEnabled: !emp.isEnabled) else emp
    ];
  }
}

final employeeListProvider = StateNotifierProvider<EmployeeListNotifier, List<EmployeeModel>>((ref) {
  return EmployeeListNotifier();
});

List<EmployeeModel> _generateInitialEmployees() {
  return [
    EmployeeModel(email: 'munawar@os.com', password: 'password123', isEnabled: false),
    EmployeeModel(email: 'sammer@os.com', password: 'password123', isEnabled: false),
    EmployeeModel(email: 'samavia@os.com', password: 'password123', isEnabled: true),
    EmployeeModel(email: 'noorulhude@os.com', password: 'password123', isEnabled: true),
    EmployeeModel(email: 'wajahat@os.com', password: 'password123', isEnabled: false),
    EmployeeModel(email: 'aftab@os.com', password: 'password123', isEnabled: true),
    EmployeeModel(email: 'mujtaba@os.com', password: 'password123', isEnabled: true),
    EmployeeModel(email: 'hammad@os.com', password: 'password123', isEnabled: true),
    EmployeeModel(email: 'seema@os.com', password: 'password123', isEnabled: false),
  ];
}
