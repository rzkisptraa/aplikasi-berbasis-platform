import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'seller/addresses/providers/seller_address_provider.dart';
import 'seller/orders/providers/seller_order_provider.dart';
import 'seller/wallet/providers/seller_wallet_provider.dart';
import 'seller/notifications/providers/seller_notification_provider.dart';
import 'courier/orders/providers/courier_order_provider.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'shared/auth/providers/auth_provider.dart';
import 'shared/providers/app_state_provider.dart';

class EcoTrashApp extends StatelessWidget {
  const EcoTrashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SellerAddressProvider()),
        ChangeNotifierProvider(create: (_) => SellerOrderProvider()),
        ChangeNotifierProvider(create: (_) => SellerWalletProvider()),
        ChangeNotifierProvider(create: (_) => SellerNotificationProvider()),
        ChangeNotifierProvider(create: (_) => CourierOrderProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EcoTrash',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}
