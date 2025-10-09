import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showCustomModalBottomSheet(
  BuildContext context,
  String title,
  Widget body,
) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
    ),
    isScrollControlled: true,
    constraints: BoxConstraints.tight(
      Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height * .9,
      ),
    ),
    builder: (ctx) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(title, style: GoogleFonts.roboto(fontSize: 20)),
          const SizedBox(height: 18),
          Expanded(child: body),
        ],
      );
    },
  );
}
