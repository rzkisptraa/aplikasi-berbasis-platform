import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import '../providers/courier_order_provider.dart';
import '../../../shared/models/order_model.dart';
import '../../../shared/auth/providers/auth_provider.dart';
import '../../maps/widgets/courier_map_widget.dart';

class CourierActiveJobScreen extends StatefulWidget {
  final int orderId;
  const CourierActiveJobScreen({super.key, required this.orderId});

  @override
  State<CourierActiveJobScreen> createState() => _CourierActiveJobScreenState();
}

class _CourierActiveJobScreenState extends State<CourierActiveJobScreen> {
  Timer? _locationTimer;
  
  double _courierLat = -7.369;
  double _courierLng = 108.534;
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CourierOrderProvider>().fetchMyCourierJobs();
      _startLiveTracking();
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  void _startLiveTracking() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
        Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _courierLat = pos.latitude;
          _courierLng = pos.longitude;
        });
        
        await context.read<CourierOrderProvider>().updateLiveLocation(pos.latitude, pos.longitude);
      }
    } catch (_) {}

    _locationTimer = Timer.periodic(const Duration(seconds: 12), (timer) async {
      try {
        LocationPermission perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
          Position pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          setState(() {
            _courierLat = pos.latitude;
            _courierLng = pos.longitude;
          });
          
          await context.read<CourierOrderProvider>().updateLiveLocation(pos.latitude, pos.longitude);
        }
      } catch (_) {}
    });
  }

  Future<void> _pickup(OrderModel order) async {
    final ImagePicker picker = ImagePicker();
    
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Sumber Foto Sampah',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(context, ImageSource.camera),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.camera_alt_rounded, color: Color(0xFF0F4D19), size: 32),
                            SizedBox(height: 8),
                            Text('Kamera', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(context, ImageSource.gallery),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.photo_library_rounded, color: Color(0xFF0F4D19), size: 32),
                            SizedBox(height: 8),
                            Text('Galeri', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (image == null) return;

    try {
      final provider = context.read<CourierOrderProvider>();
      final bytes = await image.readAsBytes();
      await provider.pickupJob(order.id, bytes, image.name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto penjemputan di-upload! Sampah siap dikirim.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deliver(OrderModel order) async {
    try {
      final provider = context.read<CourierOrderProvider>();
      await provider.deliverJob(order.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sampah terkirim ke gudang! Lakukan penimbangan.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  double _getJobDistance(Map<String, dynamic>? courierProfile, double jobLat, double jobLon) {
    if (courierProfile == null) return 2.5;
    final cLat = double.tryParse(courierProfile['current_latitude']?.toString() ?? '0') ?? 0.0;
    final cLon = double.tryParse(courierProfile['current_longitude']?.toString() ?? '0') ?? 0.0;
    if (cLat == 0.0 || cLon == 0.0) {
      return double.tryParse(((jobLat - 6.2).abs() * 10 + 1.2).toStringAsFixed(1)) ?? 2.5;
    }
    final dist = _calculateDistance(cLat, cLon, jobLat, jobLon);
    return double.tryParse(dist.toStringAsFixed(1)) ?? 2.5;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371; // Earth radius in km
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) * math.cos(_degToRad(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  double _degToRad(double deg) {
    return deg * (math.pi / 180);
  }

  void _completeCheckout(OrderModel order) {
    final Map<int, TextEditingController> textControllers = {};
    for (var item in order.items) {
      textControllers[item.id] = TextEditingController(text: item.estimatedWeight.toString());
    }

    setState(() {
      _isDialogOpen = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            'Konfirmasi Timbangan Gudang',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Masukkan berat timbangan aktual dari gudang untuk menyelesaikan pembayaran.',
                  style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
                ),
                const SizedBox(height: 20),
                ...order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      controller: textControllers[item.id],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: '${item.wasteCategory?.name ?? "Sampah"} (kg)',
                        labelStyle: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
                        suffixIcon: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Text('kg', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF0F4D19), width: 1.5),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _isDialogOpen = false;
                });
                Navigator.pop(context);
              },
              child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F4D19),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(120, 44),
                elevation: 0,
              ),
              onPressed: () async {
                final payload = <Map<String, dynamic>>[];
                bool valid = true;
                
                textControllers.forEach((itemId, controller) {
                  final w = double.tryParse(controller.text) ?? 0.0;
                  if (w <= 0) {
                    valid = false;
                  }
                  payload.add({
                    'order_item_id': itemId,
                    'actual_weight': w,
                  });
                });

                if (!valid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Berat aktual harus berupa angka desimal > 0'), backgroundColor: Colors.orange),
                  );
                  return;
                }

                try {
                  Navigator.pop(context);
                  setState(() {
                    _isDialogOpen = false;
                  });
                  final provider = context.read<CourierOrderProvider>();
                  await provider.completeJob(order.id, payload);
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tugas selesai! Transaksi dompet dikirim ke seller.'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString().replaceAll('Exception:', '').trim()), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Selesaikan Transaksi'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final courierProvider = context.watch<CourierOrderProvider>();
    final authProvider = context.watch<AuthProvider>();
    
    final activeJob = courierProvider.activeJob;
    final user = authProvider.user;
    final courierProfile = user?['courier_profile'];

    if (activeJob == null || activeJob.id != widget.orderId) {
      return Scaffold(
        appBar: AppBar(title: const Text('Alur Tugas')),
        body: const Center(child: Text('Tugas tidak ditemukan atau sudah selesai')),
      );
    }

    final sellerLat = activeJob.latitude;
    final sellerLng = activeJob.longitude;

    // Resolve vehicle details
    final vehicleTypeRaw = activeJob.vehicleType?.toString().toLowerCase() ?? '';
    final isCar = vehicleTypeRaw.contains('mobil') || vehicleTypeRaw.contains('cargo') || vehicleTypeRaw.contains('car') || vehicleTypeRaw.contains('drive');

    // Calculate dynamic distance and mocked duration
    final distance = _getJobDistance(courierProfile, sellerLat, sellerLng);
    final durationMin = (distance * 2 + 5).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text(
          'Alur Tugas ${activeJob.orderCode}',
          style: const TextStyle(
            color: Color(0xFF0F4D19),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F4D19), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 1. Stacked Map Widget with destination overlay and duration pill
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CourierMapWidget(
                    courierLat: _courierLat,
                    courierLng: _courierLng,
                    sellerLat: sellerLat,
                    sellerLng: sellerLng,
                    sellerName: activeJob.seller?.name ?? "Lokasi Penjemputan",
                    isInteractive: !_isDialogOpen,
                  ),
                ),
                // Destination Box Overlay
                Positioned(
                  top: 16,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F5E9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.location_on_outlined, color: Color(0xFF2E7D32), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Destination',
                                style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                activeJob.sellerAddress?.address ?? '-',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Duration & Distance Pill
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCar ? Icons.directions_car : Icons.motorcycle,
                            color: Colors.orange.shade800,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$durationMin min',
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            ' | ${distance.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Action content scrollable view
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card 1: Info Penjual & Alamat & Catatan
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 20,
                              backgroundColor: Color(0xFFE8F5E9),
                              child: Icon(Icons.person_outline_rounded, color: Color(0xFF2E7D32), size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activeJob.seller?.name ?? 'Seller EcoTrash',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1A1A)),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Penjual Sampah',
                                    style: TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(height: 1, color: Colors.grey.shade100),
                        const SizedBox(height: 16),

                        const Text(
                          'Alamat Penjual',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                activeJob.sellerAddress?.address ?? '-',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF424242)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          'Kendaraan',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              isCar ? Icons.local_shipping_outlined : Icons.motorcycle_outlined,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isCar ? 'EcoCargo' : 'EcoRide',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isCar ? Colors.blue.shade700 : Colors.orange.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (activeJob.pickupNotes != null && activeJob.pickupNotes!.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBF7), // Soft orange/yellow background
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Catatan Seller',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  activeJob.pickupNotes!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey.shade700,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Card 2: Daftar Sampah Diminta
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Daftar Sampah Diminta',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A1A1A)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${activeJob.items.length} Items',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...activeJob.items.map((item) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FBFA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Color(0xFF0F4D19), size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item.wasteCategory?.name ?? 'Sampah',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                                  ),
                                ),
                                Text(
                                  '${item.estimatedWeight} kg',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A1A1A)),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 10),
                        Container(height: 1, color: Colors.grey.shade100),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TOTAL MUATAN',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                            ),
                            Text(
                              '${activeJob.estimatedTotalWeight.toInt()} kg',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F4D19)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: _buildActionButton(activeJob),
      ),
    );
  }

  Widget _buildActionButton(OrderModel order) {
    String label = '';
    IconData icon = Icons.camera_alt;
    Color buttonColor = const Color(0xFF0F4D19);
    VoidCallback? action;

    if (order.status == 'ACCEPTED') {
      label = 'Sampai & Ambil Foto Sampah';
      icon = Icons.camera_alt_outlined;
      action = () => _pickup(order);
    } else if (order.status == 'PICKED_UP') {
      label = 'Kirim Sampah Ke Gudang';
      icon = Icons.warehouse_outlined;
      action = () => _deliver(order);
    } else if (order.status == 'DELIVERED') {
      label = 'Konfirmasi Berat & Selesaikan';
      icon = Icons.check_circle_outline_rounded;
      buttonColor = Colors.orange.shade800;
      action = () => _completeCheckout(order);
    } else {
      return const SizedBox();
    }

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      onPressed: action,
    );
  }
}
