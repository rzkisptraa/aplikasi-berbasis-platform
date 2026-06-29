import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    final markers = {
      Marker(
        markerId: const MarkerId('seller'),
        position: LatLng(widget.sellerLat, widget.sellerLng),
        infoWindow: InfoWindow(title: 'Seller: ${widget.sellerName}'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
      Marker(
        markerId: const MarkerId('courier'),
        position: LatLng(widget.courierLat, widget.courierLng),
        infoWindow: const InfoWindow(title: 'Saya (Kurir)'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    };

    return Stack(
      children: [
        IgnorePointer(
          ignoring: !widget.isInteractive,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.sellerLat, widget.sellerLng),
              zoom: 13,
            ),
            markers: markers,
            onMapCreated: (controller) {
              _mapController = controller;
              controller.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(widget.sellerLat, widget.sellerLng),
                    zoom: 14.5,
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.my_location, color: Colors.green),
              onPressed: () {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngBounds(
                    LatLngBounds(
                      southwest: LatLng(
                        widget.courierLat < widget.sellerLat ? widget.courierLat : widget.sellerLat,
                        widget.courierLng < widget.sellerLng ? widget.courierLng : widget.sellerLng,
                      ),
                      northeast: LatLng(
                        widget.courierLat > widget.sellerLat ? widget.courierLat : widget.sellerLat,
                        widget.courierLng > widget.sellerLng ? widget.courierLng : widget.sellerLng,
                      ),
                    ),
                    60, // Padding
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
