import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:piala_presiden_apk/firebase_options.dart';
import 'package:piala_presiden_apk/pages/splash_screen.dart';
import 'package:piala_presiden_apk/pages/step_screen.dart';
import 'package:piala_presiden_apk/provider/notification_provider.dart';
import 'package:piala_presiden_apk/services/firebase_notification_service.dart';
import 'package:piala_presiden_apk/widgets/bottom_nav_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'utils/global_navigator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.subscribeToTopic('match');
  await FirebaseMessaging.instance.subscribeToTopic('news');
  await FirebaseMessaging.instance.subscribeToTopic('standings');
  await FirebaseMessaging.instance.subscribeToTopic('statistic');
  await FirebaseMessaging.instance.subscribeToTopic('information');

  MobileAds.instance.initialize();

  await Supabase.initialize(
    url: 'https://uqxrvzvbckrgtqlclfxs.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVxeHJ2enZiY2tyZ3RxbGNsZnhzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAwMDg2MjMsImV4cCI6MjA2NTU4NDYyM30.vqIPlEQtGmyk4EqD6yLbpk7yea1xzWStrqhPBHdSx4A',
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => NotificationProvider()..fetchNotif(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  Future<void> requestPermission() async {
    FirebaseNotificationService().requestNotificationPermission((isGranted) {
      if (kDebugMode) {
        print('success');
      }
    });

    FirebaseNotificationService().firebaseInit(context);
    FirebaseNotificationService().isTokenRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      title: 'Piala Presiden 2025',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const StepScreen(),
        '/home': (context) => const BottomNavBar(),
      },
    );
  }
}
