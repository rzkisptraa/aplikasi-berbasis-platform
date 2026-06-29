import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../orders/providers/courier_order_provider.dart';
import '../../orders/screens/courier_active_job_screen.dart';
import '../../../shared/auth/providers/auth_provider.dart';
import '../../../core/network/dio_client.dart';

class CourierHomeScreen extends StatefulWidget {
  const CourierHomeScreen({super.key});

  @override
  State<CourierHomeScreen> createState() => _CourierHomeScreenState();
}

class _CourierHomeScreenState extends State<CourierHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AuthProvider>().fetchProfile();
      context.read<CourierOrderProvider>().fetchMyCourierJobs();
      context.read<CourierOrderProvider>().fetchAvailableJobs();
      context.read<CourierOrderProvider>().fetchReviews();
      context.read<CourierOrderProvider>().fetchNotifications();
    });
  }

  Future<void> _refresh() async {
    await context.read<AuthProvider>().fetchProfile();
    await context.read<CourierOrderProvider>().fetchMyCourierJobs();
    await context.read<CourierOrderProvider>().fetchAvailableJobs();
    await context.read<CourierOrderProvider>().fetchReviews();
    await context.read<CourierOrderProvider>().fetchNotifications();
  }

  Future<void> _toggleOnline(bool val) async {
    try {
      final provider = context.read<CourierOrderProvider>();
      await provider.toggleOnlineStatus();
      if (mounted) {
        // Refresh profile to update online state
        await context.read<AuthProvider>().fetchProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(val ? 'Status diubah ke ONLINE! Siap bekerja.' : 'Status diubah ke OFFLINE. Selamat beristirahat.'),
            backgroundColor: val ? Colors.green : Colors.orange,
          ),
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

  Future<void> _acceptOrder(int orderId) async {
    try {
      final provider = context.read<CourierOrderProvider>();
      await provider.acceptJob(orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tugas berhasil diterima!'), backgroundColor: Color(0xFF0F4D19)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception:', '').trim()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  double _getJobDistance(Map<String, dynamic>? courierProfile, double jobLat, double jobLon) {
    if (courierProfile == null) return 2.5; // fallback mock
    final cLat = double.tryParse(courierProfile['current_latitude']?.toString() ?? '0') ?? 0.0;
    final cLon = double.tryParse(courierProfile['current_longitude']?.toString() ?? '0') ?? 0.0;
    if (cLat == 0.0 || cLon == 0.0) {
      // Return a realistic mock distance based on job coordinates if GPS is not set
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

  IconData _getCategoryIcon(String categoryName) {
    final lower = categoryName.toLowerCase();
    if (lower.contains('plastik')) return Icons.recycling_rounded;
    if (lower.contains('kertas')) return Icons.description_rounded;
    if (lower.contains('e-waste') || lower.contains('elektronik') || lower.contains('digital')) {
      return Icons.devices_other_rounded;
    }
    if (lower.contains('organik') || lower.contains('limbah') || lower.contains('organik')) {
      return Icons.eco_rounded;
    }
    if (lower.contains('kaca') || lower.contains('beling')) return Icons.science_rounded;
    if (lower.contains('logam') || lower.contains('besi') || lower.contains('baja')) {
      return Icons.hardware_rounded;
    }
    return Icons.restore_from_trash_rounded;
  }

  Color _getCategoryColor(String categoryName) {
    final lower = categoryName.toLowerCase();
    if (lower.contains('plastik')) return const Color(0xFFE8F5E9); // light green
    if (lower.contains('kertas')) return const Color(0xFFECEFF1); // light blue-grey
    if (lower.contains('e-waste') || lower.contains('elektronik')) return const Color(0xFFE1F5FE); // light blue
    if (lower.contains('organik')) return const Color(0xFFF1F8E9); // light olive
    if (lower.contains('kaca')) return const Color(0xFFF3E5F5); // light purple
    if (lower.contains('logam')) return const Color(0xFFFFF3E0); // light orange
    return const Color(0xFFF5F5F5);
  }

  Color _getCategoryIconColor(String categoryName) {
    final lower = categoryName.toLowerCase();
    if (lower.contains('plastik')) return const Color(0xFF2E7D32);
    if (lower.contains('kertas')) return const Color(0xFF455A64);
    if (lower.contains('e-waste') || lower.contains('elektronik')) return const Color(0xFF0288D1);
    if (lower.contains('organik')) return const Color(0xFF558B2F);
    if (lower.contains('kaca')) return const Color(0xFF6A1B9A);
    if (lower.contains('logam')) return const Color(0xFFE65100);
    return Colors.grey;
  }

  void _showNotificationDialog(BuildContext context) {
    context.read<CourierOrderProvider>().fetchNotifications();

    showDialog(
      context: context,
      builder: (context) {
        return Consumer<CourierOrderProvider>(
          builder: (context, provider, child) {
            final list = provider.notifications;
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Notifikasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  if (list.isNotEmpty)
                    TextButton(
                      onPressed: () async {
                        await provider.markAllNotificationsAsRead();
                      },
                      child: const Text('Baca Semua', style: TextStyle(fontSize: 12, color: Color(0xFF0F4D19))),
                    ),
                ],
              ),
              content: SizedBox(
                width: 320,
                height: 380,
                child: list.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.notifications_off_outlined, size: 48, color: Colors.grey),
                            SizedBox(height: 12),
                            Text(
                              'Belum ada notifikasi baru',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final notif = list[index];
                          return InkWell(
                            onTap: () async {
                              if (!notif.isRead) {
                                await provider.markNotificationAsRead(notif.id);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                                color: notif.isRead ? Colors.transparent : Colors.green.withOpacity(0.04),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notif.title,
                                          style: TextStyle(
                                            fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                                            fontSize: 13,
                                            color: const Color(0xFF212121),
                                          ),
                                        ),
                                      ),
                                      if (!notif.isRead)
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notif.message,
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notif.createdAt.split('T').first,
                                    style: const TextStyle(fontSize: 9, color: Colors.black26),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAllReviewsBottomSheet(BuildContext context) {
    final reviews = context.read<CourierOrderProvider>().reviews;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Semua Ulasan Penjual',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A1A1A)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: reviews.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.star_outline_rounded, size: 48, color: Colors.grey),
                                SizedBox(height: 12),
                                Text('Belum ada ulasan', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: reviews.length,
                            itemBuilder: (context, index) {
                              final rev = reviews[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: const Color(0xFF0F4D19),
                                          child: Text(
                                            rev.seller?.name != null ? rev.seller!.name[0].toUpperCase() : 'S',
                                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                rev.seller?.name ?? 'Seller EcoTrash',
                                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: List.generate(5, (sIdx) {
                                                  return Icon(
                                                    rev.rating > sIdx ? Icons.star_rounded : Icons.star_border_rounded,
                                                    color: Colors.orange,
                                                    size: 13,
                                                  );
                                                }),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      rev.comment != null && rev.comment!.isNotEmpty
                                          ? '"${rev.comment!}"'
                                          : '"Sangat baik!"',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey.shade600,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final courierProvider = context.watch<CourierOrderProvider>();
    
    final user = authProvider.user;
    final isOnline = user?['is_online'] == true || user?['is_online'] == 1;
    final courierProfile = user?['courier_profile'];
    final activeJob = courierProvider.activeJob;

    final facePhotoPath = courierProfile?['face_photo'];
    final facePhotoUrl = facePhotoPath != null
        ? '${DioClient().baseUrl}/storage-proxy/$facePhotoPath'
        : null;

    final rating = double.tryParse(courierProfile?['rating']?.toString() ?? '0') ?? 0.0;
    final displayRating = rating == 0.0 ? 4.9 : rating;

    // Resolve vehicle details dynamically
    final vehicleTypeRaw = courierProfile?['vehicle_type']?.toString().toLowerCase() ?? '';
    final isCar = vehicleTypeRaw.contains('mobil') || vehicleTypeRaw.contains('cargo') || vehicleTypeRaw.contains('car') || vehicleTypeRaw.contains('drive');
    final vehicleTitle = isCar ? 'EcoDrive' : 'EcoRide';
    final vehicleIcon = isCar ? Icons.local_shipping_rounded : Icons.motorcycle_rounded;

    // Greeting based on time
    String getGreeting() {
      final hour = DateTime.now().hour;
      if (hour >= 5 && hour < 12) return 'SELAMAT PAGI,';
      if (hour >= 12 && hour < 17) return 'SELAMAT SIANG,';
      if (hour >= 17 && hour < 19) return 'SELAMAT SORE,';
      return 'SELAMAT MALAM,';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEFF2EE), // Soft pastel green-grey scaffold background
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Premium Header (Full Width White Background)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(top: 50, bottom: 16, left: 24, right: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Vehicle Info Block
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            vehicleIcon,
                            color: const Color(0xFF0F4D19),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicleTitle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                                height: 1.1,
                              ),
                            ),
                            const Text(
                              'LOGISTICS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Notification & Avatar Block
                    Row(
                      children: [
                        // Bell Stack
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF212121), size: 26),
                              onPressed: () => _showNotificationDialog(context),
                            ),
                            if (courierProvider.unreadCount > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 14,
                                    minHeight: 14,
                                  ),
                                  child: Text(
                                    '${courierProvider.unreadCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        // Profile Avatar
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFC8E6C9), width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFF0F4D19),
                            backgroundImage: facePhotoUrl != null
                                ? NetworkImage(facePhotoUrl)
                                : null,
                            child: facePhotoUrl == null
                                ? Text(
                                    user != null && user['name'] != null
                                        ? user['name'][0].toString().toUpperCase()
                                        : 'K',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Greeting Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getGreeting(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user != null ? '${user['name']}' : 'Kurir EcoTrash',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    // Status Toggle
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'STATUS KERJA',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Switch(
                              value: isOnline,
                              activeColor: const Color(0xFF2E7D32),
                              activeTrackColor: const Color(0xFFC8E6C9),
                              onChanged: _toggleOnline,
                            ),
                            Text(
                              isOnline ? 'Online' : 'Offline',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isOnline ? const Color(0xFF2E7D32) : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 3. Performance Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.star_rounded,
                              color: Colors.orange.shade800,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    displayRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  Text(
                                    ' / 5.0',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Rating Performa Anda',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 4. Tugas Aktif Section
              if (activeJob != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.deepOrange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Tugas Aktif',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ID ORDER',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  activeJob.orderCode,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                activeJob.status == 'ACCEPTED'
                                    ? 'DISETUJUI'
                                    : activeJob.status == 'PICKED_UP'
                                        ? 'DALAM PERJALANAN'
                                        : activeJob.status == 'DELIVERED'
                                            ? 'SAMPAI DI GUDANG'
                                            : activeJob.status,
                                style: TextStyle(
                                  color: Colors.orange.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(height: 1, color: Colors.grey.shade100),
                        const SizedBox(height: 16),
                        // Journey Timeline Flow
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF2E7D32), width: 2),
                                  ),
                                  child: const Center(
                                    child: CircleAvatar(
                                      radius: 4,
                                      backgroundColor: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 2,
                                  height: 45,
                                  color: Colors.grey.shade200,
                                ),
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF3E0),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.orange.shade800, width: 2),
                                  ),
                                  child: Center(
                                    child: CircleAvatar(
                                      radius: 4,
                                      backgroundColor: Colors.orange.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Penjemputan',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        activeJob.seller?.name ?? 'Seller EcoTrash',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                                      ),
                                      Text(
                                        activeJob.sellerAddress?.address ?? '-',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Tujuan',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepOrange,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Gudang Utama EcoTrash',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                                      ),
                                      Text(
                                        'Jalan Raya Buah Batu No. 12, Bandung',
                                        style: TextStyle(fontSize: 11, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                          label: Text(
                            activeJob.status == 'DELIVERED'
                                ? 'Selesaikan Tugas'
                                : 'Buka Alur Penjemputan',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CourierActiveJobScreen(orderId: activeJob.id),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // 5. Ulasan Penjual Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ulasan Penjual',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Minggu Ini',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF0F4D19),
                            size: 24,
                          ),
                          onPressed: () => _showAllReviewsBottomSheet(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              courierProvider.reviews.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.star_outline_rounded, color: Colors.grey, size: 36),
                            SizedBox(height: 8),
                            Text(
                              'Belum ada ulasan dari penjual.',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 145,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: courierProvider.reviews.length,
                        itemBuilder: (context, index) {
                          final rev = courierProvider.reviews[index];
                          return Container(
                            width: 290,
                            margin: const EdgeInsets.only(right: 16),
                            padding: const EdgeInsets.all(16),
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
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: const Color(0xFF0F4D19),
                                      child: Text(
                                        rev.seller?.name != null ? rev.seller!.name[0].toUpperCase() : 'S',
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            rev.seller?.name ?? 'Seller EcoTrash',
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: List.generate(5, (sIdx) {
                                              return Icon(
                                                rev.rating > sIdx ? Icons.star_rounded : Icons.star_border_rounded,
                                                color: Colors.orange,
                                                size: 13,
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: Text(
                                    rev.comment != null && rev.comment!.isNotEmpty
                                        ? '"${rev.comment!}"'
                                        : '"Sangat baik!"',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey.shade600,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

              const SizedBox(height: 28),

              // 6. Order Tersedia Section
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: const Text(
                  'Order Tersedia',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Available Jobs list
              if (!isOnline && activeJob == null) ...[
                // Offline State Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.withOpacity(0.15)),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.wifi_off_rounded, color: Colors.orange, size: 40),
                        SizedBox(height: 12),
                        Text(
                          'Status Kerja Offline',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF212121)),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Aktifkan status "Mulai Online" di atas untuk melihat dan menerima tugas penjemputan sampah!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else if (courierProvider.availableJobs.isEmpty) ...[
                // Empty State Card
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.assignment_turned_in_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'Belum ada tugas tersedia saat ini.\nSilakan tarik untuk memuat ulang.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // Dynamic List of Available Jobs
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: courierProvider.availableJobs.length,
                  itemBuilder: (context, index) {
                    final job = courierProvider.availableJobs[index];
                    final firstItem = job.items.isNotEmpty ? job.items.first : null;
                    final categoryName = firstItem?.wasteCategory?.name ?? 'Sampah Campuran';
                    
                    final iconData = _getCategoryIcon(categoryName);
                    final bgColor = _getCategoryColor(categoryName);
                    final iconColor = _getCategoryIconColor(categoryName);

                    final distance = _getJobDistance(courierProfile, job.latitude, job.longitude);
                    final hasActive = activeJob != null;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  iconData,
                                  color: iconColor,
                                  size: 24,
                                ),
                              ),
                              if (hasActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: const Text(
                                    'Tugas Aktif Berjalan',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Pengambilan $categoryName Rumah Tangga',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: hasActive ? Colors.grey : const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            job.sellerAddress?.address ?? 'Alamat Seller',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              height: 1.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 1,
                            color: Colors.grey.shade100,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.explore_outlined, size: 16, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Jarak',
                                          style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          '$distance km',
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: hasActive ? Colors.grey : const Color(0xFF1A1A1A)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.scale_outlined, size: 16, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Berat',
                                          style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          '${job.estimatedTotalWeight.toInt()} kg',
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: hasActive ? Colors.grey : const Color(0xFF1A1A1A)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: hasActive ? null : () => _acceptOrder(job.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hasActive ? Colors.grey.shade300 : const Color(0xFF0F4D19),
                              foregroundColor: hasActive ? Colors.grey.shade600 : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              minimumSize: const Size(double.infinity, 48),
                              elevation: 0,
                            ),
                            child: Text(
                              hasActive ? 'Tidak Dapat Menerima Tugas Baru' : 'Terima Tugas',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
