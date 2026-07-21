
import 'package:flutter/material.dart';
import 'package:pdf_read/screen/document/provider/FolderDetailProvider.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_read/screen/document/model/DocumentFile.dart';

import '../myBusiness/provider/PolicyProvider.dart';
import '../pdfviewer/PdfViewerScreen.dart';

class FolderDetailScreen extends StatefulWidget {
  final Folder folder;
  const FolderDetailScreen({super.key, required this.folder});

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  // Store selected file info for upload
  String? _selectedFilePath;
  String? _selectedFileName;
  double? _selectedFileSize;

  @override
  void initState() {
    super.initState();
    // Fetch document types when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FolderDetailProvider>().fetchDocumentList(folderId: widget.folder.id);
      context.read<FolderDetailProvider>().fetchDocumentTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        elevation: 0,
        foregroundColor: Colors.white,          // affects icons & text
        iconTheme: const IconThemeData(color: Colors.white), // ensures back icon white
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showUploadDialog(context),
          ),
        ],
      ),
      body: Consumer<FolderDetailProvider>(
        builder: (context, provider, child) {
          if (provider.documents.isEmpty) {
            return const Center(
              child: Text('No documents in this folder.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.documents.length,
            itemBuilder: (context, index) {
              final file = provider.documents[index];
              return GestureDetector(
                onTap: (){
                  _handleFileAction(context, provider.documents[index].fileUrl!, 'download');
                },
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.picture_as_pdf, size: 40, color: Colors.red),
                    title: Text(
                      file.fileName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${file.docTypeName}  •  ${file.createdAt.day}/${file.createdAt.month}/${file.createdAt.year}',
                    ),
                    // folder_detail_screen.dart (inside ListView.builder)

                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteDocumentDialog(
                        context,
                        file.id,
                        widget.folder.id,
                        file.fileName,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }


  void _showDeleteDocumentDialog(
      BuildContext context,
      String documentId,
      String folderId,
      String fileName,
      ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete "$fileName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // close dialog
              final provider = context.read<FolderDetailProvider>();
              final result = await provider.deleteDocument(
                documentId: documentId,
                folderId: folderId,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.message),
                    backgroundColor: result.success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleFileAction(BuildContext context, String fileUrl, String actionType) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final provider = context.read<PolicyProvider>();
    final signedUrl = await provider.getFileUrl(fileUrl, actionType);

    Navigator.of(context).pop(); // remove loading dialog

    if (signedUrl != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfWebViewScreen(pdfUrl: signedUrl),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage)),
      );
    }
  }

  // ─── Upload Dialog ──────────────────────────────────────────────────
  void _showUploadDialog(BuildContext context) {
    final titleController = TextEditingController();
    String? selectedDocTypeId;
    String? selectedDocTypeName;

    // State for file selection
    setState(() {
      _selectedFilePath = null;
      _selectedFileName = null;
      _selectedFileSize = null;
    });

    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: !isLoading,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          final provider = context.watch<FolderDetailProvider>();
          return AlertDialog(
            title: const Text('Upload Documents'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Title input ──────────────────────────
                  // TextField(
                  //   controller: titleController,
                  //   enabled: !isLoading,
                  //   decoration: const InputDecoration(
                  //     labelText: 'Title',
                  //     hintText: 'Enter a title',
                  //     border: OutlineInputBorder(),
                  //   ),
                  // ),
                  const SizedBox(height: 16),
                  // ── Document type dropdown ────────────────
                  DropdownButtonFormField<String>(
                    value: selectedDocTypeId,
                    isExpanded: true,
                   // enabled: !isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Document Type',
                      border: OutlineInputBorder(),
                    ),
                    items: provider.docTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type['id'].toString(),
                        child: Text(type['name'] ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDocTypeId = value;
                        selectedDocTypeName = provider.docTypes.firstWhere(
                              (t) => t['id'].toString() == value,
                        )['name'];
                      });
                    },
                    hint: const Text('Select document type'),
                  ),
                  const SizedBox(height: 16),
                  // ── File picker ──────────────────────────
                  InkWell(
                    onTap: isLoading ? null : () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        type: FileType.any,
                      );
                      if (result != null) {
                        PlatformFile file = result.files.first;
                        setState(() {
                          _selectedFilePath = file.path;
                          _selectedFileName = file.name;
                          _selectedFileSize = file.size / 1024; // KB
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.attach_file, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _selectedFileName != null
                                ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedFileName!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${_selectedFileSize!.toStringAsFixed(2)} KB',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            )
                                : const Text('No file selected'),
                          ),
                          const Icon(Icons.folder_open, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                  // Validate
                //  final title = titleController.text.trim();
                  // if (title.isEmpty) {
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     const SnackBar(
                  //       content: Text('Please enter a title'),
                  //       backgroundColor: Colors.orange,
                  //     ),
                  //   );
                  //   return;
                  // }
                  if (selectedDocTypeId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a document type'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                  if (_selectedFilePath == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a file'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  setState(() => isLoading = true);

                  final provider = context.read<FolderDetailProvider>();
                  final result = await provider.uploadDocument(
                    folderId: widget.folder.id,
                    docTypeId: selectedDocTypeId!,
                   // title: title,
                    filePath: _selectedFilePath!,
                  );

                  setState(() => isLoading = false);

                  if (result.success) {
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Document uploaded successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text('Upload'),
              ),
            ],
          );
        },
      ),
    );
  }
}