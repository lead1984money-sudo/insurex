import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pdf_read/app_utils/app_strings.dart';
import '../../data/sharedpreferences/PreferenceManager.dart';
import '../bottomnav/BottomNavScreen.dart';
import '../login/LoginScreen.dart';
import '../../app_utils/app_images.dart';
import '../welcome screen/welcome.dart';



class FirstSplash extends StatefulWidget {
  const FirstSplash({super.key});

  @override
  State<FirstSplash> createState() => _FirstSplashState();
}

class _FirstSplashState extends State<FirstSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();

    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(seconds: 3));

    final loginData = await PreferenceManager.getLoginData();

    if (!mounted) return;

    if (loginData != null && loginData.token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const BottomNavScreen(),
        ),
      );
    } else {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => const LoginScreen(),
      //   ),
      // );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            /// Background
            Positioned.fill(
              child: Image.asset(
                AppImages.background1,
                fit: BoxFit.cover,
              ),
            ),

            /// Soft Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(.15),
                      Colors.white.withOpacity(.05),
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),

                    const SizedBox(height: 90),

                    /// Logo
                    Center(
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Image.asset(
                          AppImages.logo1,
                          width: 270,
                          height: 350,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    /// Tagline
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black87,
                        ),
                        children: [
                          TextSpan (
                            text: AppStrings.protectToday,
                          ),
                          TextSpan(
                            text: AppStrings.secureTomorrow,
                            style: TextStyle(
                              color: Color(0xff2A8BFF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    /// Shield Card
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(.12),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shield,
                        size: 34,
                        color: Color(0xff2A8BFF),
                      ),
                    ),

                    const SizedBox(height: 28),

                    /// Progress Bar
                    SizedBox(
                      width: 180,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: const LinearProgressIndicator(
                          minHeight: 5,
                          backgroundColor: Color(0xffE5EAF4),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xff2A8BFF),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),



                    SizedBox(
                      height: size.height * .06,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}