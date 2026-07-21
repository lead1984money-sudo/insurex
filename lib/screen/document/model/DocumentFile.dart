// document_models.dart

class DocumentFile {
  final String id;
  final String fileName;
  final String fileUrl;
  final String docTypeName;
  final DateTime createdAt;
  final double size; // Optional – API doesn't send size, but we can keep it

  DocumentFile({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.docTypeName,
    required this.createdAt,
    this.size = 0.0,
  });

  factory DocumentFile.fromJson(Map<String, dynamic> json) {
    return DocumentFile(
      id: json['id']?.toString() ?? '',
      fileName: json['file_name'] ?? '',
      fileUrl: json['file_url'] ?? '',
      docTypeName: json['doc_type_name'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class Folder {
  final String id;
  final String name;
  final DateTime createdDate;
  final String s3Path;
  final bool canDelete;
  final int documentCount;
  final List<DocumentFile> files;

  Folder({
    required this.id,
    required this.name,
    required this.createdDate,
    this.s3Path = '',
    this.canDelete = true,
    this.documentCount = 0,
    this.files = const [],
  });

  factory Folder.fromJson(Map<String, dynamic> json) {
    final documents = (json['documents'] as List?)
        ?.map((d) => DocumentFile.fromJson(d))
        .toList() ??
        [];

    return Folder(
      id: json['id']?.toString() ?? '',
      name: json['folder_name'] ?? '',
      createdDate: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      s3Path: json['s3_path'] ?? '',
      canDelete: json['can_delete'] ?? false,
      documentCount: json['document_count'] ?? 0,
      files: documents,
    );
  }
}