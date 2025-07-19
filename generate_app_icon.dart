import 'dart:io';
import 'package:flutter/services.dart';

// This script helps generate app icons
// You'll need to:
// 1. Place your app icon image (1024x1024 PNG) in the project root as 'app_icon.png'
// 2. Run: flutter pub get
// 3. Run: dart generate_app_icon.dart

void main() async {
  print('App Icon Generator for MULI11 Calculator');
  print('========================================');
  print('');
  print('To generate app icons:');
  print('1. Save your app icon image as "app_icon.png" in the project root');
  print('2. Make sure it\'s 1024x1024 pixels or larger');
  print('3. Run: flutter pub get');
  print('4. Run: flutter pub run flutter_launcher_icons:main');
  print('');
  print('Or use the flutter_launcher_icons package:');
  print('1. Add to pubspec.yaml:');
  print('   dev_dependencies:');
  print('     flutter_launcher_icons: ^0.13.1');
  print('');
  print('2. Create flutter_launcher_icons.yaml:');
  print('   flutter_launcher_icons:');
  print('     android: "launcher_icon"');
  print('     ios: true');
  print('     image_path: "assets/app_icon.png"');
  print('     min_sdk_android: 21');
  print('     web:');
  print('       generate: true');
  print('       image_path: "assets/app_icon.png"');
  print('       background_color: "#hexcode"');
  print('       theme_color: "#hexcode"');
  print('     windows:');
  print('       generate: true');
  print('       image_path: "assets/app_icon.png"');
  print('       icon_size: 48');
  print('     macos:');
  print('       generate: true');
  print('       image_path: "assets/app_icon.png"');
  print('');
  print('3. Run: flutter pub run flutter_launcher_icons:main');
}
