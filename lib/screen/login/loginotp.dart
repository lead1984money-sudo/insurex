import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:pdf_read/screen/login/provider/AuthProvider.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../app_utils/ColorsPicks.dart';
import '../../app_utils/app_strings.dart';
import '../../services/notification_service.dart';
import '../bottomnav/BottomNavScreen.dart';

class OtpVerifyPage extends StatefulWidget {
  final String phoneNumber;
  final String otp;

  const OtpVerifyPage({
    super.key,
    required this.phoneNumber,
    required this.otp,
  });

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage>
    with TickerProviderStateMixin, CodeAutoFill {
  final TextEditingController otpController = TextEditingController();

  int countdown = 30;
  bool _isResending = false;
  bool _isVerifying = false;   // ← prevents double submission

  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  String appSignature = "";


  @override
  void initState() {
    super.initState();

    _initSmsListener();
    otpController.text = widget.otp;

    startTimer();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(
      CurvedAnimation(
        parent: _floatingController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _initSmsListener() async {
    try {
      listenForCode();

      appSignature =
      await SmsAutoFill().getAppSignature;

      debugPrint("APP HASH => $appSignature");

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }



  @override
  void dispose() {
    _floatingController.dispose();
    cancel();
    otpController.dispose();
    super.dispose();
  }

  /// Auto‑verify when OTP is complete (6 digits)
  void _proceedToOtp() async {
    // Guard against concurrent calls
    if (_isVerifying) return;
    _isVerifying = true;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final otp = otpController.text.trim();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.enterValidOtp)),
      );
      _isVerifying = false;
      return;
    }

    final fcmToken = await NotificationService().getFCMToken() ?? '';

    final success = await authProvider.verifyOtp(
      context: context,
      enteredOtp: otp,
      fcmToken: fcmToken,
    );

    _isVerifying = false; // Reset after API call (success or failure)

    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BottomNavScreen()),
      );
    }
  }

  @override
  void codeUpdated() {
    // Triggered when SMS auto‑fill writes the code
    if (code != null && code!.length == 6) {
      otpController.text = code!;
      // Short delay to let the UI reflect the filled digits
      Future.delayed(const Duration(milliseconds: 200), _proceedToOtp);
    }
  }

  void startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      if (countdown > 0) {
        setState(() {
          countdown--;
        });
        return true;
      }
      return false;
    });
  }

  void resendOtp() async {
    if (_isResending) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _isResending = true);

    final success = await authProvider.reSendOtp(
      context: context,
      phone: widget.phoneNumber,
    );

    setState(() => _isResending = false);

    if (success) {
      otpController.text = authProvider.otp;
      setState(() => countdown = 30);
      startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final defaultPinTheme = PinTheme(
      width: 55,
      height: 65,
      textStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xff101828),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xffE4E7EC),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new),
                ),
              ),

              const SizedBox(height: 20),

              // Main content - takes remaining space
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Verify Your Number",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Color(0xff0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "We've sent a 6-digit OTP to",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.phoneNumber,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.edit,
                          size: 18,
                          color: blueColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Floating icon (animated)
                    AnimatedBuilder(
                      animation: _floatingAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatingAnimation.value),
                          child: child,
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 230,
                            height: 230,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.withOpacity(.05),
                            ),
                          ),
                          Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.withOpacity(.07),
                            ),
                          ),
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xff4F8CFF),
                                  Color(0xff1F6DFF),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(.35),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.message_rounded,
                              size: 42,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // OTP Card (auto‑submit on completion)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.05),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Enter 6-digit OTP",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Show loading spinner while verifying
                          if (authProvider.isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: CircularProgressIndicator(
                                color: blueColor,
                              ),
                            )
                          else ...[
                            Pinput(
                              controller: otpController,
                              length: 6,
                              defaultPinTheme: defaultPinTheme,
                              focusedPinTheme:
                              defaultPinTheme.copyDecorationWith(
                                border: Border.all(
                                  color: blueColor,
                                  width: 2,
                                ),
                              ),
                              submittedPinTheme:
                              defaultPinTheme.copyDecorationWith(
                                color: Colors.blue.shade50,
                                border: Border.all(
                                  color: blueColor,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              // Auto‑verify when 6th digit is entered
                              onCompleted: (value) => _proceedToOtp(),
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Didn't receive the code?",
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                countdown == 0
                                    ? GestureDetector(
                                  onTap: resendOtp,
                                  child: Text(
                                    "Resend",
                                    style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                                    : Text(
                                  "00:${countdown.toString().padLeft(2, '0')}",
                                  style: TextStyle(
                                    color: blueColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Security Card (fixed at bottom)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.04),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.shade50,
                      ),
                      child: Icon(
                        Icons.shield_outlined,
                        color: blueColor,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "We never share your number",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Your information is 100% secure with us.",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}