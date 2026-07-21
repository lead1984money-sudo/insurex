import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf_read/app_utils/ColorsPicks.dart';
import 'package:pdf_read/app_utils/shared_preferences.dart';
import 'package:pdf_read/app_utils/size/size_config.dart';
import 'package:pdf_read/screen/login/provider/AuthProvider.dart';
import 'package:pdf_read/screen/plan/provider/PlanListProvider.dart';
import 'package:pdf_read/screen/policyHistory/provider/PolicyHistoryProvider.dart';
import 'package:pdf_read/screen/reminder/provider/ReminderProvider.dart';
import 'package:pdf_read/screen/services/provider/ServiceProvider.dart';
import 'package:pdf_read/screen/splash/FirstSplash.dart';
import 'package:pdf_read/screen/transaction/TransactionScreen.dart';
import 'package:pdf_read/screen/transaction/provider/TransactionProvider.dart';
import 'package:pdf_read/screen/uploadpdf/provider/UploadPDFProvider.dart';
import 'package:pdf_read/services/navigator_service.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';
import '../firebase_options.dart';
import '../services/notification_service.dart'; // contains the public handler
import 'aboutus/provider/LegalProvider.dart';
import 'addLead/provider/AddLeadProvider.dart';
import 'bottomnav/BottomNavScreen.dart';
import 'businessDetail/provider/MyBusinessProvider.dart';
import 'checkout/provider/CheckoutProvider.dart';
import 'details/LeadDetailScreen.dart';
import 'document/provider/DocumentProvider.dart';
import 'document/provider/FolderDetailProvider.dart';
import 'earning/provider/AddPartnerProvider.dart';
import 'earning/provider/EarningAddProvider.dart';
import 'earning/provider/EarningProvider.dart';
import 'editProfile/provider/EditProfileProvider.dart';
import 'lead/provider/LeadProvider.dart';
import 'myBusiness/provider/PolicyProvider.dart';
import 'notification/NotificationListScreen.dart';
import 'notification/provider/NotificationProvider.dart';

SpUtil? sp;

Future<void> runReadPDFApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set the public background handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize NotificationService
  await NotificationService().init();

  sp = await SpUtil.getInstance();

  await Future.delayed(
    const Duration(milliseconds: 500),
        () async {
      await initApp();
    },
  );

  runApp(const MyApp());
}

Future<void> initApp() async {
  await SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<UploadPDFProvider>(
          create: (_) => UploadPDFProvider(),
        ),
        ChangeNotifierProvider<PolicyProvider>(
          create: (_) => PolicyProvider(),
        ),
        ChangeNotifierProvider<PlanProvider>(
          create: (_) => PlanProvider(),
        ),
        ChangeNotifierProvider<PaymentProvider>(
          create: (_) => PaymentProvider(),
        ),
        ChangeNotifierProvider<PolicyHistoryProvider>(
          create: (_) => PolicyHistoryProvider(),
        ),
        ChangeNotifierProvider<LeadAddProvider>(
          create: (_) => LeadAddProvider(),
        ),
        ChangeNotifierProvider<MyBusinessProvider>(
          create: (_) => MyBusinessProvider(),
        ),
        ChangeNotifierProvider<ServiceProvider>(
          create: (_) => ServiceProvider(),
        ),
        ChangeNotifierProvider<DocumentProvider>(
          create: (_) => DocumentProvider(),
        ),
        ChangeNotifierProvider<FolderDetailProvider>(
          create: (_) => FolderDetailProvider(),
        ),
        ChangeNotifierProvider<EarningsProvider>(
          create: (_) => EarningsProvider(),
        ),
        ChangeNotifierProvider<EarningAddProvider>(
          create: (_) => EarningAddProvider(),
        ),
        ChangeNotifierProvider<AddPartnerProvider>(
          create: (_) => AddPartnerProvider(),
        ),
        ChangeNotifierProvider<LeadProvider>(
          create: (_) => LeadProvider(),
        ),
        ChangeNotifierProvider<LegalProvider>(
          create: (_) => LegalProvider(),
        ),
        ChangeNotifierProvider<ReminderProvider>(
          create: (_) => ReminderProvider(),
        ),
        ChangeNotifierProvider<TransactionProvider>(
          create: (_) => TransactionProvider(),
        ),

        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(),
        ),

        ChangeNotifierProvider<EditProfileProvider>(
          create: (_) => EditProfileProvider(),
        ),
      ],
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: false,
            brightness: Brightness.light,
            primaryColor: blueColor,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            colorScheme: ColorScheme.fromSeed(
              seedColor: blueColor,
              brightness: Brightness.light,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: blueColor,
                foregroundColor: Colors.white,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: blueColor,
                  width: 1.5,
                ),
              ),
            ),
          ),



          navigatorKey: NavigationService.navigatorKey,
          onGenerateRoute: (settings) {
            // Handle each route with arguments
            print("LINE187");
            print(settings);
            switch (settings.name) {
              case '/plans-manager':
                final args = settings.arguments as Map<String, dynamic>?;
                return MaterialPageRoute(
                  builder: (_) => LeadDetailScreen(arguments: args),
                );
              case '/lead-detail':
                final args = settings.arguments as Map<String, dynamic>?;
                return MaterialPageRoute(
                  builder: (_) => NotificationListScreen(arguments: args),
                );
                case '/transaction-list':
                final args = settings.arguments as Map<String, dynamic>?;
                return MaterialPageRoute (
                  builder: (_) => TransactionScreen(arguments: args),
                );
            // Add more routes as needed
              default:
              // Fallback to home
                return MaterialPageRoute(
                  builder: (_) => const BottomNavScreen(),
                );
            }
          },
          home: UpgradeAlert(
            dialogStyle: Platform.isIOS
                ? UpgradeDialogStyle.cupertino
                : UpgradeDialogStyle.material,
            showLater: true,
            showIgnore: false,
            showReleaseNotes: false,
            child: const FirstSplash(),
          ),
          builder: (context, child) {
            SizeConfig.initialize(
              context: context,
              draftWidth: 375,
              draftHeight: 812,
            );
            return child!;
          },
        ),
      ),
    );
  }
}