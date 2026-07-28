import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/mock_auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';

// Toggle this to true once Firebase is initialized via FlutterFire CLI
const bool useFirebase = false;

final firebaseAuthProvider = Provider<firebase.FirebaseAuth?>((ref) {
  if (!useFirebase) return null;
  try {
    return firebase.FirebaseAuth.instance;
  } catch (e) {
    return null;
  }
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource?>((ref) {
  if (!useFirebase) return null;
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  if (firebaseAuth == null) return null;
  return AuthRemoteDataSourceImpl(firebaseAuth: firebaseAuth);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (useFirebase) {
    final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
    if (remoteDataSource != null) {
      return AuthRepositoryImpl(remoteDataSource: remoteDataSource);
    }
  }
  
  // Fallback to Mock Auth Repository
  final mockRepo = MockAuthRepository();
  ref.onDispose(() => mockRepo.dispose());
  return mockRepo;
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

// Stream provider to expose auth state changes directly
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

class AuthController extends StateNotifier<AsyncValue<UserEntity?>> {
  final LoginUseCase _loginUseCase;
  final AuthRepository _authRepository;

  AuthController({
    required LoginUseCase loginUseCase,
    required AuthRepository authRepository,
  })  : _loginUseCase = loginUseCase,
        _authRepository = authRepository,
        super(const AsyncValue.data(null)) {
    _init();
  }

  void _init() {
    _authRepository.authStateChanges.listen(
      (user) {
        state = AsyncValue.data(user);
      },
      onError: (err, stack) {
        state = AsyncValue.error(err, stack);
      },
    );
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _loginUseCase.call(email: email, password: password);
      state = AsyncValue.data(user);
      return user != null;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<UserEntity?>>((ref) {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(
    loginUseCase: loginUseCase,
    authRepository: authRepository,
  );
});
