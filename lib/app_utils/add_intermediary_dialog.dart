import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pdf_read/app_utils/ColorsPicks.dart';
import 'package:pdf_read/app_utils/app_images.dart';

/// Shows a full‑featured Add Intermediary dialog.
/// Returns the newly created intermediary name (or null if cancelled).
Future<String?> showAddIntermediaryDialog(BuildContext context) async {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const _AddIntermediaryDialog();
    },
  );
}

// ─── Private Dialog Widget ────────────────────────────────────────
class _AddIntermediaryDialog extends StatefulWidget {
  const _AddIntermediaryDialog();

  @override
  State<_AddIntermediaryDialog> createState() => _AddIntermediaryDialogState();
}

class _AddIntermediaryDialogState extends State<_AddIntermediaryDialog> {
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _contactPersonController = TextEditingController();
  final TextEditingController _contactPersonMobileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _selectedStatus; // 'Active' or 'Inactive'
  final List<String> _statusOptions = ['Active', 'Inactive'];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _contactPersonController.dispose();
    _contactPersonMobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedStatus != null) {
      // Return the name (or the full data if needed)
      Navigator.pop(context, _nameController.text.trim());
    } else if (_selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final headingColor = black;
    final textColorLight = textColor;
    final inputBgColor = white.withOpacity(0.15);
    final cardBgColor = white.withOpacity(0.25);
    final cardBorderColor = white.withOpacity(0.4);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Container(
       // width: double.maxWidth,
        width: 600,
        constraints: const BoxConstraints(maxWidth: 500),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: cardBorderColor),
              boxShadow: [
                // BoxShadow(
                //   color: black.withOpacity(0.08),
                //   blurRadius: 20,
                //   offset: const Offset(0, 10),
                // ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Center(
                      child: Text(
                        'Add Intermediary',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: headingColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ─── Form Fields ──────────────────────────
                    _buildTextField(
                      label: 'Name *',
                      hint: 'Enter Name',
                      controller: _nameController,
                      inputBgColor: inputBgColor,
                      textColorLight: textColorLight,
                      validator: (v) => v!.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      label: 'Email',
                      hint: 'Enter Email',
                      controller: _emailController,
                      inputBgColor: inputBgColor,
                      textColorLight: textColorLight,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      label: 'Mobile No *',
                      hint: 'Enter Mobile No.',
                      controller: _mobileController,
                      inputBgColor: inputBgColor,
                      textColorLight: textColorLight,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v!.isEmpty) return 'Mobile number is required';
                        if (v.length < 10) return 'Enter a valid mobile number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      label: 'Contact Person',
                      hint: 'Enter Contact Person',
                      controller: _contactPersonController,
                      inputBgColor: inputBgColor,
                      textColorLight: textColorLight,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      label: 'Contact Person Mobile No',
                      hint: 'Enter Contact Person Mobile No.',
                      controller: _contactPersonMobileController,
                      inputBgColor: inputBgColor,
                      textColorLight: textColorLight,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      label: 'Address',
                      hint: 'Enter Address',
                      controller: _addressController,
                      inputBgColor: inputBgColor,
                      textColorLight: textColorLight,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),

                    // Status dropdown
                    _buildDropdown(
                      label: 'Status *',
                      hint: 'Select Status',
                      value: _selectedStatus,
                      items: _statusOptions,
                      onChanged: (val) => setState(() => _selectedStatus = val),
                      inputBgColor: inputBgColor,
                    ),
                    const SizedBox(height: 20),

                    // ─── Buttons ──────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: blueColor,
                              foregroundColor: white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text('Save Intermediary'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: headingColor,
                              side: BorderSide(color: headingColor.withOpacity(0.5)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Helper: TextField ──────────────────────────────────────────
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required Color inputBgColor,
    required Color textColorLight,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColorLight,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: inputBgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: white.withOpacity(0.3)),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: TextStyle(color: textColorLight, fontSize: 14),
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: textColorLight.withOpacity(0.6),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Helper: Dropdown ──────────────────────────────────────────
  Widget _buildDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required Color inputBgColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: inputBgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: white.withOpacity(0.3)),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            hint: Text(
              hint,
              style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 14),
            ),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
            onChanged: onChanged,
            validator: (val) => val == null ? 'Status is required' : null,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            dropdownColor: Colors.white.withOpacity(0.9),
            style: TextStyle(color: textColor, fontSize: 14),
          ),
        ),
      ],
    );
  }
}