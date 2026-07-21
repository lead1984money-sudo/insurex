import 'package:flutter/material.dart';
import 'model/EarningItem.dart';
import 'EarningEditPopup.dart';

class EarningViewPopup extends StatelessWidget {
  final EarningItem earning;

  const EarningViewPopup({
    super.key,
    required this.earning,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Text(
                    'Earning Details',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ID (optional)
              _infoRow('ID', '#${earning.id}'),
              const SizedBox(height: 12),

              // Proposer Name
              _infoRow(
                'Proposer Name',
                earning.srMasterProposerName.isNotEmpty
                    ? earning.srMasterProposerName
                    : 'N/A',
              ),
              const SizedBox(height: 12),

              // Policy No
              _infoRow(
                'Policy No',
                earning.srMasterPolicyNo.isNotEmpty
                    ? earning.srMasterPolicyNo
                    : 'N/A',
              ),
              const SizedBox(height: 12),

              // Vehicle No
              _infoRow(
                'Vehicle No',
                earning.srMasterVehicleNo.isNotEmpty
                    ? earning.srMasterVehicleNo
                    : 'N/A',
              ),
              const SizedBox(height: 12),

              // Partner
              _infoRow(
                'Partner',
                earning.partnerName.isNotEmpty
                    ? earning.partnerName
                    : 'N/A',
              ),
              const SizedBox(height: 12),

              // Partner Mobile
              _infoRow(
                'Partner Mobile',
                earning.partnerMobile.isNotEmpty
                    ? earning.partnerMobile
                    : 'N/A',
              ),
              const SizedBox(height: 12),

              // Gross Amount
              _infoRow(
                'Gross Amount',
                '₹ ${earning.payInAmount.toStringAsFixed(2)}',
                valueColor: Colors.deepPurple,
              ),
              const SizedBox(height: 12),

              // Cashback
              _infoRow(
                'Cashback to Customer',
                '₹ ${earning.cashbackCustomerAmount.toStringAsFixed(2)}',
                valueColor: Colors.orange,
              ),
              const SizedBox(height: 12),

              // Net Earning
              _infoRow(
                'Net Earning',
                '₹ ${earning.earningAmount.toStringAsFixed(2)}',
                valueColor: Colors.green,
              ),
              const SizedBox(height: 12),

              // Status
              _infoRow(
                'Status',
                earning.statusLabel,
                valueColor: earning.status == 1 ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 12),

              // Remarks
              _infoRow(
                'Remarks',
                earning.remarks.isNotEmpty ? earning.remarks : 'No remarks',
              ),
              const SizedBox(height: 12),

              // Created At
              _infoRow(
                'Created At',
                earning.createdAt,
              ),
              const SizedBox(height: 12),

              // Updated At
              _infoRow(
                'Updated At',
                earning.updatedAt,
              ),
              const SizedBox(height: 24),

              // Buttons: Close & Edit
              Center(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}