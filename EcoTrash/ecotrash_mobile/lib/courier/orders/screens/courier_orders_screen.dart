import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/courier_order_provider.dart';
import 'courier_active_job_screen.dart';
import '../../../shared/auth/providers/auth_provider.dart';

class CourierOrdersScreen extends StatefulWidget {
  const CourierOrdersScreen({super.key});

  @override
  State<CourierOrdersScreen> createState() => _CourierOrdersScreenState();
}

class _CourierOrdersScreenState extends State<CourierOrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CourierOrderProvider>().fetchMyCourierJobs();
      context.read<CourierOrderProvider>().fetchAvailableJobs();
    });
  }

  Future<void> _refresh() async {
    await context.read<CourierOrderProvider>().fetchMyCourierJobs();
    await context.read<CourierOrderProvider>().fetchAvailableJobs();
  }

  Future<void> _acceptOrder(int orderId) async {
    try {
      final provider = context.read<CourierOrderProvider>();
      await provider.acceptJob(orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tugas berhasil diterima!'),
            backgroundColor: Color(0xFF0F4D19),
          ),
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

  void _showAcceptConfirmationDialog(BuildContext context, dynamic job, double distance) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.assignment_outlined, color: Color(0xFF0F4D19), size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Terima Tugas?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A1A1A)),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Apakah Anda yakin ingin mengambil tugas penjemputan ini?',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildDialogInfoRow(Icons.tag_rounded, 'ID Order', job.orderCode),
                    const Divider(height: 16),
                    _buildDialogInfoRow(Icons.storefront_outlined, 'Penjual', job.seller?.name ?? 'Seller'),
                    const Divider(height: 16),
                    _buildDialogInfoRow(Icons.location_on_outlined, 'Jarak', '$distance km'),
                    const Divider(height: 16),
                    _buildDialogInfoRow(Icons.scale_outlined, 'Estimasi Berat', '${job.estimatedTotalWeight} kg'),
                    const Divider(height: 16),
                    _buildDialogInfoRow(Icons.monetization_on_outlined, 'Estimasi Pendapatan', 'Rp ${job.estimatedTotalPrice.toInt()}'),
                  ],
                ),
              ),
              if (job.pickupNotes != null && job.pickupNotes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Catatan Penjual:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.15)),
                  ),
                  child: Text(
                    job.pickupNotes!,
                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.deepOrange),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F4D19),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context);
                _acceptOrder(job.id);
              },
              child: const Text('Terima Tugas', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
      ],
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

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text(
          'Tugas Penjemputan',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: const Color(0xFF0F4D19),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tugas Aktif Anda Section
              if (activeJob != null) ...[
                const Text(
                  'Tugas Aktif Anda',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
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
                          Text(
                            activeJob.orderCode,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF0F4D19),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F4D19),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'AKTIF',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.storefront_outlined, size: 18, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Penjual: ${activeJob.seller?.name ?? "Seller EcoTrash"}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF424242),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              activeJob.sellerAddress?.address ?? "-",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F4D19),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.alt_route_rounded, size: 18),
                        label: const Text(
                          'Buka Alur Penjemputan',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                const SizedBox(height: 28),
              ],

              // 2. Tugas Tersedia Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tugas Tersedia',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  TextButton(
                    onPressed: _refresh,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F4D19),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 3. Offline Status / List of Jobs
              if (!isOnline && activeJob == null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.withOpacity(0.15)),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.wifi_off_rounded, color: Colors.orange, size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'Anda Sedang Offline',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF212121)),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Silakan aktifkan status kerja di beranda terlebih dahulu untuk melihat lowongan tugas penjemputan sampah!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else if (courierProvider.availableJobs.isEmpty) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: const [
                        Icon(Icons.assignment_turned_in_outlined, size: 54, color: Colors.grey),
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
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: courierProvider.availableJobs.length,
                  itemBuilder: (context, index) {
                    final job = courierProvider.availableJobs[index];
                    final distance = _getJobDistance(courierProfile, job.latitude, job.longitude);
                    final hasActive = activeJob != null;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF2EE), // Soft light grey-green background as shown in the mockup
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF0F4D19).withOpacity(0.1)),
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            color: Color(0xFF0F4D19),
                            size: 24,
                          ),
                        ),
                        title: Text(
                          job.orderCode,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: hasActive ? Colors.grey : const Color(0xFF1A1A1A),
                          ),
                        ),
                        subtitle: Text(
                          '${job.seller?.name ?? "Seller"} • $distance km',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey,
                          size: 24,
                        ),
                        onTap: () {
                          if (hasActive) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Anda masih memiliki tugas aktif berjalan. Selesaikan terlebih dahulu!'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          } else {
                            _showAcceptConfirmationDialog(context, job, distance);
                          }
                        },
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}