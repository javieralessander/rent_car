import 'package:flutter/material.dart';
import '../../core/config/app_theme.dart';

dynamic showPermission(
  BuildContext context,
  String message,
  List<Widget>? actions,
) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.warning,
        icon: const Icon(Icons.warning_rounded, size: 45),
        iconPadding: const EdgeInsets.symmetric(vertical: 10),
        iconColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
        // title: const Text(
        //   'Permiso requerido',
        //   textAlign: TextAlign.center,
        // ),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 16),
        content: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(message, textAlign: TextAlign.center),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 5),
        alignment: Alignment.center,
        actionsPadding: const EdgeInsets.symmetric(vertical: 15),
        actionsAlignment: MainAxisAlignment.center,
        actions:
            actions ??
            [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
      );
    },
  );
}
