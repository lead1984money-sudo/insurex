import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf_read/screen/lead/model/lead_model.dart';
import 'model/lead_detail_model.dart';

class EditLeadPopup extends StatefulWidget {
  final Lead lead;
  final LeadDetail detail;
  final List<Map<String, dynamic>> statuses; // list of {id, name}
  final List<Map<String, dynamic>> leadReferences; // list of {id, name}
  final List<Map<String, dynamic>> lobs; // list of {id, name}
  final VoidCallback? onUpdate;

  const EditLeadPopup({
    super.key,
    required this.lead,
    required this.detail,
    required this.statuses,
    required this.leadReferences,
    required this.lobs,
    this.onUpdate,
  });

  @override
  State<EditLeadPopup> createState() => _EditLeadPopupState();
}

class _EditLeadPopupState extends State<EditLeadPopup> {
  // Controllers
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final policyController = TextEditingController();
  final pincodeController = TextEditingController();
  final referenceDetailsController = TextEditingController();
  final remarksController = TextEditingController();

  // Dropdown selected IDs (instead of names)
  int? _selectedStatusId;
  int? _selectedTypeId;
  int? _selectedReferenceId;

  // Documents list
  final List<DocumentItem> documents = [];

  @override
  void initState() {
    super.initState();
    final lead = widget.lead;

    // Pre‑fill text controllers
    nameController.text = lead.name;
    mobileController.text = lead.mobile;
    emailController.text = lead.email;
    policyController.text = lead.policyNo ?? '';
    pincodeController.text = lead.pincode;
    referenceDetailsController.text = lead.reference ?? '';
    remarksController.text = lead.notes ?? '';

    // Map the current status/type/reference names to their IDs
    _selectedStatusId = _getIdFromName(widget.statuses, lead.status);
    _selectedTypeId = _getIdFromName(widget.lobs, lead.type);
    _selectedReferenceId = _getIdFromName(widget.leadReferences, lead.leadReferenceName ?? '');


    print("LINE67");
    print(widget.leadReferences);
    print(_selectedReferenceId);
    print(lead.reference);

    documents.add(DocumentItem());


  }

