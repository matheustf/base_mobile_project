import 'package:clickquartos_mobile/app/modules/auth/register/register_controller.dart';
import 'package:clickquartos_mobile/app/modules/auth/register/register_page.dart';
import 'package:flutter_modular/flutter_modular.dart';

class RegisterModule extends Module {
  @override
  final List<Bind> binds = [
    Bind.lazySingleton((i) => RegisterController(
      userService: i(), //AuthModule
      log: i(), //CoreModule
    )),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(Modular.initialRoute, child: (_, __) => const RegisterPage()),
  ];
}
