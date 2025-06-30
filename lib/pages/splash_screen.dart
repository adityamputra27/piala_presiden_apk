import 'dart:async';
import 'package:flutter/material.dart';
import 'package:piala_presiden_apk/constants/font_style.dart';
import 'package:piala_presiden_apk/pages/home_screen.dart';
import 'package:piala_presiden_apk/pages/step_screen.dart';
import 'package:piala_presiden_apk/services/firebase_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/color.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    animationLoaded();
    redirectToMainPage();
  }

  void animationLoaded() async {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  Future<void> redirectToMainPage() async {
    FirebaseNotificationService().requestNotificationPermission((isGranted) {
      Timer(const Duration(seconds: 3), () async {
        final SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();

        final isOnBoardingLoaded =
            sharedPreferences.getBool('isOnBoardingLoaded') ?? false;

        if (isOnBoardingLoaded) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
      });
    });
    FirebaseNotificationService().firebaseInit(context);
    FirebaseNotificationService().isTokenRefresh();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: ScaleTransition(
            scale: _animation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.grey.withOpacity(0.5),
                    //     blurRadius: 15,
                    //     offset: const Offset(0, 2),
                    //   ),
                    // ],
                  ),
                  padding: const EdgeInsets.all(10),
                  child: ClipOval(
                    child: Image.asset(
                      "assets/images/logo/logo-piala-presiden.jpeg",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Column(
                  children: [
                    Text(
                      'Piala Presiden 2025 App',
                      style: AppTextStyle.label2.copyWith(
                        fontSize: 20,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Jadwal & Klasemen',
                      style: AppTextStyle.label.copyWith(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 120),
                Column(
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'Apk Version: v1.0.0',
                      style: AppTextStyle.label.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