  // Helper: find ID from a list of maps by name
  int? _getIdFromName(List<Map<String, dynamic>> list, String name) {
    final trimmedName = name.trim().toLowerCase();
    print('🔎 Searching for: "$trimmedName"');
    print('📋 Available: ${list.map((e) => '"${e['name']}"').toList()}');

    try {
      final map = list.firstWhere((item) {
        final itemName = item['name']?.toString().trim().toLowerCase() ?? '';
        final match = itemName == trimmedName;
        if (match) print('✅ Match found: "${item['name']}" -> id: ${item['id']}');
        return match;
      });
      final id = map['id'];
      print('➡️ Raw ID: $id (${id.runtimeType})');
      int? parsedId;
      if (id is int) parsedId = id;
      else if (id is String) parsedId = int.tryParse(id);
      print('➡️ Parsed ID: $parsedId');
      return parsedId;
    } catch (e) {
      print('❌ No match for "$trimmedName"');
      return null;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    policyController.dispose();
    pincodeController.dispose();
    referenceDetailsController.dispose();
    remarksController.dispose();
    super.dispose();
  }

  // File picker
  Future<void> pickFile(int index) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null) {
        setState(() {
          documents[index].file = File(result.files.single.path!);
          documents[index].fileName = result.files.single.name;
        });
      }
    } on PlatformException catch (_) {}
  }

  void removeDocument(int index) {
    setState(() {
      documents.removeAt(index);
    });
  }

  void addDocument() {
    setState(() {
      documents.add(DocumentItem());
    });
  }

  Future<void> _saveChanges() async {
    // Here you can collect all data and send to API
    // For now, just close and refresh
    Navigator.pop(context);
    widget.onUpdate?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lead updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 850),
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _leadInformationCard(),
                    const SizedBox(height: 20),
                    _attachmentCard(),
                  ],
                ),
              ),
            ),
            _bottomButtons(),
          ],
        ),
      ),
    );
  }

  // ─── HEADER ──────────────────────────────────────────────
  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 12, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.blueAccent],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.edit, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Edit Lead",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ─── LEAD INFORMATION CARD ──────────────────────────────
  Widget _leadInformationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_outline, color: Colors.blue),
              SizedBox(width: 10),
              Text(
                "Lead Information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff1E1B2E),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          // Row 1: Name & Mobile
          Row(
            children: [
              Expanded(
                child: _textField(
                  controller: nameController,
                  label: "Customer Name",
                  hint: "Enter full name",
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _textField(
                  controller: mobileController,
                  label: "Mobile",
                  hint: "10-digit number",
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _textField(
            controller: emailController,
            label: "Email",
            hint: "example@email.com",
          ),

          const SizedBox(height: 16),

          _dropdown(
            label: "Lead Type",
            value: _selectedTypeId,
            items: widget.lobs,
            onChanged: (id) => setState(() => _selectedTypeId = id),
          ),

          const SizedBox(height: 16),
          // Row 3: Policy & Pincode
          Row(
            children: [
              Expanded(
                child: _textField(
                  controller: policyController,
                  label: "Policy No",
                  hint: "Policy number",
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _textField(
                  controller: pincodeController,
                  label: "Pincode",
                  hint: "6-digit pincode",
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Row 4: Lead Status & Reference
          Row(
            children: [
              Expanded(
                child: _dropdown(
                  label: "Lead Status",
                  value: _selectedStatusId,
                  items: widget.statuses,
                  onChanged: (id) => setState(() => _selectedStatusId = id),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _dropdown(
                  label: "Reference",
                  value: _selectedReferenceId,
                  items: widget.leadReferences,
                  onChanged: (id) => setState(() => _selectedReferenceId = id),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Reference Details (full width)
          _textField(
            controller: referenceDetailsController,
            label: "Reference Details",
            hint: "Additional info about the reference",
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          // Remarks (full width)
          _textField(
            controller: remarksController,
            label: "Remarks",
            hint: "Any additional notes",
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  // ─── ATTACHMENT CARD ─────────────────────────────────────
  Widget _attachmentCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.attach_file, color: Colors.blue),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Attachments",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color(0xff1E1B2E),
                  ),
                ),
              ),
              IconButton(
                onPressed: addDocument,
                icon: const Icon(Icons.add_circle, color: Colors.blue),
                tooltip: "Add another attachment",
              ),
            ],
          ),
          const Divider(height: 24),
          ...List.generate(documents.length, (index) {
            final doc = documents[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: doc.documentType,
                          decoration: const InputDecoration(
                            labelText: "Document Type",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: const [
                            DropdownMenuItem(value: "Aadhar", child: Text("Aadhar")),
                            DropdownMenuItem(value: "PAN", child: Text("PAN")),
                            DropdownMenuItem(value: "Policy", child: Text("Policy")),
                          ],
                          onChanged: (value) {
                            setState(() {
                              doc.documentType = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (documents.length > 1)
                        IconButton(
                          onPressed: () => removeDocument(index),
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          tooltip: "Remove this attachment",
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => pickFile(index),
                    icon: const Icon(Icons.upload_file, color: Colors.blue),
                    label: Text(
                      doc.fileName ?? "Choose PDF or Image",
                      style: TextStyle(
                        color: doc.fileName != null ? Colors.green.shade700 : Colors.grey.shade600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  if (doc.fileName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.insert_drive_file, size: 16, color: Colors.green),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              doc.fileName!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── BOTTOM BUTTONS ──────────────────────────────────────
  Widget _bottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor:  Colors.blue,
                side: const BorderSide(color: Colors.blueAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("Cancel"),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.blueAccent],
                ),
                boxShadow: [
                  BoxShadow(
                    color:  Colors.blue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Save Changes",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HELPER WIDGETS ──────────────────────────────────────
  Widget _textField({
    required TextEditingController controller,
    required String label,
    String hint = '',
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // Updated dropdown that uses IDs and a list of maps
  Widget _dropdown({
    required String label,
    required int? value,
    required List<Map<String, dynamic>> items,
    required void Function(int?) onChanged,
  }) {
    return DropdownButtonFormField<int>(
      value: value,   // ✅ Just pass the value
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder:  OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: items.map((map) {
        final id = int.parse(map['id'].toString());
        return DropdownMenuItem<int>(
          value: id,
          child: Text(map['name'] as String),
        );
      }).toList(),
      onChanged: onChanged,
      icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
    );
  }
}

// ─── DOCUMENT MODEL ────────────────────────────────────────
class DocumentItem {
  File? file;
  String? fileName;
  String? documentType;

  DocumentItem({this.file, this.fileName, this.documentType});
}