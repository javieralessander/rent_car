import 'package:flutter/material.dart';

import '../../../core/config/app_theme.dart';

class SocialSignIn extends StatelessWidget {
  final String googleActionText;
  final String facebookActionText;
  final String appleActionText;
  const SocialSignIn({
    super.key,
    required this.googleActionText,
    required this.facebookActionText,
    required this.appleActionText,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(height: size.height * 0.005),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.facebookLinkBlue,
                  foregroundColor: AppColors.facebookLinkWhite,
                ),
                onPressed: () {},
                label: Text(
                  'Facebook',
                  style: TextStyle(
                    color: AppColors.facebookLinkWhite,
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                icon: Icon(
                  Icons.facebook_rounded,
                  size: size.width * 0.05,
                  color: AppColors.facebookLinkWhite,
                ),
              ),
            ),
            SizedBox(width: size.height * 0.010),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.facebookLinkBlue,
                ),
                onPressed: () {},
                label: Text(
                  'Google',
                  style: TextStyle(
                    color: AppColors.facebookLinkBlue,
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                icon: Image.asset(
                  'assets/images/google_logo.png',
                  width: size.width * 0.04,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.010),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.appleLinkBlack,
                  foregroundColor: AppColors.white,
                ),
                onPressed: () {},
                label: Text(
                  'Apple',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                icon: Icon(Icons.apple, size: size.width * 0.060),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
