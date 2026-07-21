import 'package:dio/dio.dart';
import 'package:pdf_read/data/modifiednetwork/ApiConfig.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart'; // optional

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;

  void init({String? baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    // Optional logging
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
    ));
  }

  Dio get dio => _dio;

  // POST with upload progress
  Future<Response> postWithProgress(
      String path, {
        dynamic data,
        Map<String, String>? headers,   // <-- optional headers
        void Function(int sent, int total)? onSendProgress,
      }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        options: Options(headers: headers), // pass headers to Dio
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── PUT with upload progress ────────────────────────────────────
  Future<Response> putWithProgress(
      String path, {
        dynamic data,
        Map<String, String>? headers,
        void Function(int sent, int total)? onSendProgress,
      }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        options: Options(headers: headers),
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET with download progress
  Future<Response> getWithProgress(
      String path, {
        void Function(int received, int total)? onReceiveProgress,
      }) async {
    try {
      return await _dio.get(
        path,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      return e.response?.data['message'] ?? e.response?.statusMessage ?? 'Server error';
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please try again.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection.';
    } else {
      return e.message ?? 'Unexpected error';
    }
  }
}