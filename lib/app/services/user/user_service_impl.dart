// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:clickquartos_mobile/app/core/exceptions/failure.dart';
import 'package:clickquartos_mobile/app/core/exceptions/user_exists_exception.dart';
import 'package:clickquartos_mobile/app/core/exceptions/user_not_exists_exception.dart';
import 'package:clickquartos_mobile/app/core/helpers/constants.dart';
import 'package:clickquartos_mobile/app/core/local_storage/local_storage.dart';
import 'package:clickquartos_mobile/app/core/logger/app_logger.dart';
import 'package:clickquartos_mobile/app/repositories/social/social_repository.dart';
import 'package:clickquartos_mobile/app/repositories/user/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'user_service.dart';

class UserServiceImpl implements UserService {
  final UserRepository _userRepository;
  final AppLogger _log;
  final LocalStorage _localStorage;
  final LocalSecureStorage _localSecureStorage;

  UserServiceImpl({
    required UserRepository userRepository,
    required AppLogger log,
    required LocalStorage localStorage,
    required LocalSecureStorage localSecureStorage,
  })  : _userRepository = userRepository,
        _log = log,
        _localStorage = localStorage,
        _localSecureStorage = localSecureStorage;

  @override
  Future<void> register(String email, String password) async {
    try {
      final firebaseAuh = FirebaseAuth.instance;

      final userMethods = await firebaseAuh.fetchSignInMethodsForEmail(email);

      if (userMethods.isNotEmpty) {
        throw UserExistsException();
      }

      await _userRepository.register(email, password);

      final userRegisterCredential = await firebaseAuh
          .createUserWithEmailAndPassword(email: email, password: password);

      await userRegisterCredential.user?.sendEmailVerification();
    } on FirebaseException catch (e, s) {
      _log.error('Erro ao criar usuário no firebase', e, s);
      throw Failure(message: 'Erro ao criar usuário');
    }
  }

  @override
  Future<void> login(String email, String password) async {
    try {
      final firebaseAuth = FirebaseAuth.instance;

      final loginMethods = await firebaseAuth.fetchSignInMethodsForEmail(email);

      if (loginMethods.isEmpty) {
        throw UserNotExistsException();
      }

      if (loginMethods.contains('password')) {
        final userCredential = await firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password);

        final userVerified = userCredential.user?.emailVerified ?? false;

        if (!userVerified) {
          await userCredential.user?.sendEmailVerification();
          throw Failure(
              message:
                  'E-mail não confirmado, por favor verifique sua caixa de spam');
        }

        final accessToken = await _userRepository.login(email, password);

        await _saveAccessToken(accessToken);

        await _confirmLogin();

        await _getUserData();
      } else {
        throw Failure(
            message:
                'Login não pode ser feito por e-mail e password, por favor utilize outro método');
      }
    } on FirebaseException catch (e, s) {
      _log.error(
          'Usuário ou senha inválidos FirebaseAuthError [${e.code}]', e, s);
      throw Failure(message: 'Usuário ou senha inválidos!!!');
    }
  }

  Future<void> _saveAccessToken(String accessToken) => _localStorage.write(
      Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY, accessToken);

  Future<void> _confirmLogin() async {
    final confirmLoginModel = await _userRepository.confirmLogin();
    await _saveAccessToken(confirmLoginModel.accessToken);
    await _localSecureStorage.write(Constants.LOCAL_STORAGE_REFRESH_TOKEN_KEY,
        confirmLoginModel.refreshToken);
  }

  Future<void> _getUserData() async {
    final userModel = await _userRepository.getUserLogged();

    await _localStorage.write(
        Constants.LOCAL_STORAGE_USE_LOGGED_DATA_KEY, userModel.toJson());
  }


}
