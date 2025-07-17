// AppException Class
import 'package:cosmos_media_mvi/utils.dart/error_code.dart';
import 'package:cosmos_media_mvi/utils.dart/error_context_key.dart';
import 'package:cosmos_media_mvi/utils.dart/log_level.dart';

class AppException implements Exception {
  final ErrorCode errorCode;
  final String message;
  final String? stackTrace;
  final LogLevel logLevel;
  final DateTime timestamp;
  final Map<ErrorContextKey, dynamic> context;

  AppException({
    required this.errorCode,
    required this.message,
    this.stackTrace,
    this.logLevel = LogLevel.error,
    DateTime? timestamp,
    Map<ErrorContextKey, dynamic>? context,
  })  : timestamp = timestamp ?? DateTime.now(),
        context = context ?? {};

  // Method to add context fluently
  AppException withContext(ErrorContextKey key, dynamic value) {
    context[key] = value;
    return this;
  }

  @override
  String toString() {
    return 'AppException: [${errorCode.name}] $message (Level: ${logLevel.name}, Timestamp: $timestamp)\n'
           'Context: $context\n'
           '${stackTrace != null ? 'Stack Trace:\n$stackTrace' : ''}';
  }
}
