// document_provider.dart
import 'package:flutter/material.dart';
import '../../../data/modifiednetwork/ApiConfig.dart';
import '../../../data/modifiednetwork/ApiService.dart';
import '../../../data/network/ConnectivityService.dart';
import '../../../data/sharedpreferences/PreferenceManager.dart';
import '../model/DocumentFile.dart';

class DocumentProvider extends ChangeNotifier {
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiService _api = ApiService();

  List<Folder> _folders = [];
  bool _isLoading = false;
  bool _isCreatingFolder = false;
  String _errorMessage = '';

  List<Folder> get folders => _folders;
  bool get isLoading => _isLoading;
  bool get isCreatingFolder => _isCreatingFolder;
  String get errorMessage => _errorMessage;

  Future<String?> _getToken() async {
    final loginData = await PreferenceManager.getLoginData();
    return loginData?.token;
  }

  // ─── Fetch all folders ───────────────────────────────────────────────
  Future<void> fetchFolders() async {
    if (!await _connectivity.hasInternet()) {
      _errorMessage = 'No internet connection.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final body = {'source': 'app-android'};

      final response = await _api.postWithProgress(
        ApiConfig.getAllDocumentUrl,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          final List<dynamic> data = json['data'] ?? [];
          _folders = data.map((e) => Folder.fromJson(e)).toList();
          _errorMessage = '';
        } else {
          _errorMessage = json['message'] ?? 'Failed to load folders';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── Create folder ────────────────────────────────────────────────────
  Future<({bool success, String message})> createFolder(String name) async {
    if (!await _connectivity.hasInternet()) {
      return (success: false, message: 'No internet connection.');
    }

    _isCreatingFolder = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final body = {
        'source': 'app-android',
        'folder_name': name,
      };

      final response = await _api.postWithProgress(
        ApiConfig.folderCreateUrl,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          await fetchFolders(); // refresh list
          return (success: true, message: json['message'].toString() ?? 'Folder created');
        } else {
          return (success: false, message: json['message'].toString() ?? 'Failed to create folder');
        }
      } else {
        return (success: false, message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      return (success: false, message: 'Error: $e');
    } finally {
      _isCreatingFolder = false;
      notifyListeners();
    }
  }

  // ─── Rename folder ────────────────────────────────────────────────────
  Future<({bool success, String message})> renameFolder(String folderId, String newName) async {
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
        'id': int.tryParse(folderId) ?? folderId, // API expects integer ID; send as int if possible
        'folder_name': newName,
      };

      final response = await _api.postWithProgress(
        ApiConfig.renameFolderUrl,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          await fetchFolders(); // refresh list
          return (success: true, message: json['message'].toString() ?? 'Folder renamed');
        } else {
          return (success: false, message: json['message'].toString() ?? 'Failed to rename folder');
        }
      } else {
        return (success: false, message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      return (success: false, message: 'Error: $e');
    }
  }

  // ─── Delete folder ────────────────────────────────────────────────────
  Future<({bool success, String message})> deleteFolder(String folderId) async {
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
        'id': int.tryParse(folderId) ?? folderId, // API expects integer ID
      };

      final response = await _api.postWithProgress(
        ApiConfig.deleteFolderUrl,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          await fetchFolders(); // refresh list
          return (success: true, message: json['message'].toString() ?? 'Folder deleted');
        } else {
          return (success: false, message: json['message'].toString() ?? 'Failed to delete folder');
        }
      } else {
        return (success: false, message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      return (success: false, message: 'Error: $e');
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}