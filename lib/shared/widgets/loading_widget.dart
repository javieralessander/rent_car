import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool withText;

  const LoadingWidget({super.key, this.message, this.withText = true});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (withText) ...[
            const SizedBox(height: 16),
            Text(
              message ?? 'Cargando...',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}
