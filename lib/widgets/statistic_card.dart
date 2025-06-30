import 'package:flutter/material.dart';
import 'package:piala_presiden_apk/constants/color.dart';
import 'package:piala_presiden_apk/constants/font_style.dart';

class StatisticCard extends StatelessWidget {
  final int rank;
  final String name;
  final String teamName;
  final String teamLogo;
  final String photoUrl;
  final String valueLabel;
  final int value;
  final IconData icon;
  final Color? iconColor;
  final bool isMain;

  const StatisticCard({
    super.key,
    required this.rank,
    required this.name,
    required this.teamName,
    required this.teamLogo,
    required this.photoUrl,
    required this.valueLabel,
    required this.value,
    required this.icon,
    this.isMain = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isMain ? Colors.black : Colors.white,
      elevation: 4,
      shadowColor: Colors.black26,
      margin:
          isMain
              ? const EdgeInsets.symmetric(horizontal: 16, vertical: 20)
              : const EdgeInsets.only(bottom: 10, left: 16, right: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding:
            isMain
                ? const EdgeInsets.symmetric(horizontal: 24, vertical: 18)
                : const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isMain ? AppColors.secondary : AppColors.primary,
              radius: isMain ? 28 : 22,
              child: Text(
                "$rank",
                style: AppTextStyle.label.copyWith(
                  color: isMain ? Colors.white : AppColors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: isMain ? 30 : 18,
                ),
              ),
            ),
            const SizedBox(width: 18),
            if (!isMain)
              ClipOval(
                child: Image.network(
                  photoUrl,
                  width: 44,
                  height: 55,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Icon(Icons.person, size: 32),
                ),
              ),
            if (isMain)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyle.label.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.network(teamLogo, width: 20),
                        const SizedBox(width: 6),
                        Text(
                          teamName,
                          style: AppTextStyle.label.copyWith(
                            color: Colors.grey[300],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          icon,
                          color: iconColor != null ? iconColor : Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          "$value $valueLabel",
                          style: AppTextStyle.label.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (isMain) const SizedBox(width: 10),
            if (isMain)
              ClipOval(
                child: Image.network(
                  photoUrl,
                  width: 66,
                  height: 77,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (c, e, s) => const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 54,
                      ),
                ),
              ),
            if (!isMain) const SizedBox(width: 12),
            if (!isMain)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyle.label.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.network(teamLogo, width: 15),
                        const SizedBox(width: 6),
                        Text(
                          teamName,
                          style: AppTextStyle.label.copyWith(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (!isMain)
              Row(
                children: [
                  Icon(
                    icon,
                    color: iconColor != null ? iconColor : AppColors.secondary,
                    size: 18,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    "$value",
                    style: AppTextStyle.label.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
