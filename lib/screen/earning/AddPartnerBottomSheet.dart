import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf_read/screen/earning/provider/AddPartnerProvider.dart';

class AddPartnerBottomSheet extends StatefulWidget {
  final VoidCallback? onPartnerCreated;

  const AddPartnerBottomSheet({super.key, this.onPartnerCreated});

  @override
  State<AddPartnerBottomSheet> createState() => _AddPartnerBottomSheetState();
}

class _AddPartnerBottomSheetState extends State<AddPartnerBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddPartnerProvider(), // No arguments needed
      child: _AddPartnerView(
        onSuccess: () {
          Navigator.pop(context);
          widget.onPartnerCreated?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Partner created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }
}

// ---------- View (unchanged) ----------
class _AddPartnerView extends StatelessWidget {
  final VoidCallback onSuccess;

  const _AddPartnerView({required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddPartnerProvider>();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Form(
              key: provider.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Text(
                        "Add Partner",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Name
                  _buildTextField(
                    title: "Partner Name *",
                    controller: provider.nameController,
                    hint: "Enter partner name",
                  ),
                  const SizedBox(height: 18),

                  // Email
                  _buildTextField(
                    title: "Email *",
                    controller: provider.emailController,
                    hint: "email@example.com",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 18),

                  // Mobile
                  _buildTextField(
                    title: "Mobile *",
                    controller: provider.mobileController,
                    hint: "10-digit mobile",
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 18),

                  // Contact Person
                  _buildTextField(
                    title: "Contact Person *",
                    controller: provider.contactPersonController,
                    hint: "Contact person name",
                  ),
                  const SizedBox(height: 18),

                  // Contact Mobile
                  _buildTextField(
                    title: "Contact Mobile",
                    controller: provider.contactMobileController,
                    hint: "10-digit mobile",
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 18),

                  // Status
                  const Text(
                    "Status",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: provider.status,
                    decoration: _inputDecoration(),
                    items: const [
                      DropdownMenuItem(value: "Active", child: Text("Active")),
                      DropdownMenuItem(value: "Inactive", child: Text("Inactive")),
                    ],
                    onChanged: (value) => provider.setStatus(value!),
                  ),
                  const SizedBox(height: 18),

                  // Address
                  const Text(
                    "Address",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: provider.addressController,
                    maxLines: 4,
                    decoration: _inputDecoration(hint: "Partner Address"),
                  ),
                  const SizedBox(height: 30),

                  // Error message
                  if (provider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        provider.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                        final success = await provider.submit();
                        if (success) onSuccess();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff6C3EF4),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: provider.isLoading
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        "Create Partner",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required String title,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (value) {
            if (value == null || value.trim().isEmpty) return "Required";
            return null;
          },
          decoration: _inputDecoration(hint: hint),
        ),
      ],
    );
  }
}

InputDecoration _inputDecoration({String? hint}) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xffF8F9FC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: Color(0xff6C3EF4)),
    ),
  );
}