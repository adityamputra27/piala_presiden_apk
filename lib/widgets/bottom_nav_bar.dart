import 'package:flutter/material.dart';
import 'package:piala_presiden_apk/constants/font_style.dart';
import 'package:piala_presiden_apk/pages/about_screen.dart';
import 'package:piala_presiden_apk/pages/match_screen.dart';
import 'package:piala_presiden_apk/pages/news_screen.dart';
import 'package:piala_presiden_apk/pages/statistic_screen.dart';
// import '../constants/color.dart';
import '../pages/home_screen.dart';
// import '../pages/schedule_screen.dart';
// import '../pages/stats_screen.dart';
// import '../pages/news_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _navItems = [
    {
      "icon": Icons.home_filled,
      "label": "Beranda",
      "widget": const HomeScreen(),
    },
    {"icon": Icons.event_note, "label": "Jadwal", "widget": MatchScreen()},
    {
      "icon": Icons.stacked_bar_chart,
      "label": "Statistik",
      "widget": StatisticScreen(),
    },
    {"icon": Icons.article, "label": "Berita", "widget": NewsScreen()},
    {"icon": Icons.info, "label": "About", "widget": AboutScreen()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _navItems[_currentIndex]['widget'],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.25),
              blurRadius: 15,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (index) {
            final isSelected = _currentIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = index;
                });
              },
              behavior: HitTestBehavior.translucent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _navItems[index]["icon"],
                    color: isSelected ? Colors.black : Colors.grey[500],
                    size: 26,
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style:
                        isSelected
                            ? AppTextStyle.bottomNavLabel.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            )
                            : AppTextStyle.bottomNavLabel.copyWith(
                              color: Colors.grey[400],
                            ),
                    child: Text(_navItems[index]["label"]),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
