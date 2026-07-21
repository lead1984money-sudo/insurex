import 'dart:io';
import 'dart:typed_data'; // <-- Required for Uint8List
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfWebViewScreen extends StatefulWidget {
  final String pdfUrl;

  const PdfWebViewScreen({super.key, required this.pdfUrl});

  @override
  State<PdfWebViewScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfWebViewScreen> {
  Future<FileData?>? _fileDataFuture;

  @override
  void initState() {
    super.initState();
    _fileDataFuture = _fetchFileData();
  }

  Future<FileData?> _fetchFileData() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';
        final isPdf = contentType.contains('pdf') ||
            widget.pdfUrl.toLowerCase().endsWith('.pdf');
        final isImage = contentType.contains('image') ||
            widget.pdfUrl.toLowerCase().endsWith('.jpeg') ||
            widget.pdfUrl.toLowerCase().endsWith('.jpg') ||
            widget.pdfUrl.toLowerCase().endsWith('.png') ||
            widget.pdfUrl.toLowerCase().endsWith('.gif');

        if (isPdf) {
          return FileData(isPdf: true, bytes: response.bodyBytes);
        } else if (isImage) {
          return FileData(isPdf: false, bytes: response.bodyBytes);
        } else {
          // Try to decode as image as fallback
          try {
            await decodeImageFromList(response.bodyBytes);
            return FileData(isPdf: false, bytes: response.bodyBytes);
          } catch (_) {
            // Assume PDF if not image
            return FileData(isPdf: true, bytes: response.bodyBytes);
          }
        }
      } else {
        throw Exception('Failed to load: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Fetch error: $e');
      return null;
    }
  }

  Future<String?> downloadFile() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      if (response.statusCode == 200) {
        Directory dir = await getApplicationDocumentsDirectory();
        final extension = widget.pdfUrl.contains('.pdf') ? '.pdf' : '.jpg';
        final fileName =
            'policy_${DateTime.now().millisecondsSinceEpoch}$extension';
        String filePath = '${dir.path}/$fileName';
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      }
    } catch (e) {
      debugPrint('Download Error: $e');
    }
    return null;
  }

  Future<void> shareFile() async {
    String? path = await downloadFile();
    if (path != null) {
      await Share.shareXFiles([XFile(path)]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Policy Document',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: shareFile,
          ),
        ],
      ),
      body: FutureBuilder<FileData?>(
        future: _fileDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    snapshot.hasError ? '${snapshot.error}' : 'Failed to load file',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _fileDataFuture = _fetchFileData();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            final data = snapshot.data!;
            if (data.isPdf) {
              return SfPdfViewer.memory(
                data.bytes,
                onDocumentLoadFailed: (details) {
                  // Optionally show a snackbar
                },
              );
            } else {
              return InteractiveViewer(
                child: Image.memory(
                  data.bytes,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('Failed to decode image'));
                  },
                ),
              );
            }
          }
        },
      ),
    );
  }
}

// Data holder class – ensures bytes are Uint8List
class FileData {
  final bool isPdf;
  final Uint8List bytes;

  FileData({required this.isPdf, required this.bytes});
}