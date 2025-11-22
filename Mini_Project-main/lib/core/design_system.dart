import 'package:flutter/material.dart';

class AppSpacing {
  static const double xs = 6;
  static const double sm = 12;
  static const double md = 18;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  static const BorderRadius sm = BorderRadius.all(Radius.circular(12));
  static const BorderRadius md = BorderRadius.all(Radius.circular(18));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(24));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(40));
}

class AppDurations {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration regular = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 550);
}

class AppBlur {
  static const double light = 8;
  static const double medium = 16;
  static const double heavy = 24;
}

class AppInsets {
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: 20, vertical: 12);
  static const EdgeInsets card = EdgeInsets.symmetric(horizontal: 20, vertical: 18);
  static const EdgeInsets field = EdgeInsets.symmetric(horizontal: 20, vertical: 16);
}

class AppBreakpoints {
  static const double phone = 600;
  static const double tablet = 1024;
}
