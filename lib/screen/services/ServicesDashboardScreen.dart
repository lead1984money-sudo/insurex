import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pdf_read/screen/document/DocumentsScreen.dart';
import 'package:pdf_read/screen/plan/SubscriptionScreen.dart';
import 'package:pdf_read/screen/services/provider/ServiceProvider.dart';
import 'package:provider/provider.dart';
import 'package:pdf_read/app_utils/ColorsPicks.dart';
import 'package:pdf_read/app_utils/app_images.dart';
import '../earning/EarningScreen.dart';
import '../lead/LeadScreen.dart';
import '../myBusiness/MyBusinessScreen.dart';
import '../reminder/ReminderDashboard.dart';


class ServicesDashboardScreen extends StatefulWidget {
  const ServicesDashboardScreen({super.key});

  @override
  State<ServicesDashboardScreen> createState() =>
      _ServicesDashboardScreenState();
}

class _ServicesDashboardScreenState extends State<ServicesDashboardScreen> {


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().fetchAppMenu();
    });
  }

  @override
  Widget build(BuildContext context) {
    final overlayColor = white.withOpacity(0.3);
    final headingColor = black;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.transparent),
          color: headingColor,
        ),
        title: const Text(
          'Services',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B1A33),
          ),
        ),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: headingColor,
        ),
      ),
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
                child: Consumer<ServiceProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    // FIXED ERROR CHECK
                    if (provider.errorMessage.isNotEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              provider.errorMessage,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 15),
                            ElevatedButton(
                              onPressed: () {
                                provider.fetchAppMenu();
                              },
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      );
                    }

                    if (provider.menuItems.isEmpty) {
                      return const Center(
                        child: Text(
                          "No Services Available",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }


                    return GridView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: provider.menuItems.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 5,                      // reduced spacing
                        mainAxisSpacing: 5,                       // reduced spacing
                        childAspectRatio: 1.0,                     // square cards (was 0.85)
                      ),
                      itemBuilder: (context, index) {
                        final item = provider.menuItems[index];

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              if(item["name"] == "My Docs"){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>  DocumentsScreen(),
                                  ),
                                );
                              }else if(item["name"] == "Earning's") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EarningsScreen(),
                                  ),
                                );
                              } else if(item["name"] == "Plan's"){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>  SubscriptionScreen(),
                                  ),
                                );
                              }else if(item["name"] == "Manage Lead's"){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>  LeadPage(),
                                  ),
                                );
                              }else if(item["name"] == "Policy's"){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>  MyBusinessScreen(showBackButton: true,),
                                  ),
                                );
                              }else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>  ReminderDashboard(),
                                  ),
                                );

                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (item["appIcon"] != null &&
                                      item["appIcon"]
                                          .toString()
                                          .isNotEmpty)
                                    Image.network(
                                      item["appIcon"],
                                      width: 50,
                                      height: 50,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.apps,
                                          size: 50,
                                        );
                                      },
                                    )
                                  else
                                    const Icon(
                                      Icons.apps,
                                      size: 50,
                                    ),

                                  Text(
                                    item["name"] ?? "",
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),

                                  Text(
                                    item["appName"] ?? "",
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
            ),
          ],
        ),
      ),
    );
  }

}