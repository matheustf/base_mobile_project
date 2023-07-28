import 'package:clickquartos_mobile/app/core/logger/app_logger.dart';
import 'package:logger/logger.dart';

class LoggerAppLoggerImpl implements AppLogger {
  final logger = Logger();
  var messages = <String>[];

  @override
  void debbug(message, [error, StackTrace? strackTrace]) {
    logger.d(message, error, strackTrace);
  }

  @override
  void error(message, [error, StackTrace? strackTrace]) {
    logger.e(message, error, strackTrace);
  }

  @override
  void info(message, [error, StackTrace? strackTrace]) {
    logger.i(message, error, strackTrace);
  }

  @override
  void warning(message, [error, StackTrace? strackTrace]) {
    logger.w(message, error, strackTrace);
  }

  @override
  void append(message) {
    messages.add(message);
  }
  @override
  void closeAppend() {
   info(messages.join('\n'));
   messages = [];
  }
}
