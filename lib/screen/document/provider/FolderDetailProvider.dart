// folder_detail_provider.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../data/modifiednetwork/ApiConfig.dart';
import '../../../data/modifiednetwork/ApiService.dart';
import '../../../data/network/ConnectivityService.dart';
import '../../../data/sharedpreferences/PreferenceManager.dart';
import '../model/DocumentFile.dart';

class FolderDetailProvider extends ChangeNotifier {
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiService _api = ApiService();

  // ─── Document list state ──────────────────────────────────────────────
  List<DocumentFile> _documents = [];
  bool _isLoadingDocuments = false;
  String _documentsError = '';

  // Pagination & stats (optional)
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;

  // ─── Document types state ─────────────────────────────────────────────
  List<Map<String, dynamic>> _docTypes = [];
  bool _isLoadingDocTypes = false;
  String _docTypesError = '';

  // ─── Upload state ──────────────────────────────────────────────────────
  bool _isUploading = false;
  String _uploadError = '';

  // ─── Getters ───────────────────────────────────────────────────────────
  List<DocumentFile> get documents => _documents;
  bool get isLoadingDocuments => _isLoadingDocuments;
  String get documentsError => _documentsError;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;

  List<Map<String, dynamic>> get docTypes => _docTypes;
  bool get isLoadingDocTypes => _isLoadingDocTypes;
  String get docTypesError => _docTypesError;

  bool get isUploading => _isUploading;
  String get uploadError => _uploadError;

  Future<String?> _getToken() async {
    final loginData = await PreferenceManager.getLoginData();
    return loginData?.token;
  }

  // ─── Fetch documents for a specific folder ──────────────────────────
  Future<void> fetchDocumentList({
    required String folderId,
    int page = 1,
    int limit = 10,
    String search = '',
    String? docType,
    String dateFrom = '',
    String dateTo = '',
  }) async {
    if (!await _connectivity.hasInternet()) {
      _documentsError = 'No internet connection.';
      notifyListeners();
      return;
    }

    _isLoadingDocuments = true;
    _documentsError = '';
    notifyListeners();

    try {
      final token = await _getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final body = {
        'source': 'app-android',
        'page': page,
        'limit': limit,
        'search': search,
        'folder_id': folderId,
        'doc_type': docType,
        'date_from': dateFrom,
        'date_to': dateTo,
      };

      final response = await _api.postWithProgress(
        ApiConfig.getDocumentListUrl,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          final List<dynamic> data = json['data'] ?? [];
          _documents = data.map((e) => DocumentFile.fromJson(e)).toList();

          // Parse pagination if present
          final pagination = json['pagination'] as Map<String, dynamic>?;
          if (pagination != null) {
            _currentPage = pagination['page'] ?? 1;
            _totalPages = pagination['total_pages'] ?? 1;
            _totalItems = pagination['total'] ?? 0;
          }

          _documentsError = '';
        } else {
          _documentsError = json['message'] ?? 'Failed to load documents';
        }
      } else {
        _documentsError = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _documentsError = 'Error: $e';
    }

    _isLoadingDocuments = false;
    notifyListeners();
  }

  // ─── Fetch document types (master data) ──────────────────────────────
  Future<void> fetchDocumentTypes() async {
    if (!await _connectivity.hasInternet()) {
      _docTypesError = 'No internet connection.';
      notifyListeners();
      return;
    }

    _isLoadingDocTypes = true;
    _docTypesError = '';
    notifyListeners();

    try {
      final token = await _getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final body = {
        'type': 'my_docs',
        'source': 'app-android',
      };

      final response = await _api.postWithProgress(
        ApiConfig.mastersListUrl,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          final List<dynamic> data = json['data'] ?? [];
          _docTypes = data.map((item) => {
            'id': item['id'].toString(),
            'name': item['name'] ?? '',
          }).toList();
          _docTypesError = '';
        } else {
          _docTypesError = json['message'] ?? 'Failed to load document types';
        }
      } else {
        _docTypesError = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _docTypesError = 'Error: $e';
    }

    _isLoadingDocTypes = false;
    notifyListeners();
  }

  // ─── Upload Document ──────────────────────────────────────────────────
  Future<({bool success, String message})> uploadDocument({
    required String folderId,
    required String docTypeId,
  //  required String title,
    required String filePath,
  }) async {
    if (!await _connectivity.hasInternet()) {
      return (success: false, message: 'No internet connection.');
    }

    _isUploading = true;
    _uploadError = '';
    notifyListeners();


    print("LINE200==>>"+folderId);
    print(docTypeId);

    try {
      final token = await _getToken();
      final headers = <String, String>{
        'Authorization': 'Bearer $token',
      };

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.uploadDocumentUrl}'),
      );

      request.headers.addAll(headers);
      request.fields['source'] = 'app-android';
      request.fields['folder_id'] = folderId;
    //  request.fields['doc_type'] = docTypeId;
      request.fields['doc_type'] = '49';
     // request.fields['title'] = title;

      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body);
        if (json['status'] == true) {
          // Refresh document list after successful upload
          await fetchDocumentList(folderId: folderId);
          _isUploading = false;
          notifyListeners();
          return (success: true, message: json['message'].toString() ?? 'Document uploaded');
        } else {
          _uploadError = json['message'] ?? 'Upload failed';
          _isUploading = false;
          notifyListeners();
          return (success: false, message: _uploadError);
        }
      } else {
        _uploadError = 'Server error: ${response.statusCode}';
        _isUploading = false;
        notifyListeners();
        return (success: false, message: _uploadError);
      }
    } catch (e) {
      _uploadError = 'Error: $e';
      _isUploading = false;
      notifyListeners();
      return (success: false, message: _uploadError);
    }
  }


  // folder_detail_provider.dart (add this method)

// ─── Delete Document ────────────────────────────────────────────────────
  Future<({bool success, String message})> deleteDocument({
    required String documentId,
    required String folderId,
  }) async {
    if (!await _connectivity.hasInternet()) {
      return (success: false, message: 'No internet connection.');
    }

    try {
      final token = await _getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final body = {
        'source': 'app-android',
        'id': documentId,
      };

      final response = await _api.postWithProgress(
        ApiConfig.deleteDocumentUrl, // e.g. '/mobile/documents/delete'
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          // Refresh document list after deletion
          await fetchDocumentList(folderId: folderId);
          return (success: true, message: json['message'].toString() ?? 'Document deleted');
        } else {
          return (success: false, message: json['message'].toString() ?? 'Failed to delete document');
        }
      } else {
        return (success: false, message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      return (success: false, message: 'Error: $e');
    }
  }

  void clearErrors() {
    _docTypesError = '';
    _documentsError = '';
    _uploadError = '';
    notifyListeners();
  }
}