import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pdf_read/app_utils/ColorsPicks.dart';
import 'package:pdf_read/app_utils/app_images.dart';
import 'package:pdf_read/app_utils/app_strings.dart';

// Simple Lead model for demonstration
class Lead {
  final String id;
  final String name;
  final String status; // e.g., "New", "Not‑connected", "Working"
  final String insuranceType;
  final String assignedTo;
  final String source;
  final String createdDate;
  final String followUpDate;

  Lead({
    required this.id,
    required this.name,
    required this.status,
    required this.insuranceType,
    required this.assignedTo,
    required this.source,
    required this.createdDate,
    required this.followUpDate,
  });
}

class ViewLeadScreen extends StatefulWidget {
  const ViewLeadScreen({super.key});

  @override
  State<ViewLeadScreen> createState() => _ViewLeadScreenState();
}

class _ViewLeadScreenState extends State<ViewLeadScreen> {
  // Sample leads data
  final List<Lead> _allLeads = [
    Lead(
      id: '1',
      name: 'test',
      status: 'New',
      insuranceType: 'Motor Insurance',
      assignedTo: 'Shiv Kuma',
      source: 'Social Media',
      createdDate: '23-06-2026 11:18 AM',
      followUpDate: '23-06-2026 04:47 PM',
    ),
    Lead(
      id: '2',
      name: 'Rahul Sharma',
      status: 'New',
      insuranceType: 'Health Insurance',
      assignedTo: 'Priya Singh',
      source: 'Website',
      createdDate: '24-06-2026 09:30 AM',
      followUpDate: '25-06-2026 02:00 PM',
    ),
    Lead(
      id: '3',
      name: 'Amit Patel',
      status: 'Not-connected',
      insuranceType: 'Life Insurance',
      assignedTo: 'Shiv Kuma',
      source: 'Referral',
      createdDate: '22-06-2026 04:15 PM',
      followUpDate: '23-06-2026 10:00 AM',
    ),
    Lead(
      id: '4',
      name: 'Sneha Reddy',
      status: 'Working',
      insuranceType: 'Auto Insurance',
      assignedTo: 'Ravi Kumar',
      source: 'Social Media',
      createdDate: '20-06-2026 11:45 AM',
      followUpDate: '24-06-2026 03:30 PM',
    ),
  ];

  // Filter state
  String _selectedFilter = 'All';

  // Get filtered leads based on selected filter
  List<Lead> get _filteredLeads {
    if (_selectedFilter == 'All') {
      return _allLeads;
    }
    return _allLeads.where((lead) => lead.status == _selectedFilter).toList();
  }

  // Filter options from the image (All, New, Not‑connected, Working)
  final List<String> _filters = ['All', 'New', 'Not-connected', 'Working'];

  @override
  Widget build(BuildContext context) {
    final overlayColor = white.withOpacity(0.3);
    final textColorLight = textColor;
    final headingColor = black;
    final cardBgColor = white.withOpacity(0.25);
    final cardBorderColor = white.withOpacity(0.4);

    return Scaffold(
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
            // Overlay
            Positioned.fill(
              child: Container(color: overlayColor),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with back button
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new),
                          color: headingColor,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'View All Lead',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: headingColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Filter Tabs (segmented control)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: cardBorderColor),
                      ),
                      child: Row(
                        children: _filters.map((filter) {
                          final isSelected = _selectedFilter == filter;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 8),
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? blueColor.withOpacity(0.8)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  filter,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected ? white : textColorLight,
                                    fontWeight:
                                    isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // List of leads
                    if (_filteredLeads.isEmpty)
                      Center(
                        child: Text(
                          'No leads found',
                          style: TextStyle(
                            color: textColorLight,
                            fontSize: 16,
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredLeads.length,
                        itemBuilder: (context, index) {
                          final lead = _filteredLeads[index];
                          return _buildLeadCard(
                            lead: lead,
                            cardBgColor: cardBgColor,
                            cardBorderColor: cardBorderColor,
                            headingColor: headingColor,
                            textColorLight: textColorLight,
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

  // Build a single lead card
  Widget _buildLeadCard({
    required Lead lead,
    required Color cardBgColor,
    required Color cardBorderColor,
    required Color headingColor,
    required Color textColorLight,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _glassCard(
        bgColor: cardBgColor,
        borderColor: cardBorderColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row: Name and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lead.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: headingColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(lead.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    lead.status,
                    style: const TextStyle(
                      color: white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Insurance Type
            _buildDetailRow(
              label: 'Insurance:',
              value: lead.insuranceType,
              textColorLight: textColorLight,
            ),
            const SizedBox(height: 6),

            // Assigned To
            _buildDetailRow(
              label: 'Assigned to:',
              value: lead.assignedTo,
              textColorLight: textColorLight,
            ),
            const SizedBox(height: 6),

            // Source
            _buildDetailRow(
              label: 'Source:',
              value: lead.source,
              textColorLight: textColorLight,
            ),
            const SizedBox(height: 6),

            // Created
            _buildDetailRow(
              label: 'Created:',
              value: lead.createdDate,
              textColorLight: textColorLight,
            ),
            const SizedBox(height: 6),

            // Follow up
            _buildDetailRow(
              label: 'Follow up:',
              value: lead.followUpDate,
              textColorLight: textColorLight,
            ),
            const SizedBox(height: 16),

            // Edit / Delete Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  color: blueColor,
                  onTap: () => _showEditDialog(lead),
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: Icons.delete_outline,
                  label: 'Delete',
                  color: Colors.redAccent,
                  onTap: () => _showDeleteConfirmation(lead),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper: detail row with label and value
  Widget _buildDetailRow({
    required String label,
    required String value,
    required Color textColorLight,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColorLight,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: textColorLight,
          ),
        ),
      ],
    );
  }

  // Helper: action button (Edit / Delete)
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: get color for status badge
  Color _getStatusColor(String status) {
    switch (status) {
      case 'New':
        return Colors.green;
      case 'Not-connected':
        return Colors.orange;
      case 'Working':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Edit action
  void _showEditDialog(Lead lead) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Lead'),
        content: Text('Editing lead: ${lead.name}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Edit ${lead.name} clicked')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Delete confirmation
  void _showDeleteConfirmation(Lead lead) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Lead'),
        content: Text('Are you sure you want to delete ${lead.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _allLeads.removeWhere((l) => l.id == lead.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${lead.name} deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Glass card helper (reused)
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
}