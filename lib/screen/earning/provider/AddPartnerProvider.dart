import 'package:flutter/material.dart';
import '../../../data/modifiednetwork/ApiConfig.dart';
import '../../../data/modifiednetwork/ApiService.dart';
import '../../../data/network/ConnectivityService.dart';
import '../../../data/sharedpreferences/PreferenceManager.dart';

class AddPartnerProvider extends ChangeNotifier {
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiService _api = ApiService();

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final contactPersonController = TextEditingController();
  final contactMobileController = TextEditingController();
  final addressController = TextEditingController();

  String status = "Active";
  bool isLoading = false;
  String? errorMessage;

  int get statusInt => status == "Active" ? 1 : 0;

  Future<String?> _getToken() async {
    final loginData = await PreferenceManager.getLoginData();
    return loginData?.token;
  }

  void setStatus(String value) {
    status = value;
    notifyListeners();
  }

  Future<bool> submit() async {
    if (!formKey.currentState!.validate()) return false;

    if (!await _connectivity.hasInternet()) {
      errorMessage = 'No internet connection.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final body = {
        'source': 'app-android',
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'mobile': mobileController.text.trim(),
        'contact_person': contactPersonController.text.trim(),
        'contact_mobile': contactMobileController.text.trim(),
        'address': addressController.text.trim(),
        'status': statusInt,
      };

      final response = await _api.postWithProgress(
        ApiConfig.partnerCreateUrl,
        data: body,
        headers: headers,
      );

      isLoading = false;

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          errorMessage = '';
          notifyListeners();
          return true;
        } else {
          errorMessage = json['message'] ?? 'Failed to create partner';
          notifyListeners();
          return false;
        }
      } else {
        errorMessage = 'Server error: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      isLoading = false;
      errorMessage = 'Error: $e';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    contactPersonController.dispose();
    contactMobileController.dispose();
    addressController.dispose();
    super.dispose();
  }
}