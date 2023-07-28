import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class Environments {
  Environments._();

  static String? param(String paramName) {
    //kReleaseMode é o modo release ou seja se nao for produção
    if (kReleaseMode) {
      return FirebaseRemoteConfig.instance.getString(paramName);
    } else {
      return dotenv.env[paramName];
    }
  }

  static Future<void> loadEnvs() async {
    //kReleaseMode é o modo release ou seja se nao for produção
    if (kReleaseMode) {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await remoteConfig.fetchAndActivate();
    } else {
      await dotenv.load(fileName: ".env");
    }
  }
}
