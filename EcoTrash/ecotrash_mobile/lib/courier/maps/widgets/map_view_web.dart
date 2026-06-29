import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';

class CourierMapWidget extends StatefulWidget {
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
  State<CourierMapWidget> createState() => _CourierMapWidgetState();
}

class _CourierMapWidgetState extends State<CourierMapWidget> {
  @override
  Widget build(BuildContext context) {
    final saddr = '${widget.courierLat},${widget.courierLng}';
    final daddr = '${widget.sellerLat},${widget.sellerLng}';
    final embedUrl = 'https://maps.google.com/maps?saddr=$saddr&daddr=$daddr&output=embed&z=14';
    final viewId = 'google-map-$saddr-$daddr-${widget.isInteractive}';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => html.IFrameElement()
        ..src = embedUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.pointerEvents = widget.isInteractive ? 'auto' : 'none',
    );

    return HtmlElementView(viewType: viewId);
  }
}
