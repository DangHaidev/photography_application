import 'package:flutter/material.dart';

import '../token/gradient_tokens.dart';

class AppDecoration {
  const AppDecoration._();

  // Basic container decorations
  static BoxDecoration get none => const BoxDecoration();

  static BoxDecoration roundedContainer({
    Color? color,
    double radius = 8.0,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
    Gradient? gradient,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: border,
      boxShadow: boxShadow,
      gradient: gradient,
    );
  }

  // Size-specific decorations
  static BoxDecoration small({
    Color? color,
    Gradient? gradient,
    BoxBorder? border,
  }) {
    return roundedContainer(
      color: color,
      radius: 8.0,
      border: border,
      gradient: gradient,
    );
  }

  static BoxDecoration medium({
    Color? color,
    Gradient? gradient,
    BoxBorder? border,
  }) {
    return roundedContainer(
      color: color,
      radius: 12.0,
      border: border,
      gradient: gradient,
    );
  }

  static BoxDecoration large({
    Color? color,
    Gradient? gradient,
    BoxBorder? border,
  }) {
    return roundedContainer(
      color: color,
      radius: 16.0,
      border: border,
      gradient: gradient,
    );
  }

  // Game-specific decorations
  static BoxDecoration fastPool() {
    return roundedContainer(
      radius: 16.0,
      gradient: AppGradientTokens.fastPoolGradient,
    );
  }

  static BoxDecoration proPool() {
    return roundedContainer(
      radius: 16.0,
      gradient: AppGradientTokens.proPoolGradient,
    );
  }

  static BoxDecoration pickleball() {
    return roundedContainer(
      radius: 16.0,
      gradient: AppGradientTokens.pickleballGradient,
    );
  }

  // Selected/active state decorations
  static ShapeDecoration selectedGradientBorder({
    required Gradient containerGradient,
    double width = 4.0,
    double radius = 16.0,
  }) {
    return ShapeDecoration(
      gradient: containerGradient,
      shape: GradientBorderWithClip(
        gradient: LinearGradient(
          colors: [Color(0xFF00EB85), Color(0xFFCDF503)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        width: width,
        radius: radius,
      ),
    );
  }

  static Decoration dividerDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment(-1.00, -0.00),
        end: Alignment(1, 0),
        colors: [
          Color.from(red: 0.63, green: 0.93, blue: 0.29, alpha: 0),
          Color.from(red: 0.63, green: 0.93, blue: 0.29, alpha: 1),
          Color.from(red: 0.63, green: 0.93, blue: 0.29, alpha: 0),
        ],
      ),
    );
  }

  static BoxDecoration gradientTertiary() {
    return BoxDecoration(
      gradient: AppGradientTokens.gradientTertiary,
      borderRadius: BorderRadius.circular(9),
      border: const Border(
        left: BorderSide(color: Color(0xFF00EB85)),
        top: BorderSide(color: Color(0xFF00EB85)),
        right: BorderSide(color: Color(0xFF00EB85)),
        bottom: BorderSide(width: 2.25, color: Color(0xFF00EB85)),
      ),
    );
  }
}

class GradientBorderWithClip extends ShapeBorder {
  final LinearGradient gradient;
  final double width;
  final double radius;

  const GradientBorderWithClip({
    required this.gradient,
    required this.width,
    required this.radius,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return _getRoundedRectPath(rect.deflate(width), radius - width);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _getRoundedRectPath(rect, radius);
  }

  Path _getRoundedRectPath(Rect rect, double radius) {
    return Path()
      ..addRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final innerRect = rect.deflate(width / 2);
    final paint = Paint()
      ..shader = gradient.createShader(innerRect)
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, Radius.circular(radius)),
      paint,
    );
  }

  @override
  ShapeBorder scale(double t) => this;
}
