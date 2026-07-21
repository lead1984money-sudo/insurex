import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../data/modifiednetwork/ApiConfig.dart';
import '../../../data/modifiednetwork/ApiService.dart';
import '../../../data/network/ConnectivityService.dart';

class UploadPDFProvider with ChangeNotifier {
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiService _api = ApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  double _progress = 0.0;
  double get progress => _progress;

  Map<String, dynamic>? _responseData;
  Map<String, dynamic>? get responseData => _responseData;

  // Plan data
  int _totalCount = 0;
  int get totalCount => _totalCount;

  int _totalConsume = 0;
  int get totalConsume => _totalConsume;

  String _durationTo = '';
  String get durationTo => _durationTo;

  String _billingCycle = '';
  String get billingCycle => _billingCycle;

  String _planName = '';
  String get planName => _planName;

  String _planImage = '';
  String get planImage => _planImage;

  void setLoading(bool value) {
    _isLoading = value;
    print('🔵 isLoading = $value');
    notifyListeners();
  }

  Future<void> fetchPlanDetails({required String token}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Check internet
      if (!await _connectivity.hasInternet()) {
        _errorMessage = 'No internet connection.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final dio = _api.dio;
      if (dio == null) throw Exception('Dio client not available.');

      final headers = {'Authorization': 'Bearer $token'};
      final body = {
        'source': 'app-android',
        'service_id': 2,
      };

      final response = await dio.post(
        ApiConfig.getUploadUrl,
        data: body,
        options: Options(headers: headers),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data as Map<String, dynamic>;
        if (json['status'] == true) {
          final data = json['data'];
          _totalCount = data['total_count'] ?? 0;
          _totalConsume = data['total_consume'] ?? 0;
          _durationTo = data['duration_to'] ?? '';
          _billingCycle = data['billing_cycle'] ?? 'monthly';
          final plan = data['plan'];
          _planName = plan['planName'] ?? '';
          _planImage = plan['planImage'] ?? '';
          _isLoading = false;


          print("Total Count"+_totalCount.toString());
          notifyListeners();
          return;
        } else {
          throw Exception(json['message'] ?? 'Failed to fetch plan details');
        }
      } else {
        throw Exception('Server error (${response.statusCode})');
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset the provider state
  void resetData() {
    _isLoading = false;
    _errorMessage = '';
    _totalCount = 0;
    _totalConsume = 0;
    _durationTo = '';
    _billingCycle = '';
    _planName = '';
    _planImage = '';
    notifyListeners();

}

  // ─── Single file upload (kept for reference) ────────────────────
  Future<bool> uploadPDF({
    required BuildContext context,
    required PlatformFile file,
    required String model,
    required String s3Path,
    required String token,
  }) async {
    print('🟢 uploadPDF called for ${file.name}');

    if (!await _connectivity.hasInternet()) {
      _errorMessage = 'No internet connection.';
      print('❌ No internet');
      _showSnackBar(context, _errorMessage, Colors.red);
      return false;
    }

    setLoading(true);
    _progress = 0.0;
    _errorMessage = '';
    _responseData = null;
    notifyListeners();

    try {
      final dio = _api.dio;
      if (dio == null) throw Exception('Dio client not available.');

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path!, filename: file.name),
        'model': model,
        's3_path': s3Path,
        'source': 'app-android',
        'service_id': '2',
      });

      final headers = {'Authorization': 'Bearer $token'};
      print('🟡 Sending request for ${file.name}...');

      final response = await dio.post(
        ApiConfig.pdfUploadUrl,
        data: formData,
        options: Options(headers: headers),
        onSendProgress: (sent, total) {
          if (total != -1) {
            _progress = sent / total;
            notifyListeners();
          }
        },
      );

      print('🟢 Response status: ${response.statusCode}');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data as Map<String, dynamic>;
        if (json['status'] == true) {
          _responseData = json;
          setLoading(false);
          _progress = 1.0;
          notifyListeners();
          _showSnackBar(context, json['message'] ?? 'Upload successful!', Colors.green);
          return true;
        } else {
          throw Exception(json['message'] ?? 'Upload failed');
        }
      } else {
        throw Exception('Server error (${response.statusCode})');
      }
    } catch (e) {
      print('🔴 Upload error: $e');
      setLoading(false);
      _progress = 0.0;
      _errorMessage = e.toString();
      notifyListeners();
      _showSnackBar(context, 'Upload failed: $e', Colors.red);
      return false;
    }
  }

  // ─── NEW: Multiple files in one request ─────────────────────────
  Future<bool> uploadMultiplePDF({
    required BuildContext context,
    required List<PlatformFile> files,
    required String model,
    required String s3Path,
    required String token,
  }) async {
    print('🟢 uploadMultiplePDF called with ${files.length} files');

    if (!await _connectivity.hasInternet()) {
      _errorMessage = 'No internet connection.';
      print('❌ No internet');
      _showSnackBar(context, _errorMessage, Colors.red);
      return false;
    }

    setLoading(true);
    _progress = 0.0;
    _errorMessage = '';
    _responseData = null;
    notifyListeners();

    try {
      final dio = _api.dio;
      if (dio == null) throw Exception('Dio client not available.');

      // Build FormData with multiple file entries
      FormData formData = FormData();
      print('📦 FormData fields:');
      for (var field in formData.fields) {
        print('  ${field.key}: ${field.value}');
      }
      print('📄 Files:');
      for (var fileEntry in formData.files) {
        print('  ${fileEntry.key}: ${fileEntry.value.filename} (${fileEntry.value.length} bytes)');
      }
      // Add other fields
      formData.fields.addAll([
        MapEntry('model', model),
        MapEntry('s3_path', s3Path),
        MapEntry('source', 'app-android'),
        MapEntry('service_id', '2'),
      ]);
// After adding fields:
      print('Fields:');
      formData.fields.forEach((field) => print('${field.key}: ${field.value}'));

      final headers = {'Authorization': 'Bearer $token'};
      print('🟡 Sending ${files.length} files...');

      final response = await dio.post(
        ApiConfig.pdfUploadUrl,
        data: formData,
        options: Options(headers: headers),
        onSendProgress: (sent, total) {
          if (total != -1) {
            _progress = sent / total;
            notifyListeners(); // updates the overall progress
          }
        },
      );

      print('🟢 Response status: ${response.statusCode}');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data as Map<String, dynamic>;
        if (json['status'] == true) {
          _responseData = json;
          setLoading(false);
          _progress = 1.0;
          notifyListeners();

          _showSnackBar(context, json['message'] ?? 'Upload successful!', Colors.green);
          return true;
        } else {
          throw Exception(json['message'] ?? 'Upload failed');
        }
      } else {
        throw Exception('Server error (${response.statusCode})');
      }
    } catch (e) {
      print('🔴 Upload error: $e');
      setLoading(false);
      _progress = 0.0;
      _errorMessage = e.toString();
      notifyListeners();
      _showSnackBar(context, 'Upload failed: $e', Colors.red);
      return false;
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void reset() {
    _isLoading = false;
    _progress = 0.0;
    _errorMessage = '';
    _responseData = null;
    notifyListeners();
  }
}