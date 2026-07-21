import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:pdf_read/app_utils/ColorsPicks.dart';
import 'package:pdf_read/app_utils/app_images.dart';
import '../../app_utils/add_intermediary_dialog.dart'; // ✅ import



class PayAddScreen extends StatefulWidget {
  const PayAddScreen({super.key});

  @override
  State<PayAddScreen> createState() => _PayAddcreenState();
}

class _PayAddcreenState extends State<PayAddScreen> {
  // ─── Controllers ──────────────────────────────────────────────
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _cashbackController = TextEditingController();
  final TextEditingController _earningController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  String? _selectedPolicy;
  String? _selectedIntermediary;
  String? _selectedStatus;

  // Mutable list for intermediaries
  List<String> _intermediaries = [
    'Amit Sharma',
    'Rahul Verma',
    'Sunita Devi',
    'Manoj Patel',
    'Priya Singh'
  ];

  final List<String> _policies = ['POL123456', 'POL123457', 'POL123458'];
  final List<String> _statuses = ['Completed', 'Pending'];

  final List<Map<String, dynamic>> _recentPayIns = [
    {
      'name': 'Amit Sharma',
      'policy': 'POL123456',
      'cashback': 500,
      'earning': 4500,
      'status': 'Completed',
    },
    {
      'name': 'Rahul Verma',
      'policy': 'POL123457',
      'cashback': 300,
      'earning': 2700,
      'status': 'Pending',
    },
    {
      'name': 'Sunita Devi',
      'policy': 'POL123458',
      'cashback': 800,
      'earning': 7200,
      'status': 'Pending',
    },
    {
      'name': 'Manoj Patel',
      'policy': 'POL123459',
      'cashback': 2500,
      'earning': 2250,
      'status': 'Completed',
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _cashbackController.dispose();
    _earningController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  // ─── Form submission ──────────────────────────────────────────
  void _submitForm() {
    if (_selectedPolicy == null ||
        _selectedIntermediary == null ||
        _amountController.text.isEmpty ||
        _selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pay In added successfully!')),
    );
    setState(() {
      _selectedPolicy = null;
      _selectedIntermediary = null;
      _amountController.clear();
      _cashbackController.clear();
      _earningController.clear();
      _remarksController.clear();
      _selectedStatus = null;
    });
  }

  // ─── Add intermediary via popup ──────────────────────────────
  Future<void> _addIntermediary() async {
    final newName = await showAddIntermediaryDialog(context);
    if (newName != null && newName.isNotEmpty) {
      setState(() {
        if (!_intermediaries.contains(newName)) {
          _intermediaries.add(newName);
          _selectedIntermediary = newName; // auto‑select
        }
      });
    }
  }

  // ─── Build ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final overlayColor = white.withOpacity(0.3);
    final textColorLight = textColor;
    final headingColor = black;
    final cardBgColor = white.withOpacity(0.25);
    final cardBorderColor = white.withOpacity(0.4);
    final inputBgColor = white.withOpacity(0.15);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
          color: headingColor,
        ),
        title: const Text('Add Pay In'),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: headingColor,
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.background),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(color: overlayColor),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _glassCard(
                      bgColor: cardBgColor,
                      borderColor: cardBorderColor,
                      child: Column(
                        children: [
                          // Policy dropdown
                          _buildDropdown(
                            label: 'Policy *',
                            hint: 'Select Policy',
                            value: _selectedPolicy,
                            items: _policies,
                            onChanged: (val) => setState(() => _selectedPolicy = val),
                            inputBgColor: inputBgColor,
                          ),
                          const SizedBox(height: 16),
                          // Intermediary field with add button
                          _buildIntermediaryField(
                            label: 'Intermediary *',
                            hint: 'Select Intermediary',
                            selected: _selectedIntermediary,
                            items: _intermediaries,
                            onChanged: (val) => setState(() => _selectedIntermediary = val),
                            inputBgColor: inputBgColor,
                            onAddPressed: _addIntermediary,
                          ),
                          const SizedBox(height: 16),

                          // Amount
                          _buildTextField(
                            label: 'Amount (₮) *',
                            hint: 'Enter Amount',
                            controller: _amountController,
                            inputBgColor: inputBgColor,
                            textColorLight: textColorLight,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),

                          // Cashback
                          _buildTextField(
                            label: 'Cashback (₮)',
                            hint: 'Enter Cashback',
                            controller: _cashbackController,
                            inputBgColor: inputBgColor,
                            textColorLight: textColorLight,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),

                          // Earning Amount
                          _buildTextField(
                            label: 'Earning Amount (₮)',
                            hint: 'Enter Earning Amount',
                            controller: _earningController,
                            inputBgColor: inputBgColor,
                            textColorLight: textColorLight,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),

                          // Remarks
                          _buildTextField(
                            label: 'Remarks',
                            hint: 'Enter Remarks',
                            controller: _remarksController,
                            inputBgColor: inputBgColor,
                            textColorLight: textColorLight,
                          ),
                          const SizedBox(height: 16),

                          // Status dropdown
                          _buildDropdown(
                            label: 'Status *',
                            hint: 'Select Status',
                            value: _selectedStatus,
                            items: _statuses,
                            onChanged: (val) => setState(() => _selectedStatus = val),
                            inputBgColor: inputBgColor,
                          ),
                          const SizedBox(height: 20),

                          // Add Pay In Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: blueColor,
                                foregroundColor: white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Add Pay In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ─── Recent Pay In ──────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Pay In',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: headingColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('View All Pay In tapped')),
                            );
                          },
                          child: Text(
                            'View All',
                            style: TextStyle(
                              color: blueColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _recentPayIns.length,
                      itemBuilder: (context, index) {
                        final item = _recentPayIns[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _glassCard(
                            bgColor: cardBgColor,
                            borderColor: cardBorderColor,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: headingColor,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: item['status'] == 'Completed'
                                            ? Colors.green
                                            : Colors.orange,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        item['status'],
                                        style: const TextStyle(
                                          color: white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Policy: ${item['policy']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: textColorLight,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      'Cashback: ₮ ${item['cashback']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: textColorLight,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Earning: ₮ ${item['earning']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: textColorLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Intermediary field with add button ──────────────────────
  Widget _buildIntermediaryField({
    required String label,
    required String hint,
    required String? selected,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required Color inputBgColor,
    required VoidCallback onAddPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: DropdownSearch<String>(
                items: items,
                selectedItem: selected,
                onChanged: onChanged,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    hintText: hint,
                    filled: true,
                    fillColor: inputBgColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    suffixIcon: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_outline, color: Colors.grey),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: 'Search intermediary...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  itemBuilder: (context, item, isSelected) {
                    return ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(item),
                      trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
                    );
                  },
                ),
                dropdownButtonProps: const DropdownButtonProps(
                  icon: SizedBox.shrink(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: blueColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: onAddPressed,
                icon: const Icon(Icons.add, color: Colors.white),
                tooltip: 'Add Intermediary',
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Glass Card ──────────────────────────────────────────────────
  Widget _glassCard({
    required Widget child,
    Color? bgColor,
    Color? borderColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: bgColor ?? white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: borderColor ?? white.withOpacity(0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // ─── Normal Dropdown (Policy & Status) ─────────────────────────
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
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
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
              style: TextStyle(color: textColor.withOpacity(0.6)),
            ),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            dropdownColor: Colors.white.withOpacity(0.9),
            style: TextStyle(color: textColor),
          ),
        ),
      ],
    );
  }

  // ─── TextField helper ───────────────────────────────────────────
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required Color inputBgColor,
    required Color textColorLight,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColorLight,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: inputBgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: white.withOpacity(0.3)),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(color: textColorLight),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: textColorLight.withOpacity(0.6)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}