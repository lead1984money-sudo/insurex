import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_utils/app_images.dart';
import '../myBusiness/model/policy_model.dart';
import '../pdfviewer/PdfViewerScreen.dart';
import 'provider/PolicyHistoryProvider.dart';

class PolicyHistoryScreen extends StatefulWidget {
  const PolicyHistoryScreen({super.key});

  @override
  State<PolicyHistoryScreen> createState() => _PolicyHistoryScreenState();
}

class _PolicyHistoryScreenState extends State<PolicyHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'all';


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PolicyHistoryProvider>().fetchPolicies();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      context.read<PolicyHistoryProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Policy History',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.background),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: Consumer<PolicyHistoryProvider>(
          builder: (context, provider, child) {
            if (provider.errorMessage.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(provider.errorMessage),
                    ElevatedButton(
                      onPressed: () {
                        provider.clearError();
                        provider.fetchPolicies();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (provider.isLoading && provider.policies.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                // ─── Filter Tabs ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildFilterTab('All', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterTab('Success', 'success'),
                      const SizedBox(width: 8),
                      _buildFilterTab('Fail', 'fail'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // ─── Count ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedFilter == 'all'
                            ? 'All Policies'
                            : '${_selectedFilter.toUpperCase()} Policies',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${provider.policies.length} policies',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // ─── List ──────────────────────────────────────
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.policies.length +
                        (provider.hasMore && provider.policies.isNotEmpty
                            ? 1
                            : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.policies.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final policy = provider.policies[index];
                      return _PolicyCard(policy: policy);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = value;
          });
          context.read<PolicyHistoryProvider>().setFilter(value);
        },
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade100 : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.blue.shade400 : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Policy Card (unchanged) ──────────────────────────────────────
// ─── Policy Card (with tap popup) ───────────────────────────────
class _PolicyCard extends StatelessWidget {
  final PolicyData policy;
  const _PolicyCard({required this.policy});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPolicyDetailsDialog(context, policy),
      child: Card(
        margin: const EdgeInsets.only(bottom: 14),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      policy.proposerName ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(policy.endDate),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _infoTile('Policy Number', policy.policyNo ?? 'N/A'),
                  ),
                  Expanded(
                    child: _infoTile('Insurer', policy.insurerName ?? 'N/A'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _infoTile('LOB', policy.lobName ?? 'N/A'),
                  ),
                  Expanded(
                    child: _infoTile('Product', policy.productName ?? 'N/A'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _infoTile('Start Date', policy.startDate ?? 'N/A'),
                  ),
                  Expanded(
                    child: _infoTile('End Date', policy.endDate ?? 'N/A'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _actionButton(
                    icon: Icons.visibility_outlined,
                    label: 'View',
                    onTap: () => _handleFileAction(context, policy.fileName!, 'view'),
                  ),
                  const SizedBox(width: 16),
                  _actionButton(
                    icon: Icons.download_outlined,
                    label: 'Download',
                    onTap: () => _handleFileAction(context, policy.fileName!, 'download'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Show details popup (only non‑null/empty fields) ──────────
  void _showPolicyDetailsDialog(BuildContext context, PolicyData policy) {
    final details = <String, String>{};

    if (policy.id.isNotEmpty) details['ID'] = policy.id;
    if (policy.userId != null && policy.userId!.isNotEmpty) details['User ID'] = policy.userId!;
    if (policy.lobId != null) details['LOB ID'] = policy.lobId.toString();
    if (policy.lobName != null && policy.lobName!.isNotEmpty) details['LOB Name'] = policy.lobName!;
    if (policy.productId != null) details['Product ID'] = policy.productId.toString();
    if (policy.productName != null && policy.productName!.isNotEmpty) details['Product Name'] = policy.productName!;
    if (policy.masterId != null && policy.masterId!.isNotEmpty) details['Master ID'] = policy.masterId!;
    if (policy.insuranceMasterId != null && policy.insuranceMasterId!.isNotEmpty) {
      details['Insurance Master ID'] = policy.insuranceMasterId!;
    }
    if (policy.insurerName != null && policy.insurerName!.isNotEmpty) details['Insurer Name'] = policy.insurerName!;
    if (policy.proposerName != null && policy.proposerName!.isNotEmpty) details['Proposer Name'] = policy.proposerName!;
    if (policy.policyNo != null && policy.policyNo!.isNotEmpty) details['Policy Number'] = policy.policyNo!;
    if (policy.vehicleNo != null && policy.vehicleNo!.isNotEmpty) details['Vehicle Number'] = policy.vehicleNo!;
    if (policy.startDate != null && policy.startDate!.isNotEmpty) details['Start Date'] = policy.startDate!;
    if (policy.endDate != null && policy.endDate!.isNotEmpty) details['End Date'] = policy.endDate!;
    if (policy.fileName != null && policy.fileName!.isNotEmpty) details['File Name'] = policy.fileName!;
    if (policy.createdAt != null && policy.createdAt!.isNotEmpty) details['Created At'] = policy.createdAt!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Policy Details', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: details.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          '${entry.key}:',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Text(entry.value),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // ─── File action (View / Download) ─────────────────────────────
  void _handleFileAction(BuildContext context, String fileUrl, String actionType) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final provider = context.read<PolicyHistoryProvider>();
    final signedUrl = await provider.getFileUrl(fileUrl, actionType);

    Navigator.of(context).pop();

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

  // ─── Status chip (Active / Expired) ────────────────────────────
  Widget _buildStatusChip(String? endDate) {
    bool isActive = true;
    if (endDate != null && endDate.isNotEmpty) {
      try {
        final date = DateTime.parse(endDate);
        isActive = date.isAfter(DateTime.now());
      } catch (_) {
        isActive = false;
      }
    }
    final status = isActive ? 'Active' : 'Expired';
    final color = isActive ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ─── Info tile ──────────────────────────────────────────────────
  Widget _infoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ─── Action button ──────────────────────────────────────────────
  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.blue.shade700),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}