import 'package:flutter/material.dart';
import 'package:logistics_demo/theme/palette.dart';
import 'package:logistics_demo/theme/spacing.dart';

class LoginField extends StatelessWidget {
  final String hintText;
  const LoginField({super.key, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: TextFormField(
        style: const TextStyle(
          color: Palette.whiteColor,
          fontSize: Spacing.space14,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(Spacing.space20),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Palette.borderColor,
              width: Spacing.space2,
            ),
            borderRadius: BorderRadius.circular(Spacing.space10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Palette.gradient2,
              width: Spacing.space2,
            ),
            borderRadius: BorderRadius.circular(Spacing.space10),
          ),
          hintText: hintText,
        ),
      ),
    );
  }
}
