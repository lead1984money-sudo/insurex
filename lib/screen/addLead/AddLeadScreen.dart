import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:pdf_read/screen/lead/provider/LeadProvider.dart';
import 'package:pdf_read/data/modifiednetwork/ApiService.dart';
import 'package:pdf_read/data/modifiednetwork/ApiConfig.dart';
import 'package:pdf_read/data/sharedpreferences/PreferenceManager.dart';



class LeadAddScreen extends StatefulWidget {
  const LeadAddScreen({super.key});

  @override
  State<LeadAddScreen> createState() => _LeadAddScreenState();
}

class _LeadAddScreenState extends State<LeadAddScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _showReferenceDetails = false;

  // Controllers
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _policyNoController = TextEditingController();
  final _vehicleNoController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _remarksController = TextEditingController();
  final _referenceDetailsController = TextEditingController();

  // Dropdown selections
  String? _selectedStatusId;
  String? _selectedTypeId;
  String? _selectedReferenceId;

  // Attachments
  List<Attachment> _attachments = [];

  bool _isSubmitting = false;
  bool _isLoadingMaster = false;
  bool _uploadingDocuments = false;

  static const Color primaryColor = Colors.blue;
  static const Color secondaryColor = Colors.blueAccent;
  static const Color backgroundColor = Color(0xffF5F7FA);

  // Helper to convert to title case
  String toTitleCase(String text) {
    return text
        .split(' ')
        .map((word) => word.isNotEmpty
        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
        : '')
        .join(' ');
  }

  bool get _isMotorSelected {
    if (_selectedTypeId == null) return false;
    final provider = context.read<LeadProvider>();
    final lobs = provider.lobs;
    final selectedLob = lobs.firstWhere(
          (lob) => lob['id'] == _selectedTypeId,
     // orElse: () => null,
    );
    return selectedLob != null &&
        selectedLob['name']?.toLowerCase() == 'motor';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LeadProvider>();
      if (provider.lobs.isEmpty || provider.documentTypes.isEmpty) {
        setState(() => _isLoadingMaster = true);
        provider.fetchMasterData().then((_) {
          if (mounted) setState(() => _isLoadingMaster = false);
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeadProvider>();

    if (_isLoadingMaster) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Add Lead',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: primaryColor,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
        ),
        body: Container(
          color: backgroundColor,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Lead Information Card ----
                  _buildCard(
                    title: 'Lead Information',
                    icon: Icons.person_outline,
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'Customer Name *',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _mobileController,
                        label: 'Mobile *',
                        icon: Icons.phone_android,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          final trimmed = value.trim();
                          if (!RegExp(r'^[6-9]\d{9}$').hasMatch(trimmed)) {
                            return 'Enter valid 10-digit Indian mobile';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v!.trim().isEmpty) return 'Required';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(v)) {
                            return 'Invalid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        label: 'Lead Type *',
                        hint: 'Select lead type',
                        value: _selectedTypeId,
                        items: provider.lobs.map((type) {
                          return DropdownMenuItem<String>(
                            value: type['id'],
                            child: Text(type['name']),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedTypeId = val),
                        validator: (v) => v == null ? 'Select type' : null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ---- Plans Card ----
                  _buildCard(
                    title: 'Plans',
                    icon: Icons.assignment_outlined,
                    children: [
                      if (_isMotorSelected)
                        _buildTextField(
                          controller: _vehicleNoController,
                          label: 'Vehicle No *',
                          icon: Icons.directions_car,
                          hint: 'e.g. MH 12 AB 1234',
                          validator: (v) =>
                          v!.trim().isEmpty ? 'Enter vehicle number' : null,
                        )
                      else
                        _buildTextField(
                          controller: _policyNoController,
                          label: 'Policy No',
                          icon: Icons.description,
                          hint: 'Policy number',
                        ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _pincodeController,
                        label: 'Pincode',
                        icon: Icons.location_on,
                        keyboardType: TextInputType.number,
                        hint: '6 digit pincode',
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        label: 'Lead Status *',
                        hint: 'Select status',
                        value: _selectedStatusId,
                        items: provider.leadStatuses.map((status) {
                          return DropdownMenuItem<String>(
                            value: status['id'],
                            child: Text(toTitleCase(status['name'])),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedStatusId = val),
                        validator: (v) => v == null ? 'Select status' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        label: 'Reference *',
                        hint: 'Select reference',
                        value: _selectedReferenceId,
                        items: provider.leadReferences.map((ref) {
                          return DropdownMenuItem<String>(
                            value: ref['id'],
                            child: Text(toTitleCase(ref['name'])),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedReferenceId = val;
                            _showReferenceDetails = val != null;
                          });
                        },
                        validator: (v) => v == null ? 'Select reference' : null,
                      ),
                      if (_showReferenceDetails) ...[
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _referenceDetailsController,
                          label: 'Reference Details',
                          icon: Icons.note_add,
                          maxLines: 3,
                          hint: 'Enter reference details',
                        ),
                      ],
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _remarksController,
                        label: 'Remarks',
                        icon: Icons.comment,
                        maxLines: 3,
                        hint: 'Enter remarks',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ---- Attachments Card ----
                  _buildCard(
                    title: 'Attachments',
                    icon: Icons.attach_file,
                    children: [
                      Text(
                        'Only PDF and image files allowed. Each document type can be used once.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _attachments.length,
                        itemBuilder: (context, index) =>
                            _buildAttachmentItem(index, provider),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton.icon(
                          onPressed: _addAttachment,
                          icon: Icon(Icons.add_circle, color: primaryColor),
                          label: Text(
                            'Add Attachment',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ---- Action Buttons ----
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: (_isSubmitting || _uploadingDocuments)
                              ? null
                              : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: (_isSubmitting || _uploadingDocuments)
                              ? null
                              : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: _isSubmitting || _uploadingDocuments
                              ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Text(
                            'Create',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- UI Helpers ----------

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff333333),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 0.8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryColor, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator ??
              (v) {
            if (label.contains('*') && v!.trim().isEmpty) return 'Required';
            return null;
          },
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(Icons.arrow_drop_down, color: primaryColor, size: 24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white,
      ),
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator ??
              (v) {
            if (label.contains('*') && v == null) return 'Required';
            return null;
          },
      icon: const Icon(Icons.expand_more, color: Colors.grey),
      dropdownColor: Colors.white,
      style: const TextStyle(color: Colors.black87),
    );
  }

  Widget _buildAttachmentItem(int index, LeadProvider provider) {
    final attachment = _attachments[index];
    final allDocs = provider.documentTypes;
    final usedIds = _attachments
        .where((a) => a.documentTypeId != null && _attachments.indexOf(a) != index)
        .map((a) => a.documentTypeId!)
        .toList();

    final availableItems = allDocs
        .where((doc) => !usedIds.contains(doc['id']))
        .map((doc) {
      return DropdownMenuItem<String>(
        value: doc['id'],
        child: Text(doc['name']!),
      );
    }).toList();

    if (attachment.documentTypeId != null &&
        usedIds.contains(attachment.documentTypeId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          attachment.documentTypeId = null;
        });
      });
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Document type',
                  border: InputBorder.none,
                  isDense: true,
                ),
                hint: const Text('Choose document'),
                value: attachment.documentTypeId,
                items: availableItems,
                onChanged: (val) {
                  setState(() {
                    attachment.documentTypeId = val;
                  });
                },
                validator: (v) => v == null ? 'Select type' : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      attachment.fileName ?? 'No file',
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _pickFileForAttachment(index),
                    icon: Icon(Icons.attach_file, color: primaryColor),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _attachments.removeAt(index);
                      });
                    },
                    icon: const Icon(Icons.close, color: Colors.red),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Logic ----------

  void _addAttachment() {
    setState(() {
      _attachments.add(Attachment());
    });
  }

  Future<void> _pickFileForAttachment(int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null) {
      final file = File(result.files.single.path!);
      setState(() {
        _attachments[index].file = file;
        _attachments[index].fileName = result.files.single.name;
      });
    }
  }

  // ---------- Submission ----------

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final usedDocTypes = <String>{};
    for (var attachment in _attachments) {
      if (attachment.documentTypeId == null || attachment.file == null) {
        _showError('Each attachment must have a type and a file.');
        return;
      }
      if (usedDocTypes.contains(attachment.documentTypeId)) {
        _showError('Duplicate document type selected. Each type can be used only once.');
        return;
      }
      usedDocTypes.add(attachment.documentTypeId!);
    }

    setState(() => _isSubmitting = true);

    try {
      final leadId = await _createLead();
      if (leadId == null) return;

      if (_attachments.isNotEmpty) {
        setState(() {
          _isSubmitting = false;
          _uploadingDocuments = true;
        });

        bool allUploaded = true;
        for (var attachment in _attachments) {
          final success = await _uploadDocument(leadId, attachment);
          if (!success) {
            allUploaded = false;
            break;
          }
        }

        setState(() => _uploadingDocuments = false);

        if (!allUploaded) return;
      }

      context.read<LeadProvider>().refreshLeads();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lead added successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _uploadingDocuments = false;
        });
      }
    }
  }

  // ---------- Create Lead ----------
  Future<String?> _createLead() async {
    final body = <String, dynamic>{
      'source': 'app-android',
      'customer_name': _nameController.text.trim(),
      'mobile': _mobileController.text.trim(),
      'email': _emailController.text.trim(),
      'lob_id': _selectedTypeId.toString(),
      'lead_status_id': _selectedStatusId.toString(),
      'lead_reference_master_id': _selectedReferenceId.toString(),
      'pincode': _pincodeController.text.trim(),
      'remarks': _remarksController.text.trim(),
      'notes': _referenceDetailsController.text.trim(),
      'date_time': formatDateTime(DateTime.now()),
      'vehicle_no': _isMotorSelected ? _vehicleNoController.text.trim() : '',
      'policy_no': _isMotorSelected ? '' : _policyNoController.text.trim(),
    };

    final loginData = await PreferenceManager.getLoginData();
    final token = loginData?.token;
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null) headers['Authorization'] = 'Bearer $token';

    final api = ApiService();
    final response = await api.postWithProgress(
      ApiConfig.leadCreateUrl,
      data: body,
      headers: headers,
    );

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final json = response.data;
      if (json is Map<String, dynamic> && json['status'] == true) {
        final data = json['data'];
        if (data is Map<String, dynamic> && data.containsKey('id')) {
          return data['id'].toString();
        } else if (data is List && data.isNotEmpty) {
          return data[0]['id'].toString();
        } else {
          return json['id']?.toString();
        }
      } else {
        _showError(json['message'] ?? 'Failed to create lead');
        return null;
      }
    } else {
      _showError('Server error: ${response.statusCode}');
      return null;
    }
  }

  // ---------- Upload Document ----------
  Future<bool> _uploadDocument(String leadId, Attachment attachment) async {
    try {
      final loginData = await PreferenceManager.getLoginData();
      final token = loginData?.token;
      if (token == null) {
        _showError('Authentication token not found.');
        return false;
      }

      final uri = Uri.parse(ApiConfig.baseUrl + ApiConfig.documentUploadUrl);
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['lead_id'] = leadId
        ..fields['doc_type_id'] = attachment.documentTypeId!
        ..fields['source'] = 'app-android';

      final fileBytes = await attachment.file!.readAsBytes();
      final fileName = path.basename(attachment.file!.path);
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final json = jsonDecode(response.body);
          if (json is Map<String, dynamic> && json['status'] == true) {
            return true;
          } else {
            _showError(json['message'] ?? 'Failed to upload document');
            return false;
          }
        } catch (e) {
          _showError('Invalid response from server: $e');
          return false;
        }
      } else {
        String errorMsg = 'Upload failed (${response.statusCode})';
        try {
          final json = jsonDecode(response.body);
          if (json is Map && json.containsKey('message')) {
            errorMsg = json['message'] is List
                ? (json['message'] as List).join(', ')
                : json['message'];
          }
        } catch (_) {}
        _showError(errorMsg);
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('Error uploading document: $e\n$stackTrace');
      _showError('Error: $e');
      return false;
    }
  }

  String formatDateTime(DateTime date) {
    final now = DateTime.now();
    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      now.hour,
      now.minute,
      now.second,
    );
    return dateTime.toString().split('.').first;
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _policyNoController.dispose();
    _vehicleNoController.dispose();
    _pincodeController.dispose();
    _remarksController.dispose();
    _referenceDetailsController.dispose();
    super.dispose();
  }
}

// ---------- Attachment Model ----------
class Attachment {
  String? documentTypeId;
  File? file;
  String? fileName;

  Attachment({this.documentTypeId, this.file, this.fileName});
}