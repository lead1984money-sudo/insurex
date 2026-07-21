import 'package:flutter/material.dart';
import 'package:pdf_read/screen/bottomnav/BottomNavScreen.dart';
import 'package:pdf_read/screen/editProfile/EditProfileScreen.dart';
import 'package:pdf_read/screen/home/deshbord.dart';
import 'package:pdf_read/screen/privacypolicy/PrivacyPolicyScreen.dart';
import '../../data/sharedpreferences/PreferenceManager.dart';
import '../aboutus/AboutUsScreen.dart';
import '../contactsupport/ContactSupportScreen.dart';
import '../login/LoginScreen.dart';
import '../term/TermScreen.dart';
import '../transaction/TransactionScreen.dart';


class SideDrawerScreen extends StatefulWidget {
  final int selectedIndex;        // 👈 which item is active (0 = Dashboard)
  final Function(int) onItemTapped; // 👈 callback when an item is tapped

  const SideDrawerScreen({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<SideDrawerScreen> createState() => _SideDrawerScreenState();
}

class _SideDrawerScreenState extends State<SideDrawerScreen> {
  // Navigation helper – closes drawer and calls the callback
  void _navigateTo(int index) {
    // Close the drawer
    Navigator.pop(context);

    // For About Us, navigate directly
     if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) =>  BottomNavScreen()),
      );
    }else if(index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) =>  EditProfileScreen()),
      );
    }else if(index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) =>  TransactionScreen()),
      );
    }else if(index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
      );
    }else if(index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TermScreen()),
      );
    }else if(index == 5) {
      Navigator.push (
        context,
        MaterialPageRoute(builder: (_) => const AboutUsScreen()),
      );
    }else if(index == 6) {



    }else if(index == 7) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ContactSupportScreen()),
      );
    }

    else {
      // For other items, let the parent handle navigation
      widget.onItemTapped(index);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand
              Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: const Color(0xFF4F9CF7),
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'InsureX',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0B1A33),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ---- Menu items ----
              DrawerNavItem(
                icon: Icons.dashboard,
                label: 'Dashboard',
                isActive: widget.selectedIndex == 0,
                onTap: () => _navigateTo(0),
              ),
              DrawerNavItem(
                icon: Icons.people_outline,
                label: 'Profile',
                isActive: widget.selectedIndex == 1,
                onTap: () => _navigateTo(1),
              ),

              DrawerNavItem(
                icon: Icons.receipt_long_outlined,
                label: 'Transactions',
                isActive: widget.selectedIndex == 1,
                onTap: () => _navigateTo(2),
              ),
              DrawerNavItem(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                isActive: widget.selectedIndex == 2,
                onTap: () => _navigateTo(3),
              ),
              DrawerNavItem(
                icon: Icons.description_outlined,
                label: 'Terms & Conditions',
                isActive: widget.selectedIndex == 3,
                onTap: () => _navigateTo(4),
              ),
              DrawerNavItem(
                icon: Icons.info_outline,
                label: 'About Us',
                isActive: widget.selectedIndex == 4,
                onTap: () => _navigateTo(5),
              ),
              DrawerNavItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                isActive: widget.selectedIndex == 5,
                onTap: () => _navigateTo(6),
              ),
              DrawerNavItem(
                icon: Icons.help_outline,
                label: 'Help Center',
                isActive: widget.selectedIndex == 6,
                onTap: () => _navigateTo(7),
              ),

              const Spacer(),

              // Footer – user info and logout
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4F9CF7), Color(0xFF7B61FF)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'RS',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Rahul Sharma',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0B1A33),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Admin',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout_outlined),
                      color: Colors.grey.shade600,
                      iconSize: 20,
                      onPressed: () async {
                        await PreferenceManager.clearLoginData();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                              (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DrawerNavItem – unchanged, but now receives isActive dynamically
// ============================================================
class DrawerNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final bool isActive;
  final VoidCallback? onTap;

  const DrawerNavItem({
    super.key,
    required this.icon,
    required this.label,
    this.badge,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap ?? () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFE3F2FD)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(color: const Color(0xFF4F9CF7).withOpacity(0.3))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive
                    ? const Color(0xFF4F9CF7)
                    : Colors.grey.shade700,
                size: 20,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isActive
                        ? const Color(0xFF0B1A33)
                        : Colors.grey.shade800,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F9CF7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}