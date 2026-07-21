import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_read/screen/lead/model/lead_detail_model.dart';
import 'package:pdf_read/screen/lead/model/lead_model.dart';
import 'package:provider/provider.dart';
import 'package:pdf_read/screen/lead/provider/LeadProvider.dart';
import '../myBusiness/provider/PolicyProvider.dart';
import '../pdfviewer/PdfViewerScreen.dart'; // ⬅️ ADD THIS

class LeadViewPopup extends StatefulWidget {
  final Lead lead;
  final LeadDetail detail;
  final List<Map<String, dynamic>> statuses; // list of {id, name}
  final VoidCallback? onUpdate;

  const LeadViewPopup({
    super.key,
    required this.lead,
    required this.detail,
    required this.statuses,
    this.onUpdate,
  });

  @override
  State<LeadViewPopup> createState() => _LeadViewPopupState();
}

class _LeadViewPopupState extends State<LeadViewPopup> {
  Map<String, dynamic>? _selectedStatus;
  DateTime? _selectedDateTime;
  bool _isUpdating = false;
  final TextEditingController _remarksController = TextEditingController();
  String? _pdfFileName;
  File? _policyFile;



  @override
  void initState() {
    super.initState();
    final currentStatusName = widget.lead.status;
    _selectedStatus = widget.statuses.firstWhere(
          (s) => s['name'] == currentStatusName,
      orElse: () => widget.statuses.isNotEmpty ? widget.statuses.first : {},
    );
  }

  bool get _showDateTime => _selectedStatus?['name'] == 'followup';
  bool get _showPdfUpload => _selectedStatus?['name'] == 'complete';

