import 'package:flutter/material.dart';
import 'package:piala_presiden_apk/constants/color.dart';
import 'package:piala_presiden_apk/constants/font_style.dart';

class AdInfoDialog extends StatelessWidget {
  final VoidCallback? onOk;

  const AdInfoDialog({super.key, this.onOk});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: AppColors.secondary,
              size: 48,
            ),
            const SizedBox(height: 18),
            Text(
              "Piala Presiden App 2025",
              style: AppTextStyle.label.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Aplikasi ini gratis untuk digunakan dan didukung oleh iklan.\nTerima kasih sudah mendukung kami!",
              style: AppTextStyle.body.copyWith(
                color: AppColors.mutedText,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (onOk != null) onOk!();
                },
                child: Text(
                  "Oke, mengerti",
                  style: AppTextStyle.label.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
