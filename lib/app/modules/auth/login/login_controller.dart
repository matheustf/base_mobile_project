// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:clickquartos_mobile/app/core/exceptions/failure.dart';
import 'package:clickquartos_mobile/app/core/exceptions/user_not_exists_exception.dart';
import 'package:clickquartos_mobile/app/core/ui/widgets/loader.dart';
import 'package:clickquartos_mobile/app/core/ui/widgets/messages.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';

import 'package:clickquartos_mobile/app/core/logger/app_logger.dart';
import 'package:clickquartos_mobile/app/services/user/user_service.dart';

part 'login_controller.g.dart';

class LoginController = LoginControllerBase with _$LoginController;

abstract class LoginControllerBase with Store {
  final UserService _userService;
  final AppLogger _log;

  LoginControllerBase({
    required UserService userService,
    required AppLogger log,
  })  : _userService = userService,
        _log = log;

  Future<void> login(String login, String password) async {
    try {
      Loader.show();
      await _userService.login(login, password);
      Loader.hide();
      Modular.to.navigate('/auth/');
    } on Failure catch (e, s) {
      final errorMessage = e.message ?? 'Erro ao realizar login';
      _log.error(errorMessage, e, s);
      Loader.hide();
      Messages.alert(errorMessage);
    } on UserNotExistsException {
      const errorMessage = 'Usuârio não cadastrado';
      _log.error(errorMessage);
      Loader.hide();
      Messages.alert(errorMessage);
    }
  }
}
