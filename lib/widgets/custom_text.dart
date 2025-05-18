import 'package:flutter/material.dart';
import 'package:logistics_demo/theme/spacing.dart';

class CustomText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool isDesktop;
  final FontWeight? fontWeight;
  final Color? color;
  final double? fontSize;

  const CustomText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isDesktop = false,
    this.fontWeight,
    this.color,
    this.fontSize,
  });

  // Predefined styles for common text variants
  static TextStyle get titleStyle => TextStyle(
    fontSize: Spacing.space24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle get subtitleStyle => TextStyle(
    fontSize: Spacing.space18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get bodyStyle => TextStyle(
    fontSize: Spacing.space14,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );

  static TextStyle get captionStyle => TextStyle(
    fontSize: Spacing.space12,
    fontWeight: FontWeight.normal,
    color: Colors.grey,
  );

  static TextStyle get errorStyle => TextStyle(
    fontSize: Spacing.space14,
    fontWeight: FontWeight.w500,
    color: Colors.red,
    letterSpacing: 0.2,
  );

  @override
  Widget build(BuildContext context) {
    // Base style that considers desktop/mobile variations
    final baseStyle = TextStyle(
      fontSize: fontSize ?? (isDesktop ? Spacing.space16 : Spacing.space14),
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? Colors.white,
    );

    // Merge base style with provided style
    final finalStyle = style?.merge(baseStyle) ?? baseStyle;

    return Text(
      text,
      style: finalStyle,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
