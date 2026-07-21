import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf_read/app_utils/app_strings.dart';
import 'package:pdf_read/screen/login/LoginScreen.dart';
import '../../app_utils/app_images.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  // Entrance animation (staggered)
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;

  // Continuous floating animation (smooth sine wave, no snapping)
  late AnimationController _floatController;

  // Get Started button press-scale (Apple-style tactile feedback)
  bool _isButtonPressed = false;

  // Page indicator (decorative, matches design — wire to a real
  // PageController if you turn this into a multi-page onboarding flow)
  final int _currentPage = 0;
  final int _totalPages = 3;

  @override
  void initState() {
    super.initState();

    // --- Entrance Animation ---
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );

    // --- Floating Animation ---
    // Runs 0 -> 1 forever. We turn this into a smooth sine wave below
    // instead of using the raw value directly, which is what caused
    // the visible "jump" every loop in the old code.
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const floatAmplitude = 6.0; // subtle vertical drift in px
    const pulseAmplitude = 0.03; // subtle logo breathing

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: size.height,
            width: size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.welcomeBgImage),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _entranceController,
                    _floatController,
                  ]),
                  builder: (context, _) {
                    // ---- Smooth float using sin(), not a raw ramp ----
                    final wave = math.sin(_floatController.value * 2 * math.pi);
                    final floatOffset = floatAmplitude * wave;
                    final pulseScale = 1.0 + pulseAmplitude * wave;

                    // ---- Entrance progress ----
                    final progress = _fadeAnimation.value;

                    final titleOpacity = _computeOpacity(progress, 0.0, 0.2);
                    final titleSlide = _computeSlide(progress, 0.0, 0.2);
                    final subtitleOpacity = _computeOpacity(progress, 0.1, 0.3);
                    final subtitleSlide = _computeSlide(progress, 0.1, 0.3);
                    final cardsOpacity = _computeOpacity(progress, 0.3, 0.6);
                    final cardsSlide = _computeSlide(progress, 0.3, 0.6);
                    final bottomOpacity = _computeOpacity(progress, 0.6, 0.9);
                    final bottomSlide = _computeSlide(progress, 0.6, 0.9);

                    return Column(

                      children: [
                        const SizedBox(height: 8),

                        // ---- Title (fade + slide up) ----
                        Transform.translate(
                          offset: Offset(0, titleSlide),
                          child: Opacity(
                            opacity: titleOpacity,
                            child: Column(
                              children: [
                                const SizedBox(height: 12),
                                const Text(
                                  "Welcome to",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff052B7A),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "INSURE",
                                        style: TextStyle(color: Color(0xff052B7A)),
                                      ),
                                      TextSpan(
                                        text: "X",
                                        style: TextStyle(color: Color(0xff18D9FF)),
                                      ),
                                      TextSpan(
                                        text: " Policy",
                                        style: TextStyle(color: Color(0xff052B7A)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ---- Subtitle ----
                        Transform.translate(
                          offset: Offset(0, subtitleSlide),
                          child: Opacity(
                            opacity: subtitleOpacity,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 25),
                              child: Text(
                                "Your all-in-one platform to manage leads,\npolicies, and earnings effortlessly.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: Color(0xff6B7280),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ---- Cards area (float applied smoothly) ----
                        Transform.translate(
                          offset: Offset(0, cardsSlide),
                          child: Opacity(
                            opacity: cardsOpacity,
                            child: SizedBox(
                              width: size.width,
                              height: size.height * 0.44,
                              child: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: [
                                  // ---- Logo with smooth pulse ----
                                  Transform.scale(
                                    scale: pulseScale,
                                    child: Image.asset(
                                      AppImages.logo1,
                                      width: size.width * 0.35,
                                      height: size.width * 0.35,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stack) =>
                                          _fallbackShieldLogo(size),
                                    ),
                                  ),
                                  // ---- Four cards (float together) ----
                                  _buildPositionedCard(
                                    top: -10,
                                    left: 20,
                                    offset: floatOffset,
                                    card: _featureCard(
                                      width: size.width * 0.28,
                                      icon: Icons.people_alt_outlined,
                                      iconColor: Colors.blue,
                                      title: "Smart Leads",
                                      subtitle: "Capture, follow-up\n& convert leads",
                                    ),
                                  ),
                                  _buildPositionedCard(
                                    top: -10,
                                    right: 20,
                                    offset: floatOffset,
                                    card: _featureCard(
                                      width: size.width * 0.28,
                                      icon: Icons.verified_user_outlined,
                                      iconColor: Colors.green,
                                      title: "Policy Management",
                                      subtitle: "Upload, manage &\ntrack all policies",
                                    ),
                                  ),
                                  _buildPositionedCard(
                                    bottom: -10,
                                    left: 20,
                                    // opposite phase so cards feel alive, not robotic
                                    offset: -floatOffset,
                                    card: _featureCard(
                                      width: size.width * 0.28,
                                      icon: Icons.description_outlined,
                                      iconColor: Colors.deepPurple,
                                      title: "AI PDF Extract",
                                      subtitle: "Extract data from\npolicy PDFs instantly",
                                    ),
                                  ),
                                  _buildPositionedCard(
                                    bottom: -10,
                                    right: 20,
                                    offset: -floatOffset,
                                    card: _featureCard(
                                      width: size.width * 0.28,
                                      icon: Icons.account_balance_wallet_outlined,
                                      iconColor: Colors.orange,
                                      title: "Earnings & Reports",
                                      subtitle: "Track earnings and\nperformance in real-time",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // ---- Bottom Features Card ----
                        Transform.translate(
                          offset: Offset(0, bottomSlide),
                          child: Opacity(
                            opacity: bottomOpacity,
                            child: Container(
                              margin: const EdgeInsets.all(18),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.95),
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(.08),
                                    blurRadius: 25,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _bottomFeature(
                                          Icons.shield_outlined,
                                          Colors.blue,
                                          "Secure & Reliable",
                                          "Your data is protected\nwith top-notch security",
                                        ),
                                      ),
                                      Expanded(
                                        child: _bottomFeature(
                                          Icons.bolt,
                                          Colors.cyan,
                                          "Fast & Easy",
                                          "Powerful tools designed\nfor your daily work",
                                        ),
                                      ),
                                      Expanded(
                                        child: _bottomFeature(
                                          Icons.bar_chart,
                                          Colors.deepPurple,
                                          "Grow More",
                                          "Insights and reports\nto grow your business",
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 22),

                                  GestureDetector(
                                    onTapDown: (_) =>
                                        setState(() => _isButtonPressed = true),
                                    onTapCancel: () =>
                                        setState(() => _isButtonPressed = false),
                                    onTapUp: (_) =>
                                        setState(() => _isButtonPressed = false),
                                    onTap: () {
                                      HapticFeedback.mediumImpact();
                                      // TODO: navigate to next screen


                                      Navigator.push (
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>  LoginScreen(),
                                        ),
                                      );


                                    },
                                    child: AnimatedScale(
                                      scale: _isButtonPressed ? 0.97 : 1.0,
                                      duration: const Duration(milliseconds: 120),
                                      curve: Curves.easeOut,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 120),
                                        width: double.infinity,
                                        height: 58,
                                        decoration: BoxDecoration(
                                          color: const Color(0xff3B82F6),
                                          borderRadius: BorderRadius.circular(18),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xff3B82F6)
                                                  .withOpacity(_isButtonPressed ? 0.15 : 0.35),
                                              blurRadius: _isButtonPressed ? 8 : 16,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        alignment: Alignment.center,
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              AppStrings.getStarted,
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper: build a positioned card with float offset
  Widget _buildPositionedCard({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double offset,
    required Widget card,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.translate(
        offset: Offset(0, offset),
        child: card,
      ),
    );
  }

  // Helper: compute opacity based on progress and interval
  double _computeOpacity(double progress, double start, double end) {
    if (progress <= start) return 0.0;
    if (progress >= end) return 1.0;
    return (progress - start) / (end - start);
  }

  // Helper: compute slide offset (from 30 to 0) based on progress and interval
  double _computeSlide(double progress, double start, double end) {
    if (progress <= start) return 30.0;
    if (progress >= end) return 0.0;
    final t = (progress - start) / (end - start);
    return 30.0 * (1.0 - t);
  }

  // ---- Page indicator dot (now implemented, was an empty stub before) ----
  Widget _dot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 22 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? const Color(0xff3B82F6) : const Color(0xffD1D5DB),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // Fallback logo (used only if AppImages.logo1 fails to load) so the
  // screen never shows a broken-image icon in place of the shield mark.
  Widget _fallbackShieldLogo(Size size) {
    return Icon(
      Icons.shield_rounded,
      size: size.width * 0.32,
      color: const Color(0xff18D9FF),
    );
  }

  Widget _featureCard({
    required double width,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: iconColor.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: iconColor.withOpacity(.15),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xff6B7280),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomFeature(
      IconData icon,
      Color color,
      String title,
      String subtitle,
      ) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: color.withOpacity(.10),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xff6B7280),
          ),
        ),
      ],
    );
  }
}

