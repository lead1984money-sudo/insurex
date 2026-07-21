import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf_read/screen/lead/model/lead_model.dart';
import 'package:pdf_read/screen/lead/provider/LeadProvider.dart';
import 'package:pdf_read/screen/addLead/AddLeadScreen.dart';
import 'package:pdf_read/screen/bottomnav/BottomNavScreen.dart';
import 'EditLeadPopup.dart';
import 'LeadViewPopup.dart';




class LeadPage extends StatefulWidget {
  const LeadPage({super.key});

  @override
  State<LeadPage> createState() => _LeadPageState();
}

class _LeadPageState extends State<LeadPage> {
  final ScrollController _scrollController = ScrollController();
  int _selectedTabIndex = 0;
  final FocusNode _searchFocusNode = FocusNode();
 // bool _isSearchFocused = false;


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // _searchFocusNode.addListener(() {
    //   setState(() {
    //     _isSearchFocused = _searchFocusNode.hasFocus;
    //   });
    // });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      context.read<LeadProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (!didPop) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BottomNavScreen()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF7F9FD),
        body: SafeArea(
          child: Consumer<LeadProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.error.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        provider.error,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => provider.init(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              // Prepare stats data – map from provider
              final stats = [
                {
                  'title': 'All Leads',
                  'count': provider.totalLeads,
                  'growth': '+12 this month', // replace with real data if available
                  'color': Colors.blue,
                  'icon': Icons.groups_rounded,
                },
                {
                  'title': 'New',
                  'count': provider.pending,
                  'growth': '+8 this month',
                  'color': Colors.lightBlue,
                  'icon': Icons.circle,
                },
                {
                  'title': 'In Progress',
                  'count': provider.totalFollowup,
                  'growth': '+6 this month',
                  'color': Colors.orange,
                  'icon': Icons.circle,
                },
                {
                  'title': 'Converted',
                  'count': 0, // replace with actual converted count if available
                  'growth': '+5 this month',
                  'color': Colors.green,
                  'icon': Icons.circle,
                },
              ];

              // Build status tabs from provider's statusOptions
              List<String> statusTabs = [
                'All Leads',
                ...provider.statusOptions.where((s) => s != 'All Status')
              ];
              if (statusTabs.isEmpty) statusTabs = ['All Leads'];

              // Sync tab index with provider's current filter
              if (_selectedTabIndex > 0 &&
                  _selectedTabIndex < statusTabs.length) {
                final currentFilter = provider.currentStatusFilter;
                if (currentFilter != 'All Status' &&
                    statusTabs[_selectedTabIndex] != currentFilter) {
                  // If filter changed externally, reset index to 0 (All Leads)
                  _selectedTabIndex = 0;
                }
              }

              return Column(
                children: [
                  // ---- Header ----
                  _buildHeader(context, provider),
                  const SizedBox(height: 16),
                  // ---- Search Bar ----
                  _buildSearchBar(context),
                  const SizedBox(height: 16),
                  // ---- Stats Row ----
                  _buildStatsRow(stats),
                  const SizedBox(height: 20),
                  // ---- Status Tabs ----
                  _buildStatusTabs(statusTabs, provider),
                  const SizedBox(height: 16),
                  // ---- Type Filter Dropdown ----
                 // _buildTypeFilter(provider),
                  const SizedBox(height: 12),
                  // ---- Leads List ----
                  Expanded(
                    child: provider.leads.isEmpty
                        ? const Center(
                      child: Text(
                        'No leads found',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                        : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.leads.length +
                          (provider.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == provider.leads.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: provider.isLoadingMore
                                  ? const CircularProgressIndicator()
                                  : const SizedBox.shrink(),
                            ),
                          );
                        }
                        final lead = provider.leads[index];
                        return _buildLeadCard(lead, context);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ---- Header ----
  Widget _buildHeader(BuildContext context, LeadProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Menu icon – opens drawer
          // Builder(
          //   builder: (context) => Container(
          //     height: 58,
          //     width: 58,
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.circular(18),
          //     ),
          //     child: IconButton(
          //       icon: const Icon(Icons.menu),
          //       onPressed: () => Scaffold.of(context).openDrawer(),
          //     ),
          //   ),
          // ),

          Expanded(
            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,
              children:  [
                Text(
                  'Leads',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),
          ),
          // Filter icon – opens type filter popup (alternative to dropdown)
          GestureDetector(
            onTap: () => _showTypeFilterDialog(context, provider),
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.filter_alt_outlined),
            ),
          ),
          const SizedBox(width: 12),
          // Add button – gradient
          GestureDetector (
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LeadAddScreen()),
              );
            },
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xff4B8DFF), Color(0xff1565FF)],
                ),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Search Bar ----
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 30,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(-5, -5),
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) {
            context.read<LeadProvider>().updateSearch(value);
          },
          decoration: InputDecoration(
            hintText: "Search leads by name, mobile or source...",
            hintStyle: TextStyle (
              color: Colors.grey.shade500,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                Icons.search_rounded,
                color: Colors.grey.shade500,
                size: 26,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 55,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 20,
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ---- Stats Row ----
  Widget _buildStatsRow(List<Map<String, dynamic>> stats) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final item = stats[index];
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 15),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.04),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: item['color'] as Color,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item['title'] as String,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  item['count'].toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Text(
                //   item['growth'] as String,
                //   style: TextStyle(
                //     color: item['color'] as Color,
                //     fontWeight: FontWeight.w600,
                //   ),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---- Status Tabs ----
  Widget _buildStatusTabs(List<String> tabs, LeadProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 45,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: tabs.length,
          itemBuilder: (_, index) {
            final isSelected = _selectedTabIndex == index;
            final tabName = tabs[index];

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
                // Update status filter
                if (index == 0) {
                  provider.updateStatusFilter('All Status');
                } else {
                  provider.updateStatusFilter(tabName);
                }
              },
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  toTitleCase(tabName),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ---- Type Filter Dropdown ----
  Widget _buildTypeFilter(LeadProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Text(
            'Type:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              value: provider.currentTypeFilter,
              items: provider.typeOptions.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                if (value != null) provider.updateTypeFilter(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  String toTitleCase(String text) {
    return text
        .split(' ')
        .map((word) => word.isNotEmpty
        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
        : '')
        .join(' ');
  }

  // ---- Popup for type filter (filter icon in header) ----
  void _showTypeFilterDialog(BuildContext context, LeadProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filter by Type',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...provider.typeOptions.map((type) {
                return ListTile(
                  title: Text(type),
                  trailing: provider.currentTypeFilter == type
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    provider.updateTypeFilter(type);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // ---- Lead Card ----
  Widget _buildLeadCard(Lead lead, BuildContext context) {
    final bool isComplete = lead.status.toLowerCase() == 'complete';
    final Color statusColor = _getStatusColor(lead.status);
    final String initials = _getInitials(lead.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 15,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: statusColor.withOpacity(.12),
            child: Text(
              initials,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 15),

          // Lead info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        lead.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        lead.status,
                        style: TextStyle(color: statusColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  lead.mobile,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  lead.type,
                  style: const TextStyle(color: Colors.blue, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Source: ${lead.source.isNotEmpty ? lead.source : "N/A"}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),

          // Time and actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _timeAgo(lead.createdAt),
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // View
                  IconButton(
                    onPressed: () async {
                      final provider = Provider.of<LeadProvider>(context, listen: false);
                      final detail = await provider.fetchLeadDetail(lead.id);
                      if (detail != null) {
                        showDialog(
                          context: context,
                          builder: (_) => LeadViewPopup(
                            lead: lead,
                            detail: detail,
                            statuses: provider.leadStatuses,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(provider.error)),
                        );
                      }
                    },
                    icon: const Icon(Icons.visibility, color: Colors.blue),
                    splashRadius: 20,
                    constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                  ),
                  const SizedBox(width: 4),
                  // Edit (only if not complete)
                  if (!isComplete)
                    IconButton(
                      onPressed: () async {
                        final provider = Provider.of<LeadProvider>(context, listen: false);
                        final detail = await provider.fetchLeadDetail(lead.id);
                        if (detail != null) {

                          print("LINE668");
                          print(lead.reference);
                          showDialog(
                            context: context,
                            builder: (_) => EditLeadPopup(
                              lead: lead,
                              detail: detail,
                              statuses: provider.leadStatuses,
                              leadReferences: provider.leadReferences,
                              lobs: provider.lobs,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(provider.error)),
                          );
                        }
                      },
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      splashRadius: 20,
                      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                    ),
                  const SizedBox(width: 4),
                  // Delete
                  IconButton(
                    onPressed: () => _showDeleteConfirmation(context, lead),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    splashRadius: 20,
                    constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---- Delete Confirmation ----
  void _showDeleteConfirmation(BuildContext context, Lead lead) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Lead'),
        content: Text('Are you sure you want to delete "${lead.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<LeadProvider>();
              final success = await provider.deleteLead(lead.id);
              if (success) {
                await provider.refreshLeads();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lead deleted successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete: ${provider.error}')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ---- Helpers ----
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _timeAgo(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (_) {
      return dateTimeStr;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'follow-up':
        return Colors.teal;
      case 'lost':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'complete':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}