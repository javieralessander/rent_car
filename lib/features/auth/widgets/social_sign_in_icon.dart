import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_theme.dart';
import '../../../core/providers/theme_provider.dart';

class SocialSignInIcon extends StatelessWidget {
  final double? iconsSize;
  final String? googleActionText;
  final void Function() googleOnPressed;
  final String? facebookActionText;
  final void Function() facebookOnPressed;
  final String? appleActionText;
  final void Function() appleOnPressed;

  const SocialSignInIcon({
    super.key,
    this.googleActionText,
    this.facebookActionText,
    this.appleActionText,
    this.iconsSize,
    required this.googleOnPressed,
    required this.facebookOnPressed,
    required this.appleOnPressed,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: IconButton(
            // onPressed: () async {
            // await context.read<SocialSignInService>().signInWithGoogle();
            // },
            onPressed: googleOnPressed,
            icon: Image.asset(
              'assets/images/google_logo.png',
              width: (iconsSize ?? 0) * 0.9,
            ),
          ),
        ),
        Expanded(
          child: IconButton(
            // onPressed: () async {
            // await context.read<SocialSignInService>().signInWithFacebook();
            // },
            onPressed: facebookOnPressed,
            icon: Icon(
              Icons.facebook_outlined,
              color:
                  themeProvider.isDarkMode
                      ? AppColors.facebookLinkWhite
                      : AppColors.facebookLinkBlue,
              size: (iconsSize ?? 0) * 1.1,
            ),
          ),
        ),
        Expanded(
          child: IconButton(
            onPressed: appleOnPressed,
            icon: Icon(
              Icons.apple,
              color:
                  themeProvider.isDarkMode
                      ? AppColors.appleLinkWhite
                      : AppColors.appleLinkBlack,
              size: (iconsSize ?? 0) * 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
