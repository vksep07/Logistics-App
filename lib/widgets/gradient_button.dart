import 'package:flutter/material.dart';
import 'package:logistics_demo/theme/palette.dart';

class GradientButton extends StatelessWidget {
  final bool? isLoading;
  final Function() onPressed;
  final String? label;

  const GradientButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    bool isLoading = this.isLoading ?? false;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Palette.gradient1, Palette.gradient2, Palette.gradient3],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(7),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(395, 55),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child:
            isLoading
                ? const CircularProgressIndicator()
                : Text(
                  label ?? 'Sign in',
                  style: TextStyle(
                    color: Palette.whiteColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                ),
      ),
    );
  }
}
