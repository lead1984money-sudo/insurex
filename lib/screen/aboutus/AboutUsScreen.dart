// about_us_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:pdf_read/screen/aboutus/provider/LegalProvider.dart';
import 'package:provider/provider.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch privacy policy content (or you can fetch a generic 'about_us' if available)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LegalProvider>().fetchLegalContent();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us',style: TextStyle(color: Colors.white)), // or dynamic title from provider
        backgroundColor: const Color(0xFF4F9CF7),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white), // explicitly set
      ),
      body: Consumer<LegalProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.error,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.fetchLegalContent();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final data = provider.data;
          if (data == null) {
            return const Center(child: Text('No content available.'));
          }

          // You can also use the title from the API: data['title']
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Html(
              data: data['content'] ?? '',
              style: {
                'h2': Style(
                  fontSize: FontSize(22),
                  fontWeight: FontWeight.bold,
                  margin: Margins.only(bottom: 8, top: 16),
                ),
                'p': Style(
                  fontSize: FontSize(16),
                  lineHeight: LineHeight(1.6),
                  margin: Margins.only(bottom: 12),
                ),
                'ul': Style(
                  padding: HtmlPaddings.only(left: 20),
                ),
                'li': Style(
                  fontSize: FontSize(16),
                  lineHeight: LineHeight(1.6),
                ),
                'strong': Style(
                  fontWeight: FontWeight.bold,
                ),
              },
            ),
          );
        },
      ),
    );
  }
}