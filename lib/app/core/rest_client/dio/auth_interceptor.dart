// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:clickquartos_mobile/app/core/helpers/constants.dart';
import 'package:clickquartos_mobile/app/core/local_storage/local_storage.dart';
import 'package:clickquartos_mobile/app/modules/core/auth/auth_store.dart';
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final LocalStorage _localStorage;
  final AuthStore _authStore;

  AuthInterceptor({
    required LocalStorage localStorage,
    required AuthStore authStore,
  })  : _localStorage = localStorage,
        _authStore = authStore;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final authRequired =
        options.extra[Constants.REST_CLIENT_AUTH_REQUIRED_KEY] ?? false;

    if (authRequired) {
      final accessToken = await _localStorage
          .read<String>(Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY);

      if (accessToken == null) {
        await _authStore.logout();
        return handler.reject(
          DioError(
            requestOptions: options,
            error: 'Expire token',
            type: DioErrorType.cancel,
          ),
        );
      }

      options.headers['Authorization'] = accessToken;
    } else {
      options.headers.remove('Authorization');
    }

    handler.next(options);
  }


}
