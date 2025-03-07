// constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  // Misc
  static const String appName = 'ALIPPE ТАЙМАШ';
  
  // API Endpoints
  static const String baseUrl = 'https://example.com/api';
  static const String loginEndpoint = '/auth/login';
  static const String verifyCodeEndpoint = '/auth/verify';
  static const String registerEndpoint = '/auth/register';
  
  // Assets
  static const String logoPath = 'assets/images/logo.png';
  
  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration animationDuration = Duration(milliseconds: 300);
}

class AppAssets {
  static const String logo = 'assets/images/logo.png';
  static const String background = 'assets/images/background.png';
}