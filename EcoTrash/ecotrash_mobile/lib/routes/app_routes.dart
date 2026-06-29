import 'package:flutter/material.dart';

import '../shared/auth/screens/login_screen.dart';
import '../shared/auth/screens/splash_screen.dart';
import '../seller/dashboard/seller_dashboard_screen.dart';
import '../courier/dashboard/screens/courier_dashboard_screen.dart';

class AppRoutes {
  static const String splash =
      '/';

  static const String login =
      '/login';

  static const String sellerHome =
      '/seller-home';

  static const String courierHome =
      '/courier-home';

  static Map<String,
      WidgetBuilder> routes = {
    splash: (context) =>
        const SplashScreen(),

    login: (context) =>
        const LoginScreen(),

    sellerHome: (context) =>
        const SellerDashboardScreen(),

    courierHome: (context) =>
        const CourierDashboardScreen(),
  };
}