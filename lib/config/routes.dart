import 'package:flutter/material.dart';
import 'package:unzip/features/home/screens/home_screen.dart';
import 'package:unzip/features/json_tools/screens/zipper_screen.dart';
import 'package:unzip/features/json_tools/screens/unzipper_screen.dart';
import 'package:unzip/features/text_tools/screens/text_formatter_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String zipper = '/json-tools/zipper';
  static const String unzipper = '/json-tools/unzipper';
  static const String textFormatter = '/text-tools/formatter';

  static Map<String, WidgetBuilder> get routes => {
    home: (context) => const HomeScreen(),
    zipper: (context) => const ZipperScreen(),
    unzipper: (context) => const UnzipperScreen(),
    textFormatter: (context) => const TextFormatterScreen(),
  };
}