import 'package:flutter/material.dart';
import 'package:pdf_read/screen/earning/provider/EarningProvider.dart';
import 'package:provider/provider.dart';
import 'package:pdf_read/screen/earning/provider/EarningAddProvider.dart';
import 'AddPartnerBottomSheet.dart';

class EarningAddScreen extends StatefulWidget {
  final VoidCallback? onEarningCreated;

  const EarningAddScreen({super.key, this.onEarningCreated});

  @override
  State<EarningAddScreen> createState() => _EarningAddScreenState();
}

class _EarningAddScreenState extends State<EarningAddScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EarningAddProvider(),
      child: _EarningAddView(
        onSuccess: () {

          final provider = context.read<EarningsProvider>();
          provider.init();
          Navigator.pop(context);
          widget.onEarningCreated?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Earning created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }
}

// ---------- Now _EarningAddView is Stateful and fetches data ----------
class _EarningAddView extends StatefulWidget {
  final VoidCallback onSuccess;

  const _EarningAddView({required this.onSuccess});

  @override
  State<_EarningAddView> createState() => _EarningAddViewState();
}

class _EarningAddViewState extends State<_EarningAddView> {
  bool _fetched = false;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to fetch after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_fetched) {
        final provider = context.read<EarningAddProvider>();
        provider.fetchPolicies();
        provider.fetchPartners();
        _fetched = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EarningAddProvider>();

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Add Earning",
          style: TextStyle(
            color: Color(0xff1A1D29),
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(.08),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // POLICY
                      _title("Policy List *"),
                      const SizedBox(height: 8),
                      if (provider.isLoadingPolicies)
                        const Center(child: CircularProgressIndicator())
                      else
                        _dropdown(
                          value: provider.selectedPolicyLabel,
                          hint: "Select policy",
                          items: provider.policyLabels,
                          onChanged: provider.setPolicyByLabel,
                        ),
                      const SizedBox(height: 20),

                      // PARTNER
                      _title("Partner *"),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: provider.isLoadingPartners
                                ? const Center(child: CircularProgressIndicator())
                                : _dropdown(
                              value: provider.selectedPartnerName,
                              hint: "Select partner",
                              items: provider.partnerLabels,
                              onChanged: provider.setPartnerByName,
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => AddPartnerBottomSheet(
                                  onPartnerCreated: () {
                                    // Refresh partner list after adding a new partner
                                    provider.fetchPartners();
                                  },
                                ),
                              );
                            },
                            child: Container(
                              height: 58,
                              width: 58,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xff6C3EF4),
                                ),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Color(0xff6C3EF4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // GROSS & CASHBACK
                      Row(
                        children: [
                          Expanded(
                            child: _textField(
                              title: "Gross Amount *",
                              controller: provider.grossController,
                              onChanged: (_) => provider.calculateNetEarning(),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _textField(
                              title: "Cashback to Customer",
                              controller: provider.cashbackController,
                              onChanged: (_) => provider.calculateNetEarning(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // NET EARNING & STATUS
                      Row(
                        children: [
                          Expanded(
                            child: _textField(
                              title: "Net Earning",
                              controller: provider.netEarningController,
                              readOnly: true,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _title("Status"),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: provider.status,
                                  decoration: _decoration(),
                                  items: ["Active", "Inactive"]
                                      .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                                      .toList(),
                                  onChanged: (value) => provider.setStatus(value!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // REMARKS
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _title("Remarks (optional)"),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: provider.remarksController,
                        maxLines: 5,
                        decoration: _decoration(hint: "Enter remarks"),
                      ),
                      const SizedBox(height: 30),

                      // ERROR MESSAGE
                      if (provider.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            provider.errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),

                      // SUBMIT BUTTON
                      SizedBox(
                        height: 56,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: provider.isLoading
                              ? null
                              : () async {
                            final success = await provider.submit();
                            if (success) {
                              widget.onSuccess();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xff6C3EF4),
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
                            "Submit",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _title(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xff1A1D29),
        ),
      ),
    );
  }

  static Widget _textField({
    required String title,
    required TextEditingController controller,
    bool readOnly = false,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(title),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          decoration: _decoration(hint: "0.00"),
        ),
      ],
    );
  }

  static Widget _dropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _decoration(),
      hint: Text(hint),
      items: items
          .map((e) => DropdownMenuItem(
        value: e,
        child: Text(e),
      ))
          .toList(),
      onChanged: onChanged,
    );
  }

  static InputDecoration _decoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xff6C3EF4)),
      ),
    );
  }
}