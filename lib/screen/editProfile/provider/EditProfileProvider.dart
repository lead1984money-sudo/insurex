import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf_read/data/modifiednetwork/ApiConfig.dart';
import 'package:pdf_read/data/modifiednetwork/ApiService.dart';
import 'package:pdf_read/data/network/ConnectivityService.dart';
import 'package:pdf_read/data/sharedpreferences/PreferenceManager.dart';
import '../model/user_profile_model.dart';
import '../model/address_model.dart';
import '../model/bank_model.dart';

class EditProfileProvider extends ChangeNotifier {
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiService _api = ApiService();

  // ─── Data ──────────────────────────────────────────────────────
  UserProfile? _user;
  Address? _address;
  Bank? _bank;
  String? _profilePictureUrl; // full URL

  // ─── UI state ──────────────────────────────────────────────────
  bool _isLoading = false;
  bool _isUploadingPicture = false;
  bool _isUpdatingPersonal = false;
  bool _isUpdatingAddress = false;
  bool _isUpdatingBank = false;
  String _errorMessage = '';

  // ─── Getters ──────────────────────────────────────────────────
  UserProfile? get user => _user;
  Address? get address => _address;
  Bank? get bank => _bank;
  String? get profilePictureUrl => _profilePictureUrl;
  bool get isLoading => _isLoading;
  bool get isUploadingPicture => _isUploadingPicture;
  bool get isUpdatingPersonal => _isUpdatingPersonal;
  bool get isUpdatingAddress => _isUpdatingAddress;
  bool get isUpdatingBank => _isUpdatingBank;
  String get errorMessage => _errorMessage;

  // ─── Token helper ──────────────────────────────────────────────
  Future<String?> _getToken() async {
    final loginData = await PreferenceManager.getLoginData();
    return loginData?.token;
  }

  // ─── 1. Upload Profile Picture ────────────────────────────────
  Future<bool> uploadProfilePicture(File imageFile) async {
    if (!await _connectivity.hasInternet()) {
      _errorMessage = 'No internet connection.';
      notifyListeners();
      return false;
    }

    _isUploadingPicture = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _errorMessage = 'Authentication token not found.';
        _isUploadingPicture = false;
        notifyListeners();
        return false;
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.profilePictureUpload}');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        if (json['status'] == true) {
          final relativeUrl = json['url'] ?? '';
          // Prepend base URL to get full image URL
          _profilePictureUrl = '${ApiConfig.baseUrl}$relativeUrl';
          _isUploadingPicture = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = json['message'] ?? 'Upload failed';
        }
      } else {
        _errorMessage = 'Upload failed with status ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error uploading: $e';
    }

    _isUploadingPicture = false;
    notifyListeners();
    return false;
  }

  // ─── 2. Update Personal Details ────────────────────────────────
  Future<bool> updatePersonalDetails({
    required String name,
    required String email,
  }) async {
    if (!await _connectivity.hasInternet()) {
      _errorMessage = 'No internet connection.';
      notifyListeners();
      return false;
    }

    _isUpdatingPersonal = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _errorMessage = 'Authentication token not found.';
        _isUpdatingPersonal = false;
        notifyListeners();
        return false;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      final body = {
        'name': name,
        'email': email,
        'source': 'app-android',
      };

      final response = await _api.putWithProgress(
        ApiConfig.profilePersonalUpdate,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          // Update local user data
          _user = UserProfile.fromJson(json['user'] ?? {});
          _isUpdatingPersonal = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = json['message'] ?? 'Failed to update personal details';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    }

    _isUpdatingPersonal = false;
    notifyListeners();
    return false;
  }

  // ─── 3. Update Address ──────────────────────────────────────────
  Future<bool> updateAddress({
    required String address,
    required String pincode,
    required String city,
    required String state,
  }) async {
    if (!await _connectivity.hasInternet()) {
      _errorMessage = 'No internet connection.';
      notifyListeners();
      return false;
    }

    _isUpdatingAddress = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _errorMessage = 'Authentication token not found.';
        _isUpdatingAddress = false;
        notifyListeners();
        return false;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      final body = {
        'address': address,
        'pincode': pincode,
        'city': city,
        'state': state,
        'source': 'app-android',
      };

      final response = await _api.putWithProgress(
        ApiConfig.profileAddressUpdate,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          _address = Address.fromJson(json['address'] ?? {});
          _isUpdatingAddress = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = json['message'] ?? 'Failed to update address';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    }

    _isUpdatingAddress = false;
    notifyListeners();
    return false;
  }

  // ─── 4. Update Bank Details ────────────────────────────────────
  Future<bool> updateBank({
    required String bankName,
    required String acHolderName,
    required String ifsc,
    required String acNumber,
    required String acType,
  }) async {
    if (!await _connectivity.hasInternet()) {
      _errorMessage = 'No internet connection.';
      notifyListeners();
      return false;
    }

    _isUpdatingBank = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _errorMessage = 'Authentication token not found.';
        _isUpdatingBank = false;
        notifyListeners();
        return false;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      final body = {
        'bankName': bankName,
        'acHolderName': acHolderName,
        'ifsc': ifsc,
        'acNumber': acNumber,
        'acType': acType,
        'source': 'app-android',
      };

      final response = await _api.putWithProgress(
        ApiConfig.profileBankUpdate,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          _bank = Bank.fromJson(json['bank'] ?? {});
          _isUpdatingBank = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = json['message'] ?? 'Failed to update bank details';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    }

    _isUpdatingBank = false;
    notifyListeners();
    return false;
  }

  // ─── 5. Update All (convenience) ──────────────────────────────
  Future<bool> updateAllProfile({
    required String name,
    required String email,
    required String address,
    required String pincode,
    required String city,
    required String state,
    required String bankName,
    required String acHolderName,
    required String ifsc,
    required String acNumber,
    required String acType,
    File? imageFile, // optional
  }) async {
    // Do personal first
    bool success = await updatePersonalDetails(name: name, email: email);
    if (!success) return false;

    success = await updateAddress(address: address, pincode: pincode, city: city, state: state);
    if (!success) return false;

    success = await updateBank(
      bankName: bankName,
      acHolderName: acHolderName,
      ifsc: ifsc,
      acNumber: acNumber,
      acType: acType,
    );
    if (!success) return false;

    if (imageFile != null) {
      success = await uploadProfilePicture(imageFile);
      if (!success) return false;
    }

    return true;
  }

  // ─── 6. Manual setters (for cached data) ──────────────────────
  void setUser(UserProfile user) {
    _user = user;
    notifyListeners();
  }

  void setAddress(Address address) {
    _address = address;
    notifyListeners();
  }

  void setBank(Bank bank) {
    _bank = bank;
    notifyListeners();
  }

  void setProfilePicture(String url) {
    _profilePictureUrl = url;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}