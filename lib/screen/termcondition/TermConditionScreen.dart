// lib/screens/term_condition_screen.dart
import 'package:flutter/material.dart';
import 'package:pdf_read/app_utils/ColorsPicks.dart';
import 'package:provider/provider.dart';

import '../login/provider/AuthProvider.dart';


class TermConditionScreen extends StatefulWidget {
  const TermConditionScreen({super.key});

  @override
  State<TermConditionScreen> createState() => _TermConditionScreenState();
}

class _TermConditionScreenState extends State<TermConditionScreen> {
  bool _localAccepted = false;

  final List<Map<String, dynamic>> sections = [
    {
      "icon": Icons.verified_user_outlined,
      "title": "Acceptance of Terms",
      "content":
      "By using InsureX, you agree to comply with these Terms & Conditions. If you do not agree, please discontinue use of the application."
    },
    {
      "icon": Icons.person_outline,
      "title": "User Responsibilities",
      "content":
      "Users must provide accurate information and use the platform responsibly. Any misuse, fraud, or unauthorized activity is prohibited."
    },
    {
      "icon": Icons.lock_outline,
      "title": "Account Security",
      "content":
      "You are responsible for maintaining the confidentiality of your account credentials and ensuring the security of your account."
    },
    {
      "icon": Icons.payment_outlined,
      "title": "Payments & Subscription",
      "content":
      "Subscription plans may renew automatically unless canceled before the renewal date. Pricing and billing details are displayed before purchase."
    },
    {
      "icon": Icons.shield_outlined,
      "title": "Insurance Disclaimer",
      "content":
      "InsureX provides insurance-related information and services. Policy approvals and coverage are subject to the insurer's terms and conditions."
    },
    {
      "icon": Icons.copyright_outlined,
      "title": "Intellectual Property",
      "content":
      "All logos, content, designs, and materials within InsureX are protected under applicable intellectual property laws."
    },
    {
      "icon": Icons.warning_amber_rounded,
      "title": "Limitation of Liability",
      "content":
      "InsureX shall not be liable for indirect, incidental, or consequential damages arising from the use of the application."
    },
    {
      "icon": Icons.block_outlined,
      "title": "Termination",
      "content":
      "We reserve the right to suspend or terminate accounts that violate our terms, policies, or applicable laws."
    },
    {
      "icon": Icons.update_outlined,
      "title": "Changes to Terms",
      "content":
      "These Terms & Conditions may be updated periodically. Continued use of the application indicates acceptance of the updated terms."
    },
    {
      "icon": Icons.gavel_outlined,
      "title": "Governing Law",
      "content":
      "These terms are governed by the laws of India. Any disputes shall be subject to the jurisdiction of Indian courts."
    },
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 60,
              left: 20,
              right: 20,
              bottom: 25,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [blueColor, Color(0xff00B4FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Terms & Conditions",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Please read and understand our terms before using InsureX.",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    "Last Updated • June 12, 2026",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.04),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome to InsureX 👋",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Thank you for choosing InsureX. These Terms & Conditions govern your access and use of our platform. By continuing, you agree to comply with all applicable terms and policies.",
                        style: TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ...sections.map(
                      (item) => Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.04),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xff0066FF).withOpacity(.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(item["icon"], color: const Color(0xff0066FF)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["title"],
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item["content"],
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  height: 1.5,
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _localAccepted,
                      activeColor: const Color(0xff0066FF),
                      onChanged: (value) {
                        setState(() => _localAccepted = value ?? false);
                      },
                    ),
                    const Expanded(
                      child: Text(
                        "I have read and agree to the Terms & Conditions.",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 56,
                  width: size.width,
                  child: ElevatedButton(
                    onPressed: _localAccepted
                        ? () {
                      // Update provider and go back
                      authProvider.setTermsAccepted(true);
                      Navigator.pop(context);
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: blueColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      "Accept & Continue",
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ],
      ),
    );
  }
}