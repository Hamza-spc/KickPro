import 'package:dio/dio.dart';

/// Extracts a human-readable message from API/Dio errors.
String apiErrorMessage(Object error) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    if (status == 429) {
      return 'Gemini rate limit reached. Wait 1–2 minutes and try one feature at a time.';
    }
    if (error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionTimeout) {
      return 'AI request timed out. Gemini may be rate-limited — wait a minute and retry.';
    }
    if (error.type == DioExceptionType.connectionError) {
      return 'Cannot reach server. Check Docker is running and the API URL is correct.';
    }
  }
  return error.toString().replaceFirst('Exception: ', '');
}

String formatMatchDateTime(DateTime dateTime) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${dateTime.year}-${two(dateTime.month)}-${two(dateTime.day)}'
      'T${two(dateTime.hour)}:${two(dateTime.minute)}:00';
}
