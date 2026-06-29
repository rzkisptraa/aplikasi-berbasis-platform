import 'package:flutter/material.dart';

class CourierMapWidget extends StatelessWidget {
  final double courierLat;
  final double courierLng;
  final double sellerLat;
  final double sellerLng;
  final String sellerName;
  final bool isInteractive;

  const CourierMapWidget({
    super.key,
    required this.courierLat,
    required this.courierLng,
    required this.sellerLat,
    required this.sellerLng,
    required this.sellerName,
    this.isInteractive = true,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Platform not supported'));
  }
}
