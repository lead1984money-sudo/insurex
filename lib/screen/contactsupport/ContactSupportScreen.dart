
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../aboutus/provider/LegalProvider.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LegalProvider>().fetchContactSupport();
    });
  }

  // Launch URL helper
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      // Show a snackbar if launch fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot open: $url'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LegalProvider>(
          builder: (context, provider, child) {
            final title = provider.data?['title'] ?? 'Contact Support';
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
          // Loading
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
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
                        provider.fetchContactSupport();
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

          // Data
          final data = provider.data;
          if (data == null) {
            return const Center(child: Text('No content available.'));
          }

          final title = data['title'] ?? 'Contact Support';
          final description = data['description'] ?? '';
          final options = data['options'] as List<dynamic>? ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title (if not already in AppBar)
                if (data['title'] != null)
                  Text(
                    data['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B1A33),
                    ),
                  ),
                const SizedBox(height: 8),

                // Description
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                const SizedBox(height: 24),

                // Contact options
                ...options.map((item) {
                  final label = item['label'] ?? '';
                  final value = item['value'] ?? '';
                  final url = item['url'] ?? '';
                  final action = item['action'] ?? '';
                  final icon = _getIconForAction(action);
                  final color = _getColorForAction(action);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        if (url.isNotEmpty) {
                          _launchUrl(url);
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: color.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icon, color: color, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    label,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0B1A33),
                                    ),
                                  ),
                                  Text(
                                    value,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper to get icon based on action
  IconData _getIconForAction(String action) {
    switch (action.toLowerCase()) {
      case 'phone':
      case 'tel':
        return Icons.phone;
      case 'email':
        return Icons.email;
      case 'whatsapp':
        return Icons.chat;
      default:
        return Icons.help_outline;
    }
  }

  // Helper to get colour based on action
  Color _getColorForAction(String action) {
    switch (action.toLowerCase()) {
      case 'phone':
      case 'tel':
        return Colors.blue;
      case 'email':
        return Colors.red;
      case 'whatsapp':
        return const Color(0xFF25D366); // WhatsApp green
      default:
        return Colors.grey;
    }
  }
}