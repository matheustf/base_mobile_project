// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:clickquartos_mobile/app/core/exceptions/user_exists_exception.dart';
import 'package:clickquartos_mobile/app/core/ui/widgets/loader.dart';
import 'package:clickquartos_mobile/app/core/ui/widgets/messages.dart';
import 'package:mobx/mobx.dart';

import 'package:clickquartos_mobile/app/core/logger/app_logger.dart';
import 'package:clickquartos_mobile/app/services/user/user_service.dart';

part 'register_controller.g.dart';

class RegisterController = RegisterControllerBase with _$RegisterController;

abstract class RegisterControllerBase with Store {
  final UserService _userService;
  final AppLogger _log;
  RegisterControllerBase({
    required UserService userService,
    required AppLogger log,
  })  : _userService = userService,
        _log = log;

  void register({required String email, required String password}) async {
    try {
      Loader.show();
      await _userService.register(email, password);
      Messages.info('Enviamos um e-mail de confirmação, por favor olhe sua caixa de e-mail');
      Loader.hide();
    } on UserExistsException {
      Loader.hide();
      Messages.alert('E-mail já utilizado, por favor escolha outro');
    } catch (e, s) {
      _log.error('Erro ao registrar usuário', e, s);
      Loader.hide();
      Messages.alert('Erro ao registrar usuário');
    }
  }
}
