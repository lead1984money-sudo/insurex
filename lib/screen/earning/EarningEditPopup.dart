import 'package:flutter/material.dart';
import 'package:pdf_read/data/modifiednetwork/ApiConfig.dart';
import 'package:pdf_read/data/modifiednetwork/ApiService.dart';
import 'package:pdf_read/data/network/ConnectivityService.dart';
import 'package:pdf_read/data/sharedpreferences/PreferenceManager.dart';
import 'model/EarningItem.dart';
import 'model/PolicyItem.dart';

class EarningEditPopup extends StatefulWidget {
  final EarningItem earning;
  final List<PolicyItem> policies;   // full list
  final List<PartnerItem> partners;  // full list
  final VoidCallback onUpdated;

  const EarningEditPopup({
    super.key,
    required this.earning,
    required this.policies,
    required this.partners,
    required this.onUpdated,
  });

  @override
  State<EarningEditPopup> createState() => _EarningEditPopupState();
}

class _EarningEditPopupState extends State<EarningEditPopup> {
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiService _api = ApiService();

  late TextEditingController _grossController;
  late TextEditingController _cashbackController;
  late TextEditingController _netEarningController;
  late TextEditingController _remarksController;

  // Selected objects (by ID)
  PolicyItem? _selectedPolicy;
  PartnerItem? _selectedPartner;
  String _status = 'Active';

  bool _isLoading = false;
  String? _errorMessage;




  @override
  void initState() {
    super.initState();
    final e = widget.earning;


    // Find the current policy by its ID
    print('Policies count: ${widget.policies.length}');
    widget.policies.forEach((p) => print('Policy id: ${p.id}, label: ${p.label}'));

    try {
      _selectedPolicy = widget.policies.firstWhere((p) => p.id == e.srMastersId);
    } catch (_) {
      _selectedPolicy = null;
      print('Selected policy not found!');
    }

    // Find the current partner by its ID
    try {
      _selectedPartner = widget.partners.firstWhere((p) => p.id == e.partnerId);
    } catch (_) {
      _selectedPartner = null;
    }

    _grossController = TextEditingController(text: e.payInAmount.toString());
    _cashbackController = TextEditingController(text: e.cashbackCustomerAmount.toString());
    _netEarningController = TextEditingController(text: e.earningAmount.toString());
    _remarksController = TextEditingController(text: e.remarks);
    _status = e.statusLabel;
  }

  @override
  void dispose() {
    _grossController.dispose();
    _cashbackController.dispose();
    _netEarningController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final loginData = await PreferenceManager.getLoginData();
    return loginData?.token;
  }

  void _calculateNetEarning() {
    double gross = double.tryParse(_grossController.text) ?? 0;
    double cashback = double.tryParse(_cashbackController.text) ?? 0;
    _netEarningController.text = (gross - cashback).toStringAsFixed(2);
  }

  Future<void> _updateEarning() async {
    // Validate
    if (_selectedPolicy == null) {
      setState(() => _errorMessage = 'Please select a policy.');
      return;
    }
    if (_selectedPartner == null) {
      setState(() => _errorMessage = 'Please select a partner.');
      return;
    }
    double gross = double.tryParse(_grossController.text) ?? 0;
    if (gross <= 0) {
      setState(() => _errorMessage = 'Gross amount must be greater than 0.');
      return;
    }

    if (!await _connectivity.hasInternet()) {
      setState(() => _errorMessage = 'No internet connection.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await _getToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      int statusInt = _status == 'Active' ? 1 : 0;

      final body = {
        'id': widget.earning.id,
        'source': 'app-android',
        'sr_masters_id': _selectedPolicy!.id,
        'partner_id': _selectedPartner!.id,
        'pay_in_amount': double.tryParse(_grossController.text) ?? 0,
        'cashback_customer_amount': double.tryParse(_cashbackController.text) ?? 0,
        'remarks': _remarksController.text.trim(),
        'status': statusInt,
      };

      final response = await _api.postWithProgress(
        ApiConfig.earningsUpdateUrl,
        data: body,
        headers: headers,
      );

      setState(() => _isLoading = false);

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          widget.onUpdated();
          Navigator.pop(context);
        } else {
          setState(() => _errorMessage = json['message'] ?? 'Update failed');
        }
      } else {
        setState(() => _errorMessage = 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Edit Earning',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Policy Dropdown (dynamic)
              DropdownButtonFormField<PolicyItem>(
                value: _selectedPolicy,
                decoration: const InputDecoration(
                  labelText: 'Policy List *',
                  border: OutlineInputBorder(),
                ),
                items: widget.policies
                    .map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(p.label),
                ))
                    .toList(),
                onChanged: (newPolicy) => setState(() => _selectedPolicy = newPolicy),
                isExpanded: true,
              ),
              const SizedBox(height: 16),

              // Partner Dropdown (dynamic)
              DropdownButtonFormField<PartnerItem>(
                value: _selectedPartner,
                decoration: const InputDecoration(
                  labelText: 'Partner *',
                  border: OutlineInputBorder(),
                ),
                items: widget.partners
                    .map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(p.name),
                ))
                    .toList(),
                onChanged: (newPartner) => setState(() => _selectedPartner = newPartner),
                isExpanded: true,
              ),
              const SizedBox(height: 16),

              // Gross & Cashback
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _grossController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Gross Amount *',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _calculateNetEarning(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cashbackController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cashback To Customer',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _calculateNetEarning(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Net Earning & Status
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _netEarningController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Net Earning',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Active', child: Text('Active')),
                        DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                      ],
                      onChanged: (val) => setState(() => _status = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Remarks
              TextFormField(
                controller: _remarksController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Remarks',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateEarning,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff6C3EF4),
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text('Update Earning'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}