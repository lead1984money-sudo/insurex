import 'package:flutter/material.dart';
import 'package:pdf_read/data/modifiednetwork/ApiConfig.dart';
import 'package:pdf_read/data/modifiednetwork/ApiService.dart';
import 'package:pdf_read/data/network/ConnectivityService.dart';
import 'package:pdf_read/data/sharedpreferences/PreferenceManager.dart';

class PaymentProvider extends ChangeNotifier {
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiService _api = ApiService();
  bool _isProcessing = false;
  String _errorMessage = '';

  bool get isProcessing => _isProcessing;
  String get errorMessage => _errorMessage;

  Future<String?> _getToken() async {
    final loginData = await PreferenceManager.getLoginData();
    return loginData?.token;
  }

  // ----- Create Order -----
  Future<String?> createOrder({
    required double amount,
    required String planId,
    required String billingCycle,
    required String discountAmount,

  }) async {
    if (!await _connectivity.hasInternet()) {
      _errorMessage = 'No internet connection.';
      notifyListeners();
      return null;
    }

    _isProcessing = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _errorMessage = 'Authentication token not found.';
        _isProcessing = false;
        notifyListeners();
        return null;
      }



      // print("OrderCreateeee===>>>");
      // print("Total===>>>"+amount.toString());
      // print("PlanID===>>>"+planId.toString());
      // print("BillingCycle===>>>"+billingCycle);
      // print("YearlyDiscount===>>>"+discountAmount.toString());


      final body = {
        "sourceType": "app-android",
        "billing_cycle": billingCycle,
        "amount": amount,
        "discount_amount": discountAmount,
      };

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await _api.postWithProgress(
        ApiConfig.buyUrl+'/'+planId,
        data: body,
        headers: headers,
      );


      _isProcessing = false;
      notifyListeners();

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        print("Create Order Response: $json");

        // ✅ FIX: use 'status' instead of 'success'
        if (json is Map<String, dynamic> && json['status'] == true) {
          return json['order_id'] as String?;
        } else {
          _errorMessage = json['message'] ?? 'Failed to create order';
          return null;
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
        return null;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  // ----- Complete Payment (Success/Failure) -----
  Future<bool> completePayment({
    required String orderId,
    required String paymentId,
    required String signature,
    required int status, // 1 = success, 0 = failure
    required int planId,
    required String billingCycle, // 'monthly' or 'yearly'
    required double amount,
    String? reasonFail,
  }) async {
    if (!await _connectivity.hasInternet()) {
      _errorMessage = 'No internet connection.';
      notifyListeners();
      return false;
    }

    _isProcessing = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _errorMessage = 'Authentication token not found.';
        _isProcessing = false;
        notifyListeners();
        return false;
      }


      final body = {
        'orderId': orderId,
        'paymentId': paymentId,
        'signature': signature,
        'status': 1,
        'source_type': 'app-android',
        'rawPayload': {
          'razorpay_payment_id': paymentId,
          'razorpay_order_id': orderId,
          'razorpay_signature': signature,
        },
       // if (reasonFail != null) 'reason_fail': reasonFail,
      };

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await _api.postWithProgress(
        ApiConfig.paymentCompleteUrl,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {

          print("PAYMENT SUCCESS");
          _isProcessing = false;
          notifyListeners();
          return true;
        } else {
          print("PAYMENT FAIL");
          _errorMessage = json['message'] ?? 'Payment completion failed';
          _isProcessing = false;
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
        _isProcessing = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}