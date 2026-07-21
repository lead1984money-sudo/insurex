import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_read/screen/uploadpdf/provider/UploadPDFProvider.dart';
import 'package:provider/provider.dart';
import '../../data/sharedpreferences/PreferenceManager.dart';
import '../bottomnav/BottomNavScreen.dart';


class UploadPolicyScreen extends StatefulWidget {
  const UploadPolicyScreen({super.key});

  @override
  State<UploadPolicyScreen> createState() => _UploadPolicyScreenState();
}

class _UploadPolicyScreenState extends State<UploadPolicyScreen> {
  final int topUp = 0;

  // ─── File management ─────────────────────────────────────────────
  List<PlatformFile> _selectedFiles = [];

  // ─── Local loading state (UI controls) ──────────────────────────
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  // ─── File picker ──────────────────────────────────────────────────
  Future<void> _pickFiles() async {
    if (_isUploading) return;
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null) {
        setState(() {
          _selectedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking files: $e')),
      );
    }
  }

  void _removeFile(int index) {
    if (_isUploading) return;
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _clearAllFiles() {
    if (_isUploading) return;
    setState(() {
      _selectedFiles.clear();
    });
  }

  Future<void> _uploadFiles() async {
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one PDF.')),
      );
      return;
    }

    final token = await _getToken();
    final userID = await _getUserID();
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token missing.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    final provider = Provider.of<UploadPDFProvider>(context, listen: false);
    int totalFiles = _selectedFiles.length;
    int successCount = 0;
    bool anyError = false;

    // Make a local copy to prevent modifications during upload
    final filesToUpload = List<PlatformFile>.from(_selectedFiles);

    for (int i = 0; i < totalFiles; i++) {
      final file = filesToUpload[i];

      // Check if path is valid
      if (file.path == null || file.path!.isEmpty) {
        anyError = true;
        break;
      }

      setState(() {
        _uploadProgress = i / totalFiles;
      });

      bool success = false;
      try {
        success = await provider.uploadPDF(
          context: context,
          file: file,
          model: 'haiku3',
          s3Path: '$userID/pdf_extract',
          token: token,
        );
      } catch (e) {
        anyError = true;
        break;
      }

      if (success) {
        successCount++;
      } else {
        anyError = true;
        if (provider.errorMessage.contains('limit exceeded') ||
            provider.errorMessage.contains('topup') ||
            provider.errorMessage.contains('Please topup')) {
          _showLimitExceededDialog(provider.errorMessage);
          break;
        }
        break;
      }

      await Future.delayed(Duration.zero);
    }

    setState(() {
      _isUploading = false;
      _uploadProgress = anyError ? _uploadProgress : 1.0;
    });

    if (anyError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed at file ${successCount + 1}.')),
      );
    } else {
      _clearAllFiles();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All files uploaded successfully!')),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final token = await _getToken();
        if (token != null && token.isNotEmpty) {
          await _provider.fetchPlanDetails(token: token);
        }
      });
    }
  }

  void _showLimitExceededDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.blue.shade50.withOpacity(0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange.withOpacity(0.15),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: 56,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Upload Limit Exceeded',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B1A33),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Navigate to Top-Up screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Navigate to Top-Up screen')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Top Up Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Token helpers ───────────────────────────────────────────────
  Future<String?> _getToken() async {
    final loginData = await PreferenceManager.getLoginData();
    return loginData?.token;
  }

  Future<String?> _getUserID() async {
    final loginData = await PreferenceManager.getLoginData();
    return loginData?.user.id.toString();
  }

  // ─── Helper: format date ────────────────────────────────────────
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  late UploadPDFProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = UploadPDFProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        await _provider.fetchPlanDetails(token: token);
      }
    });
  }

  // ─── BUILD ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {


    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<UploadPDFProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: const Color(0xffF5F7FA), // Light grey background
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: _isUploading
                    ? null
                    : () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const BottomNavScreen()),
                  );
                },
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
              ),
              title: Column(
                children: [
                  const SizedBox(height: 5),
                  const Text(
                    'Upload Policy PDF(s)',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Upload policy documents for extraction',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Stats Cards ────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'YEARLY PLAN',
                            value: provider.totalCount.toString(),
                            icon: Icons.calendar_month,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            title: 'TOP-UP',
                            value: '$topUp',
                            icon: Icons.add_circle_outline,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ─── Available Uploads ─────────────────────────────
                    const Text(
                      'Available Uploads',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${provider.totalConsume} / ${provider.totalCount}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${((provider.totalConsume / provider.totalCount) * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: provider.totalCount > 0
                          ? (provider.totalConsume / provider.totalCount).clamp(0.0, 1.0)
                          : 0.0,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.blue,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Your monthly limit will be reset on ',
                          ),
                          TextSpan(
                            text: provider.durationTo.isNotEmpty
                                ? _formatDate(DateTime.parse(provider.durationTo))
                                : "--",
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // ─── Drop Zone ─────────────────────────────────────
                    GestureDetector(
                      onTap: _isUploading ? null : _pickFiles,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 50,
                              color: Colors.blue.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _isUploading ? 'Uploading...' : 'Tap to select PDFs',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Insurex can make mistakes, Please double check Responses.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _isUploading ? null : _pickFiles,
                              icon: const Icon(Icons.folder_open, color: Colors.white),
                              label: const Text('Choose PDF Files'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ─── Security Note ──────────────────────────────────
                    Row(
                      children: [
                        Icon(Icons.lock_outline, size: 18, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your documents are 100% secure and encrypted. We never share your documents with anyone.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ─── Selected Files List ──────────────────────────
                    if (_selectedFiles.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Selected Files (${_selectedFiles.length})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                            onPressed: _isUploading ? null : _clearAllFiles,
                            child: const Text(
                              'Clear All',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ..._selectedFiles.asMap().entries.map((entry) {
                        int index = entry.key;
                        PlatformFile file = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.picture_as_pdf, color: Colors.red),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        file.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${(file.size / 1024).toStringAsFixed(1)} KB',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.grey),
                                  onPressed: _isUploading ? null : () => _removeFile(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 16),

                      // ─── Upload Progress / Button ────────────────────
                      if (_isUploading)
                        Column(
                          children: [
                            LinearProgressIndicator(
                              value: provider.progress,
                              backgroundColor: Colors.grey.shade300,
                              color: Colors.blue,
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(provider.progress * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        )
                      else
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _uploadFiles,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Upload Files'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],


                    // ─── AI Extraction Card ─────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.auto_awesome, color: Colors.blue, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'AI-Powered Data Extraction',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Our AI will automatically extract key details from your document like policy number, insured name, premiums, coverage and more.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── Brand Footer ──────────────────────────────────
                    Row(
                      children: [
                        const Spacer(),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Insure',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: 'X',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Secure upload · Bank-level encryption',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Helper: Stat Card ──────────────────────────────────────────
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}