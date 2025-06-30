import 'package:flutter/material.dart';
import 'package:piala_presiden_apk/constants/font_style.dart';
import 'package:piala_presiden_apk/pages/home_screen.dart';
import 'package:piala_presiden_apk/widgets/ad_info_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/color.dart';

class StepScreen extends StatefulWidget {
  const StepScreen({super.key});

  @override
  State<StepScreen> createState() => _StepScreenState();
}

class _StepScreenState extends State<StepScreen> {
  int currentStep = 0;
  bool finalStep = false;

  final List<Map<String, String>> steps = [
    {
      "image": "assets/images/logo/logo-piala-presiden.jpeg",
      "logo": "assets/images/logo/logo-piala-presiden.jpeg",
      "title": "Selamat Datang di Aplikasi Piala Presiden 2025",
      "subtitle":
          "pertama di indonesia, aplikasi mobile untuk kompetisi pramusim piala presiden tahun 2025",
    },
    {
      "image": "assets/images/splash/2.webp",
      "logo": "assets/images/logo/logo-piala-presiden.jpeg",
      "title": "Jadwal & Klasemen",
      "subtitle":
          "Lihat jadwal, hasil & statistik pertandingan fase grup dan knockout piala presiden 2025",
    },
    {
      "image": "assets/images/splash/3.webp",
      "logo": "assets/images/logo/logo-piala-presiden.jpeg",
      "title": "Update Berita Terkini",
      "subtitle":
          "Ikuti kabar terbaru seputar klub dan pertandingan sepanjang piala presiden 2025",
    },
  ];

  void nextStep() async {
    if (currentStep < steps.length - 1) {
      setState(() {
        currentStep++;
      });
    } else {
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setBool('isOnBoardingLoaded', true);
      setState(() {
        finalStep = true;
      });
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void prevStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  void skipSteps() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void initState() {
    super.initState();
    _showAdInfoIfFirstTime();
  }

  Future<void> _showAdInfoIfFirstTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('isAdInfoDialogShown') ?? false;
    if (!shown) {
      Future.delayed(const Duration(milliseconds: 500), () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => const AdInfoDialog(),
        );
      });
      prefs.setBool('isAdInfoDialogShown', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = steps[currentStep];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(step["image"]!, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 650,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black87],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(step["logo"]!),
                    radius: 30,
                  ),
                  TextButton(
                    onPressed: skipSteps,
                    child: Text(
                      "Lewati",
                      style: AppTextStyle.label.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20,
              ),
              child: Column(
                children: [
                  const Spacer(),
                  Text(
                    step["title"]!,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.heading.copyWith(
                      color: AppColors.primary,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    step["subtitle"]!,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.subHeading.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (currentStep > 0)
                        TextButton(
                          onPressed: prevStep,
                          child: Text(
                            "Sebelumnya",
                            style: AppTextStyle.label.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 100),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: nextStep,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              finalStep
                                  ? Text(
                                    "Loading...",
                                    style: AppTextStyle.label.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  )
                                  : (currentStep < steps.length - 1
                                      ? Text(
                                        "Lanjut",
                                        style: AppTextStyle.label.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      )
                                      : Text(
                                        "Mulai",
                                        style: AppTextStyle.label.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      )),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
