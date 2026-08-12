import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final userModel = await remoteDataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userModel?.toEntity();
  }

  @override
  Future<UserEntity?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final userModel = await remoteDataSource.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
    return userModel?.toEntity();
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return remoteDataSource.authStateChanges.map(
      (userModel) => userModel?.toEntity(),
    );
  }
}
