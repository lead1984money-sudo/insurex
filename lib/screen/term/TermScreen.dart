import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import '../aboutus/provider/LegalProvider.dart';

class TermScreen extends StatefulWidget {
  const TermScreen({super.key});

  @override
  State<TermScreen> createState() => _TermScreenState();
}

class _TermScreenState extends State<TermScreen> {


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LegalProvider>().fetchTermContent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LegalProvider>(
          builder: (context, provider, child) {
            final title = provider.data?['title'] ?? 'Terms & Conditions';
            return Text(
              title,
              style: const TextStyle(color: Colors.white),
            );
          },
        ),
        backgroundColor: const Color(0xFF4F9CF7),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
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
                        provider.fetchTermContent();
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

          // 4. Render HTML content with styling
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Html(
              data: content,
              style: {
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