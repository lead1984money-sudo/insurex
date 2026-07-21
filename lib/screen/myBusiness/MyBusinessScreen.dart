import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pdf_read/screen/businessDetail/MyBusinessDetails.dart';
import 'package:provider/provider.dart';
import '../../app_utils/ColorsPicks.dart';
import '../../app_utils/app_images.dart';
import '../pdfviewer/PdfViewerScreen.dart';
import '../policyHistory/PolicyHistoryScreen.dart';
import 'model/policy_model.dart';
import 'provider/PolicyProvider.dart'; // your existing provider

class MyBusinessScreen extends StatefulWidget {
  final bool showBackButton;
  const MyBusinessScreen({super.key, this.showBackButton = false});

  @override
  State<MyBusinessScreen> createState() => _MyBusinessScreenState();
}

class _MyBusinessScreenState extends State<MyBusinessScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'all'; // 'all' or 'renewed'




  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PolicyProvider>().fetchPolicies();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      context.read<PolicyProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overlayColor = Colors.white.withOpacity(0.3);
    final headingColor = black; // from ColorsPicks

    return PopScope(
      canPop: false, // Prevent default pop
      onPopInvoked: (bool didPop) async {
        // This is called after the back button is pressed.
        // If the pop was NOT handled (didPop == false), we navigate manually.
        if (!didPop) {
          // Navigate to BottomNavScreen (replace current route)
          // Use pushReplacement so the user can't go back to this screen.
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (_) => const BottomNavScreen()),
          // );
        }
      },

      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: widget.showBackButton
              ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1A33)),
            onPressed: () => Navigator.pop(context),
          )
              : null,
          title: const Text(
            'Policy List',
            style: TextStyle(
              color: Color(0xFF0B1A33),
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.history, color: Color(0xFF0B1A33)),
              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PolicyHistoryScreen(),
                  ),
                );

              },
              tooltip: 'History',
            ),
          ],
        ),
        body: Container(
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
                child: Consumer<PolicyProvider>(
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

                    // Filter the list client‑side if needed (e.g., 'renewed')
                    final displayedPolicies = _selectedFilter == 'all'
                        ? provider.policies
                        : provider.policies
                      //  .where((p) => p.status == 'renewed') // adjust field as needed
                        .toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        // ─── Filter Tabs ──────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              _buildFilterTab('ALL', 'all'),
                              const SizedBox(width: 8),
                              _buildFilterTab('Renewed', 'renewed'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ─── Count ─────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedFilter == 'all'
                                    ? 'All Policies'
                                    : 'Renewed Policies',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: headingColor,
                                ),
                              ),
                              Text(
                                '${displayedPolicies.length} policies',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // ─── List ──────────────────────────────────
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: displayedPolicies.length +
                                (provider.hasMore && displayedPolicies.isNotEmpty
                                    ? 1
                                    : 0),
                            itemBuilder: (context, index) {
                              if (index == displayedPolicies.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                              final policy = displayedPolicies[index];
                              return _PolicyCard(policy: policy);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
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
          // If you want to fetch fresh data from API with filter, call provider here
          // context.read<PolicyProvider>().fetchPolicies(refresh: true, filter: value);
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

// ─── Policy Card (with glass‑style upgrade) ──────────────────────

class _PolicyCard extends StatelessWidget {
  final PolicyData policy;
  const _PolicyCard({required this.policy});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final int srMasterId = int.tryParse(policy.id) ?? 0;
        Navigator.push(
          context,
          MaterialPageRoute (
            builder: (_) =>  MyBusinessDetails(srMasterId: srMasterId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Proposer Name + Status Chip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          policy.proposerName ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B1A33),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildStatusChip(policy.endDate),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Info rows
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
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _actionButton(
                        icon: Icons.visibility_outlined,
                        label: 'View',
                        onTap: () => _handleFileAction(context, policy.fileName!, 'view'),
                      ),
                      const SizedBox(width: 12),
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
        ),
      ),
    );
  }




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

  // ─── Info tile (label + value) ─────────────────────────────────
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
            color: Color(0xFF0B1A33),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ─── Action button (View / Download) ───────────────────────────
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