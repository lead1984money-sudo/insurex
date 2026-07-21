import 'dart:ui'; // required for BackdropFilter & ImageFilter
import 'package:flutter/material.dart';
import 'package:pdf_read/data/modifiednetwork/ApiService.dart';
import 'package:pdf_read/data/modifiednetwork/ApiConfig.dart';
import 'package:pdf_read/data/network/ConnectivityService.dart';
import '../../../data/sharedpreferences/PreferenceManager.dart';
import '../LoginModel.dart';
import '../model/VerifyOtpModel.dart';

class AuthProvider extends ChangeNotifier {
  // --- Existing state ---
  String _mobileNumber = '';
  bool _termsAccepted = false;
  bool _isOtpSent = false;
  String _otp = ''; // stored after send

  String get mobileNumber => _mobileNumber;
  bool get termsAccepted => _termsAccepted;
  bool get isOtpSent => _isOtpSent;
  String get otp => _otp;

  // --- API & connectivity ---
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiService _api = ApiService();

  // --- Loading / progress / error ---
  bool _isLoading = false;
  double _progress = 0.0;
  String _errorMessage = '';
  LoginModel? _data; // holds response (if needed)
  bool get isLoading => _isLoading;
  double get progress => _progress;
  String get errorMessage => _errorMessage;
  LoginModel? get data => _data;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // --- Existing setters ---
  void setMobileNumber(String number) {
    _mobileNumber = number;
    notifyListeners();
  }

  void setTermsAccepted(bool accepted) {
    _termsAccepted = accepted;
    notifyListeners();
  }

  void reset() {
    _mobileNumber = '';
    _termsAccepted = false;
    _isOtpSent = false;
    _otp = '';
    _errorMessage = '';
    _data = null;
    _progress = 0.0;
    notifyListeners();
  }

  // --- 🍏 Premium Apple‑style glass SnackBar ---
  void _showSnackBar(
      BuildContext context,
      String message, {
        bool isSuccess = true,
      }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 12,
              sigmaY: 12,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  colors: isSuccess
                      ? [
                    const Color(0xff34C759),
                    const Color(0xff30B350),
                  ]
                      : [
                    const Color(0xffFF6B6B),
                    const Color(0xffFF4D4D),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isSuccess
                        ? const Color(0xff34C759)
                        : Colors.red)
                        .withOpacity(.35),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSuccess
                          ? Icons.check_rounded
                          : Icons.close_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isSuccess ? "Success" : "Failed",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          message,
                          style: TextStyle(
                            color: Colors.white.withOpacity(.95),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- 🔥 REAL OTP SEND (with progress) ---
  Future<bool> sendOtp({
    required BuildContext context,
    required String phone,
  }) async {
    if (!await _connectivity.hasInternet()) {
      _errorMessage = 'No internet connection. Please check your network.';
      notifyListeners();
      _showSnackBar(context, _errorMessage, isSuccess: false);
      return false;
    }

    setLoading(true);
    _progress = 0.0;
    _errorMessage = '';
    _isOtpSent = false;
    _otp = '';
    notifyListeners();

    final body = {
      'mobile': phone,
      'source': 'app-android',
    };

    try {
      final response = await _api.postWithProgress(
        ApiConfig.requestOTPUrl,
        data: body,
        onSendProgress: (sent, total) {
          if (total != -1) {
            _progress = sent / total;
            notifyListeners();
          }
        },
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data as Map<String, dynamic>;

        if (json['status'] == true) {
          _otp = json['otpCode']?.toString() ?? '';
          _isOtpSent = true;
          setLoading(false);
          _progress = 1.0;
          notifyListeners();
          _showSnackBar(
            context,
            json['message'] ?? 'OTP sent successfully!',
            isSuccess: true,
          );
          return true;
        } else {
          throw Exception(json['message'] ?? 'Failed to send OTP');
        }
      } else {
        throw Exception('Server error (${response.statusCode})');
      }
    } catch (e) {
      setLoading(false);
      _progress = 0.0;
      _errorMessage = e.toString();
      notifyListeners();
      _showSnackBar(context, 'Failed to send OTP: $e', isSuccess: false);
      return false;
    }
  }

  // --- 🔄 Resend OTP ---
  Future<bool> reSendOtp({
    required BuildContext context,
    required String phone,
  }) async {
    if (!await _connectivity.hasInternet()) {
      _errorMessage = 'No internet connection. Please check your network.';
      notifyListeners();
      _showSnackBar(context, _errorMessage, isSuccess: false);
      return false;
    }

    setLoading(true);
    _progress = 0.0;
    _errorMessage = '';
    _isOtpSent = false;
    _otp = '';
    notifyListeners();

    final body = {
      'mobile': phone,
      'source': 'app-android',
      "type": "resend"
    };

    try {
      final response = await _api.postWithProgress(
        ApiConfig.requestOTPUrl,
        data: body,
        onSendProgress: (sent, total) {
          if (total != -1) {
            _progress = sent / total;
            notifyListeners();
          }
        },
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data as Map<String, dynamic>;

        if (json['status'] == true) {
          _otp = json['otpCode']?.toString() ?? '';
          _isOtpSent = true;
          setLoading(false);
          _progress = 1.0;
          notifyListeners();
          _showSnackBar(
            context,
            json['message'] ?? 'OTP sent successfully!',
            isSuccess: true,
          );
          return true;
        } else {
          throw Exception(json['message'] ?? 'Failed to send OTP');
        }
      } else {
        throw Exception('Server error (${response.statusCode})');
      }
    } catch (e) {
      setLoading(false);
      _progress = 0.0;
      _errorMessage = e.toString();
      notifyListeners();
      _showSnackBar(context, 'Failed to send OTP: $e', isSuccess: false);
      return false;
    }
  }

  // --- 🔥 REAL OTP VERIFY (with progress) ---
  Future<bool> verifyOtp({
    required BuildContext context,
    required String enteredOtp,
    required String fcmToken,
  }) async {
    if (!await _connectivity.hasInternet()) {
      _errorMessage = 'No internet connection.';
      notifyListeners();
      _showSnackBar(context, _errorMessage, isSuccess: false);
      return false;
    }

    setLoading(true);
    _progress = 0.0;
    _errorMessage = '';
    notifyListeners();

    final body = {
      'mobile': _mobileNumber,
      'otp': enteredOtp,
      'fcm_token': fcmToken,
      'source': 'app-android',
    };

    try {
      final response = await _api.postWithProgress(
        ApiConfig.verifyUrl,
        data: body,
        onSendProgress: (sent, total) {
          if (total > 0) {
            _progress = sent / total;
            notifyListeners();
          }
        },
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;

        if (json is Map<String, dynamic> && json['status'] == true) {
          final loginModel = VerifyOtpModel.fromJson(json);
          await PreferenceManager.saveLoginData(loginModel);

          setLoading(false);
          _progress = 1.0;
          notifyListeners();

          _showSnackBar(
            context,
            loginModel.message,
            isSuccess: true,
          );
          return true;
        } else {
          throw Exception(
            json['message'] ?? 'Invalid OTP',
          );
        }
      } else {
        throw Exception('Server Error : ${response.statusCode}');
      }
    } catch (e) {
      setLoading(false);
      _progress = 0.0;
      _errorMessage = e.toString();
      notifyListeners();
      _showSnackBar(
        context,
        'Verification failed: $e',
        isSuccess: false,
      );
      return false;
    }
  }
}