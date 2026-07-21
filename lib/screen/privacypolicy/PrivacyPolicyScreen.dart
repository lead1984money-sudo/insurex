import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import '../aboutus/provider/LegalProvider.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
 @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch privacy policy – the provider will call the fixed endpoint
      context.read<LegalProvider>().fetchPrivacyPolicyContent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LegalProvider>(
          builder: (context, provider, child) {
            // Try to use the title from the API, fallback to 'Privacy Policy'
            final title = provider.data?['title'] ?? 'Privacy Policy';
            return Text(
              title,
              style: const TextStyle(color: Colors.white),
            );
          },
        ),
        backgroundColor: const Color(0xFF4F9CF7),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white), // white back arrow
        elevation: 0,
      ),
      body: Consumer<LegalProvider>(
        builder: (context, provider, child) {
          // 1. Loading state
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error state
          if (provider.error.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      provider.error,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        provider.fetchPrivacyPolicyContent();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F9CF7),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3. Data available
          final data = provider.data;
          if (data == null) {
            return const Center(
              child: Text('No content available.'),
            );
          }

          final content = data['content'] ?? '';

          // 4. Render HTML content
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Html(
              data: content,
              style: {
                // Customise heading styles
                'h2': Style(
                  fontSize: FontSize(22),
                  fontWeight: FontWeight.bold,
                  margin: Margins.only(bottom: 8, top: 16),
                  color: const Color(0xFF0B1A33),
                ),
                'p': Style(
                  fontSize: FontSize(16),
                  lineHeight: LineHeight(1.6),
                  margin: Margins.only(bottom: 12),
                  color: Colors.black87,
                ),
                'ul': Style(
                  padding: HtmlPaddings.only(left: 20),
                ),
                'li': Style(
                  fontSize: FontSize(16),
                  lineHeight: LineHeight(1.6),
                  color: Colors.black87,
                ),
                'strong': Style(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0B1A33),
                ),
                'em': Style(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade700,
                ),
              },
            ),
          );
        },
      ),
    );
  }
}