
abstract class AppLogger {
  
    void debbug(dynamic message, [dynamic error, StackTrace? strackTrace]);
    void error(dynamic message, [dynamic error, StackTrace? strackTrace]);
    void warning(dynamic message, [dynamic error, StackTrace? strackTrace]);
    void info(dynamic message, [dynamic error, StackTrace? strackTrace]);
    void append(dynamic message);
    void closeAppend();

}