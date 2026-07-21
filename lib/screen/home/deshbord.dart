import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf_read/app_utils/ColorsPicks.dart';
import 'package:pdf_read/app_utils/app_images.dart';
import 'package:pdf_read/screen/addLead/AddLeadScreen.dart';
import 'package:pdf_read/screen/earning/EarningScreen.dart';
import 'package:pdf_read/screen/notification/NotificationListScreen.dart';
import 'package:pdf_read/screen/uploadpdf/UploadPDFPage.dart';
import 'package:provider/provider.dart';
import '../contactsupport/ContactSupportScreen.dart';
import '../drawer/SideDrawerScreen.dart';
import '../notification/provider/NotificationProvider.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int notificationCount = 5;

  final List<Map<String, dynamic>> stats = [
    {
      "title": "Total Clients",
      "value": "125",
      "change": "+12 this month",
      "icon": Icons.people,
      "color": Colors.blue,
      "graphColor": Colors.blue,
    },
    {
      "title": "Total Policies",
      "value": "56",
      "change": "+8 this month",
      "icon": Icons.description,
      "color": Colors.green,
      "graphColor": Colors.green,
    },
    {
      "title": "Total Claims",
      "value": "12",
      "change": "2 Pending",
      "icon": Icons.security,
      "color": Colors.orange,
      "graphColor": Colors.orange,
    },
    {
      "title": "Total Premium",
      "value": "₹2.4L",
      "change": "+18% this month",
      "icon": Icons.currency_rupee,
      "color": Colors.amber,
      "graphColor": Colors.amber,
    },
  ];

  final List<Map<String, dynamic>> quickActions = [
    {"title": "Add Lead", "icon": Icons.person_add, "color": Colors.blue},
    {"title": "Upload Policy", "icon": Icons.upload_file, "color": Colors.green},
    {"title": "My Earnings", "icon": Icons.payments, "color": Colors.orange},
    {"title": "Reports", "icon": Icons.insert_chart, "color": Colors.purple},
    {"title": "Help Center", "icon": Icons.help_outline, "color": Colors.red},
  ];

  final List<Map<String, dynamic>> policies = [
    {
      "name": "Health Insurance",
      "id": "L2M001",
      "holder": "Rahul Verma",
      "date": "30 Jun 2026",
      "amount": "₹ 18,500",
      "status": "Active",
    },
    {
      "name": "Motor Insurance",
      "id": "MTRO02",
      "holder": "Amit Singh",
      "date": "25 Jun 2026",
      "amount": "₹ 11,200",
      "status": "Active",
    },
    {
      "name": "Life Insurance",
      "id": "LIF003",
      "holder": "Priya Sharma",
      "date": "20 Jun 2026",
      "amount": "₹ 21,000",
      "status": "Pending",
    },
  ];

  Widget _buildDrawer() {
    return SideDrawerScreen(
      selectedIndex: _selectedIndex,
      onItemTapped: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // ✅ Fetch notifications when dashboard loads – this sets the data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        final shouldExit = await _showExitConfirmationDialog(context);
        if (shouldExit && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: _buildDrawer(),
        backgroundColor: const Color(0xffF5F7FA),
        body: SafeArea (
          child: Column (
            children: [

              _buildTopBar(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: stats.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.1,
                        ),
                        itemBuilder: (context, index) {
                          final stat = stats[index];
                          final Color graphColor = stat['graphColor'] as Color;
                          final Color cardColor = stat['color'] as Color;

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  height: 65,
                                  child: Opacity(
                                    opacity: 0.30,
                                    child: Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()..scale(-1.0, 1.0),
                                      child: ColorFiltered(
                                        colorFilter: ColorFilter.mode(
                                          graphColor,
                                          BlendMode.srcIn,
                                        ),
                                        child: Image.asset(
                                          'assets/images/graph.png',
                                          height: 55,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: cardColor.withOpacity(0.10),
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            child: Icon(
                                              stat['icon'],
                                              color: cardColor,
                                              size: 22,
                                            ),
                                          ),
                                          const Spacer(),
                                          if (stat['change'].toString().contains('+'))
                                            Icon(
                                              Icons.trending_up,
                                              color: cardColor,
                                              size: 18,
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        stat['title'],
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        stat['value'],
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // --- Quick Actions ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Quick Actions",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          // TextButton(
                          //   onPressed: () {},
                          //   child: const Text(
                          //     "View All",
                          //     style: TextStyle(color: blueColor),
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: quickActions.length,
                          itemBuilder: (context, index) {
                            final action = quickActions[index];
                            return InkWell(
                              onTap: () {

                                if(action['title'] == "Add Lead") {

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LeadAddScreen(),
                                    ),
                                  );


                                }else if(action['title'] == "My Earnings") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EarningsScreen(),
                                    ),
                                  );

                                }else if(action['title'] == "Upload Policy") {

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => UploadPolicyScreen(),
                                    ),
                                  );

                                }else if(action['title'] == "Reports") {



                                }else if(action['title'] == "Help Center") {

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ContactSupportScreen(),
                                    ),
                                  );
                                }

                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: 80,
                                margin: const EdgeInsets.only(right: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: (action['color'] as Color).withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        action['icon'],
                                        color: action['color'],
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      action['title'],
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Recent Policies ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Recent Policies",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              "View All",
                              style: TextStyle(color: blueColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...policies.map((policy) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: blueColor.withOpacity(0.12),
                              child: const Icon(
                                Icons.description,
                                color: blueColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    policy['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${policy['id']} • ${policy['holder']}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          size: 12, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        policy['date'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.currency_rupee,
                                          size: 12, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        policy['amount'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: policy['status'] == 'Active'
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                policy['status'],
                                style: TextStyle(
                                  color: policy['status'] == 'Active'
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// --- Extracted top bar for cleaner code ---
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: const Color(0xffF5F7FA), // match background
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.menu, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 12),
          Image.asset(
            AppImages.logo2,
            height: 30,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          // ✅ Use Consumer to listen to unread count from provider
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              final unreadCount = provider.unreadCount;

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationListScreen(),
                    ),
                  );
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.notifications_none,
                        color: Colors.black87,
                      ),
                    ),
                    // Badge
                    if (unreadCount > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),



    );
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}