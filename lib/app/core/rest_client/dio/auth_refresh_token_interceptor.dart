// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:clickquartos_mobile/app/core/exceptions/expire_token_exception.dart';
import 'package:clickquartos_mobile/app/core/helpers/constants.dart';
import 'package:clickquartos_mobile/app/core/local_storage/local_storage.dart';
import 'package:clickquartos_mobile/app/core/logger/app_logger.dart';
import 'package:clickquartos_mobile/app/core/rest_client/rest_client.dart';
import 'package:clickquartos_mobile/app/modules/core/auth/auth_store.dart';
import 'package:dio/dio.dart';

class AuthRefreshTokenInterceptor extends Interceptor {
  final AuthStore _authStore;
  final LocalStorage _localStorage;
  final LocalSecureStorage _localSecureStorage;
  final RestClient _restClient;
  final AppLogger _log;
  AuthRefreshTokenInterceptor({
    required AuthStore authStore,
    required LocalStorage localStorage,
    required LocalSecureStorage localSecureStorage,
    required RestClient restClient,
    required AppLogger log,
  })  : _authStore = authStore,
        _localStorage = localStorage,
        _localSecureStorage = localSecureStorage,
        _restClient = restClient,
        _log = log;

  @override
  Future<void> onError(DioError err, ErrorInterceptorHandler handler) async {
    try {
      final respStatusCode = err.response?.statusCode ?? 0;
      final reqPath = err.requestOptions.path;

      if (respStatusCode == 403 || respStatusCode == 401) {
        if (reqPath != '/auth/refresh') {
          final authRequired = err.requestOptions
                  .extra[Constants.REST_CLIENT_AUTH_REQUIRED_KEY] ??
              false;

          if (authRequired) {
            _log.append('############## Refresh token ##############');
            await _refreshToken(err);
            await _retryRequest(err, handler);
          } else {
            throw err;
          }
        } else {
          throw err;
        }
      } else {
        throw err;
      }
    } on ExpireTokenException {
      _authStore.logout();
      handler.next(err);
    } on DioError catch (e) {
      handler.next(e);
    } catch (e, s) {
      _log.error('Erro rest client', e, s);
      handler.next(err);
    } finally {
      _log.closeAppend();
    }
  }

  Future<void> _refreshToken(DioError err) async {
    final refreshToken = await _localSecureStorage
        .read(Constants.LOCAL_STORAGE_REFRESH_TOKEN_KEY);

    if (refreshToken == null) {
      throw ExpireTokenException();
    }

    final resultRefresh = await _restClient.auth().put('/auth/refresh', data: {
      'refresh_token': refreshToken,
    });

    await _localStorage.write<String>(Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY,
        resultRefresh.data['access_token']);

    await _localSecureStorage.write(Constants.LOCAL_STORAGE_REFRESH_TOKEN_KEY,
        resultRefresh.data['refresh_token']);
  }

  Future<void> _retryRequest(
      DioError err, ErrorInterceptorHandler handler) async {
    _log.append('############## Retry request ##############');
    final requestOptions = err.requestOptions;

    final result = await _restClient.request(
      requestOptions.path,
      method: requestOptions.method,
      data: requestOptions.data,
      headers: requestOptions.headers,
      queryParameters: requestOptions.queryParameters,
    );

    handler.resolve(
      Response(
        requestOptions: requestOptions,
        data: result.data,
        statusCode: result.statusCode,
        statusMessage: result.statusMessage,
      ),
    );
  }
}
