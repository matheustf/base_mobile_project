import 'package:clickquartos_mobile/app/modules/auth/home/auth_home_page.dart';
import 'package:clickquartos_mobile/app/modules/auth/login/login_module.dart';
import 'package:clickquartos_mobile/app/modules/auth/register/register_module.dart';
import 'package:clickquartos_mobile/app/repositories/social/social_repository.dart';
import 'package:clickquartos_mobile/app/repositories/social/social_repository_impl.dart';
import 'package:clickquartos_mobile/app/repositories/user/user_repository.dart';
import 'package:clickquartos_mobile/app/repositories/user/user_repository_impl.dart';
import 'package:clickquartos_mobile/app/services/user/user_service.dart';
import 'package:clickquartos_mobile/app/services/user/user_service_impl.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AuthModule extends Module {
  @override
  final List<Bind> binds = [
    Bind.lazySingleton<UserRepository>((i) => UserRepositoryImpl(
          restClient: i(), //CoreModule
          log: i(), //CoreModule
        )),
    Bind.lazySingleton<UserService>((i) => UserServiceImpl(
          userRepository: i(), //AuthModule
          log: i(), //CoreModule
          localStorage: i(), //CoreModule
          localSecureStorage: i(), //CoreModule
        )),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(Modular.initialRoute,
        child: (_, __) => AuthHomePage(
              authStore: Modular.get(),
            )),
    ModuleRoute('/login', module: LoginModule()),
    ModuleRoute('/register', module: RegisterModule()),
  ];
}
