import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home/deshbord.dart';
import '../lead/LeadScreen.dart';
import '../myBusiness/MyBusinessScreen.dart';
import '../services/ServicesDashboardScreen.dart';
import '../uploadpdf/UploadPDFPage.dart';
import '../lead/provider/LeadProvider.dart';  // <-- import your provider



class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen>
    with SingleTickerProviderStateMixin {
  int _bottomNavIndex = 0;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  final iconList = <IconData>[
    Icons.home_rounded,
    Icons.leaderboard,
    Icons.document_scanner,
    Icons.payments_outlined,
  ];

  final pages = [
    const DashboardPage(),
    const LeadPage(),
    const MyBusinessScreen(showBackButton: false,),
    const ServicesDashboardScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  void _onFabTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UploadPolicyScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_bottomNavIndex],
      floatingActionButton: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: FloatingActionButton(
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: _onFabTap,
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        leftCornerRadius: 25,
        rightCornerRadius: 25,
        iconSize: 28,
        activeColor: Colors.blue,
        inactiveColor: Colors.grey,
        splashColor: Colors.blue.withOpacity(0.2),
        backgroundColor: Colors.white,
        elevation: 20,
        onTap: (index) {
          setState(() => _bottomNavIndex = index);

          // 🔁 Refresh Lead data when the Lead tab (index 1) is selected
          if (index == 1) {
            // Make sure LeadProvider is available in the widget tree
            final leadProvider = context.read<LeadProvider>();
            leadProvider.refreshLeads(); // or `init()` if you prefer
          }
        },
      ),
    );
  }
}