  // ---------- Date & Time Picker ----------
  Future<void> _selectDateTime(BuildContext context) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? now),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  // ---------- PDF Upload ----------
  Future<void> _uploadPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );
      if (result == null) return;

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;

      setState(() {
        _policyFile = file;
        _pdfFileName = fileName;
        _isUpdating = true;
      });
    } catch (e) {
      setState(() {
        _policyFile = null;
        _pdfFileName = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF upload error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  // ---------- Update Status API ----------
  Future<void> _updateStatus() async {
    if (_selectedStatus == null || _selectedStatus!['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid status')),
      );
      return;
    }

    final remarks = _remarksController.text.trim();
    if (remarks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter remarks')),
      );
      return;
    }

    final statusName = _selectedStatus!['name'] as String;

    if (statusName == 'followup' && _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a follow-up date & time')),
      );
      return;
    }

    if (statusName == 'complete' && _policyFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a PDF policy file')),
      );
      return;
    }

    setState(() => _isUpdating = true);

    try {
      final provider = Provider.of<LeadProvider>(context, listen: false);
      final statusId = int.parse(_selectedStatus!['id'].toString());

      final success = await provider.updateLeadStatus(
        leadId: widget.lead.id.toString(),
        statusId: statusId,
        followupDateTime: _selectedDateTime,
        remarks: remarks,
        policyFile: _policyFile,
      );

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status updated successfully')),
        );
        widget.onUpdate?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  // ---------- Open Document (View / Download) ----------
  // ─── File action (View / Download) ─────────────────────────────
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

  // ---------- Document Section ----------
  Widget _buildDocumentsSection() {
    final documents = widget.lead.documents ?? [];
    if (documents.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.10),
            blurRadius: 20,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.attach_file, color: Colors.blue),
              const SizedBox(width: 10),
              const Text(
                "Documents",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              )
            ],
          ),
          const SizedBox(height: 15),
          ...documents.map((doc) => _buildDocumentTile(doc)).toList(),
        ],
      ),
    );
  }

  Widget _buildDocumentTile(dynamic doc) {
    final name = doc['name'] ?? 'Document';
    final fileUrl = doc['file_url'] ?? '';
    final createdAt = doc['created_at'] ?? '';
    final docType = doc['doc_type_name'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: Colors.red, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                if (docType.isNotEmpty)
                  Text(
                    docType,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                if (createdAt.isNotEmpty)
                  Text(
                    createdAt,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
              ],
            ),
          ),

          IconButton(
            onPressed: () =>_handleFileAction(context, name, 'view'),
            icon: const Icon(Icons.visibility, color: Colors.blue),
            tooltip: 'View',
          ),
          IconButton(
            onPressed: () => _handleFileAction(context, name, 'download'),
            icon: const Icon(Icons.download, color: Colors.blue),
            tooltip: 'Download',
          ),
        ],
      ),
    );
  }

  // ---------- Build UI ----------
  @override
  Widget build(BuildContext context) {
    final lead = widget.lead;
    final detail = widget.detail;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 550,
              maxHeight: 750,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.95),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.12),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildLeadCard(),
                        const SizedBox(height: 16),
                        _buildSectionCard(
                          title: "Lead Information",
                          icon: Icons.info_outline,
                          children: [
                            _buildInfoRow(Icons.person, "Name", lead.name),
                            _buildInfoRow(Icons.phone, "Mobile", lead.mobile),
                            _buildInfoRow(Icons.email, "Email", lead.email),
                            _buildInfoRow(Icons.location_on, "Pincode", lead.pincode),
                            _buildInfoRow(Icons.category, "LOB", lead.type),
                            _buildInfoRow(Icons.public, "Source", lead.source),
                            _buildInfoRow(Icons.people_outline, "Reference", lead.reference ?? "N/A"),
                            _buildInfoRow(Icons.policy, "Policy No", lead.policyNo ?? "N/A"),
                            _buildInfoRow(Icons.directions_car, "Vehicle No", lead.vehicleNo ?? "N/A"),
                            _buildInfoRow(Icons.home, "Address", lead.address ?? "N/A"),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildSectionCard(
                          title: "Notes & Remarks",
                          icon: Icons.note_alt_outlined,
                          children: [
                            _buildInfoRow(Icons.description_outlined, "Lead Details", lead.leadDetails ?? "N/A"),
                            _buildInfoRow(Icons.note, "Notes", lead.notes ?? "N/A"),
                            _buildInfoRow(Icons.comment, "Remarks", lead.remarks ?? "N/A"),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildSectionCard(
                          title: "Activity History",
                          icon: Icons.history,
                          children: detail.history.isEmpty
                              ? [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                "No history available",
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            )
                          ]
                              : detail.history.map((h) => _buildHistoryTile(h)).toList(),
                        ),
                        const SizedBox(height: 16),

                        // ---------- NEW: Documents Section ----------
                        _buildDocumentsSection(),
                        const SizedBox(height: 16),

                        // ---------- Update Status ----------
                        if (lead.status.toLowerCase() != "complete")
                          _buildUpdateStatusCard(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── HEADER ──────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.blueAccent],
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.20),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Lead Details",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "Customer Information",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
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

  // ─── LEAD CARD ────────────────────────────────────────────
  Widget _buildLeadCard() {
    final lead = widget.lead;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_getStatusColor(lead.status).withOpacity(.12), Colors.white],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: _getStatusColor(lead.status),
            child: Text(
              lead.name.isNotEmpty ? lead.name[0].toUpperCase() : "L",
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lead.name,
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  lead.mobile,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor(lead.status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              lead.status.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SECTION CARD ──────────────────────────────────────────
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.10),
            blurRadius: 20,
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color:  Colors.blue),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              )
            ],
          ),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  // ─── INFO ROW ──────────────────────────────────────────────
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HISTORY TILE ───────────────────────────────────────────
  Widget _buildHistoryTile(History history) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: _getStatusColor(history.leadStatusName),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      history.leadStatusName.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(history.leadStatusName),
                      ),
                    ),
                    Text(
                      history.dateTime,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
                if (history.remarks != null && history.remarks!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      history.remarks!,
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── STATUS COLOR ─────────────────────────────────────────
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'complete':
        return Colors.green;
      case 'followup':
        return Colors.orange;
      case 'lost':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  // ─── UPDATE STATUS CARD ────────────────────────────────────
  Widget _buildUpdateStatusCard() {
    List<Map<String, dynamic>> filteredStatuses = widget.statuses;
    if (widget.lead.status.toLowerCase() == 'followup') {
      filteredStatuses = widget.statuses
          .where((s) => s['name'].toString().toLowerCase() != 'pending')
          .toList();
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.10),
            blurRadius: 20,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.update, color: Colors.blue),
              const SizedBox(width: 10),
              const Text(
                "Update Status",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              )
            ],
          ),
          const SizedBox(height: 15),
          DropdownButtonFormField<String>(
            value: _selectedStatus != null ? _selectedStatus!['name'] as String? : null,
            decoration: const InputDecoration(
              labelText: "Lead Status",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            items: filteredStatuses.map((status) {
              final name = status['name'] as String;
              return DropdownMenuItem(
                value: name,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getStatusColor(name),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(name),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStatus = widget.statuses.firstWhere(
                      (s) => s['name'] == value,
                );
                if (!_showPdfUpload) {
                  _policyFile = null;
                  _pdfFileName = null;
                }
                if (!_showDateTime) {
                  _selectedDateTime = null;
                }
              });
            },
          ),
          const SizedBox(height: 14),

          Visibility(
            visible: _showDateTime,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _selectDateTime(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Select follow-up date & time",
                        hintText: "Choose date & time",
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        suffixIcon: const Icon(Icons.calendar_today, color: Colors.blue),
                      ),
                      controller: TextEditingController(
                        text: _selectedDateTime != null
                            ? "${_selectedDateTime!.toLocal()}".split('.')[0]
                            : "",
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),

          Visibility(
            visible: _showPdfUpload,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Upload Policy Document (PDF)",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isUpdating ? null : _uploadPdf,
                        icon: const Icon(Icons.upload_file),
                        label: const Text("Choose PDF"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:  Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    if (_pdfFileName != null) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _pdfFileName!,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),

          TextFormField(
            controller: _remarksController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: "Remarks",
              hintText: "Add any additional notes...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isUpdating ? null : _updateStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor:  Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isUpdating
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text(
                "Save Changes",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}