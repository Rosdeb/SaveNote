import 'package:flutter/material.dart';

/// Spacing tokens — Responsive.Mode 1.tokens.json > Padding থেকে।
///
/// Example:
/// ```dart
/// Padding(
///   padding: EdgeInsets.all(AppSpacing.s16),
///   child: ...,
/// )
///
/// SizedBox(height: AppSpacing.s24)
/// ```
class AppSpacing {
  AppSpacing._();

  static const double s0 = 0;
  static const double s1 = 1;
  static const double s2 = 2;
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s28 = 28;
  static const double s32 = 32;
  static const double s36 = 36;
  static const double s40 = 40;
  static const double s48 = 48;
  static const double s56 = 56;
  static const double s64 = 64;
  static const double s96 = 96;
  static const double s120 = 120;
  static const double s200 = 200;
  static const double s250 = 250;

  // Semantic shortcuts
  static const double xs = s4;
  static const double sm = s8;
  static const double md = s16;
  static const double lg = s24;
  static const double xl = s32;
  static const double xxl = s48;
}

/// Border radius tokens — Responsive.Mode 1.tokens.json > Corner থেকে।
///
/// Example:
/// ```dart
/// Container(
///   decoration: BoxDecoration(
///     borderRadius: BorderRadius.circular(AppBorderRadius.r8),
///   ),
/// )
/// ```
class AppBorderRadius {
  AppBorderRadius._();

  static const double r0 = 0;
  static const double r2 = 2;
  static const double r4 = 4;
  static const double r8 = 8;
  static const double r12 = 12;
  static const double r16 = 16;
  static const double r20 = 20;
  static const double r24 = 24;
  static const double rFull = 200; // pill shape

  // BorderRadius helpers
  static BorderRadius circular(double r) => BorderRadius.circular(r);

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(r12));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(r8));
  static const BorderRadius chipRadius = BorderRadius.all(Radius.circular(rFull));
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(r8));
  static const BorderRadius sheetRadius = BorderRadius.vertical(top: Radius.circular(r24));
}

/// Border width tokens — Responsive.Mode 1.tokens.json > Border থেকে।
class AppBorderWidth {
  AppBorderWidth._();

  static const double w0 = 0;
  static const double w05 = 0.5;
  static const double w1 = 1;
  static const double w15 = 1.5;
  static const double w2 = 2;
  static const double w4 = 4;
  static const double w8 = 8;
}

/// Icon size tokens — Responsive.Mode 1.tokens.json > Icon থেকে।
class AppIconSize {
  AppIconSize._();

  static const double sm = 16;
  static const double normal = 24;
}