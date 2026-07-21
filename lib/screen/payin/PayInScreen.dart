import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf_read/app_utils/app_images.dart';
import 'package:pdf_read/screen/payAdd/PayAddScreen.dart';
import '../../app_utils/ColorsPicks.dart';
import '../../app_utils/app_strings.dart';
import '../bottomnav/BottomNavScreen.dart';



class PayInScreen extends StatefulWidget {
  const PayInScreen({super.key});

  @override
  State<PayInScreen> createState() => _PayInScreenState();
}

class _PayInScreenState extends State<PayInScreen> {
  final List<Map<String, dynamic>> stats = [
    {
      "title": "Received Income",
      "value": "₹ 1,25,000",
      "icon": Icons.people,
    },
    {
      "title": "Pending Income",
      "value": "₹ 32,500",
      "icon": Icons.description,
    },
    {
      "title": "Total Income",
      "value": "₹ 1,57,500",
      "icon": Icons.wallet,
    },
    {
      "title": "Total Cash Back",
      "value": "₹ 18,750",
      "icon": Icons.card_giftcard,
    },

    {
      "title": "Total Earning",
      "value": "₹ 1,38,750",
      "icon": Icons.bar_chart_rounded,
    },


    {
      "title": "Total Policy Success",
      "value": "128",
      "icon": Icons.security_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final textColorLight = textColor;
    final headingColor = black;
    final cardBgColor = white.withOpacity(0.25);
    final cardBorderColor = white.withOpacity(0.4);

    return PopScope(
      canPop: false, // Prevent default pop
      onPopInvoked: (bool didPop) async {
        if (!didPop) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BottomNavScreen()),
          );
        }
      },
      child: Scaffold(
        extendBody: true,
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration:  BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppImages.background),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack (
            children: [
              SafeArea (
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column (
                    children: [
                      Row (
                        children: [
                          Text (
                            AppStrings.appTitle,
                            style: const TextStyle(
                              fontSize: 28,
                              color: blueColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>  PayAddScreen(),
                                ),
                              );
                            },
                            child: glassCard(
                              bgColor: cardBgColor,
                              borderColor: cardBorderColor,
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(
                                  Icons.add,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),


                      // Stats Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: stats.length,
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 15,
                          crossAxisSpacing: 15,
                          childAspectRatio: 1.2,
                        ),
                        itemBuilder: (context, i) {
                          return TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 400 + (i * 150)),
                            tween: Tween(begin: 30, end: 0),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, value),
                                child: child,
                              );
                            },
                            child: glassCard(
                              bgColor: cardBgColor,
                              borderColor: cardBorderColor,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    stats[i]['icon'],
                                    size: 30,
                                    color: blueColor,
                                  ),
                                  const Spacer(),
                                  Text(
                                    stats[i]['value'],
                                    style:  TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: headingColor,
                                    ),
                                  ),
                                  Text(
                                    stats[i]['title'],
                                    style: TextStyle(
                                      color: textColorLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 15),

                      // Policy List

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



  // Glass card with fixed colours
  Widget glassCard({
    required Widget child,
    Color? bgColor,
    Color? borderColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
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
