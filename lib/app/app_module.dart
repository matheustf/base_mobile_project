import 'package:clickquartos_mobile/app/modules/auth/auth_module.dart';
import 'package:clickquartos_mobile/app/modules/core/core_module.dart';
import 'package:clickquartos_mobile/app/modules/home/home_module.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AppModule extends Module {
  @override
  List<Bind<Object>> get binds => [];

  @override
  List<Module> get imports => [
        CoreModule(),
      ];

  @override
  List<ModularRoute> get routes => [
        ModuleRoute('/auth', module: AuthModule()),
        ModuleRoute('/home', module: HomeModule()),
      ];
}
