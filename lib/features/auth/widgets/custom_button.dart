import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final WidgetStateProperty<Color?>? overlayColor;
  final Color? textColor;
  final List<BoxShadow>? boxShadow;
  final void Function()? onTap;
  final Widget? prefixIcon;
  final double? heightButton;
  final double? textFontSize;
  final double? radiusBorderCircular;

  const CustomButton({
    super.key,
    required this.text,
    this.boxShadow,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.prefixIcon,
    this.heightButton,
    this.textFontSize,
    this.radiusBorderCircular,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap,
      child: Ink(
        width: size.width,
        height: heightButton ?? 45,
        decoration: BoxDecoration(
          boxShadow: boxShadow,
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          overlayColor:
              overlayColor != null
                  ? WidgetStateProperty.resolveWith<Color?>((
                    Set<WidgetState> states,
                  ) {
                    return states.contains(WidgetState.pressed)
                        ? overlayColor!.resolve(states)
                        : null;
                  })
                  : null,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                prefixIcon ?? Container(),
                prefixIcon != null ? const SizedBox(width: 10) : Container(),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    text,
                    style: TextStyle(
                      letterSpacing: 1.5,
                      color: textColor,
                      fontSize: textFontSize ?? 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
