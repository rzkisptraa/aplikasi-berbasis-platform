import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../orders/providers/courier_order_provider.dart';
import '../../../shared/auth/providers/auth_provider.dart';
import '../../../../core/network/dio_client.dart';

class CourierProfileScreen extends StatefulWidget {
  const CourierProfileScreen({super.key});

  @override
  State<CourierProfileScreen> createState() => _CourierProfileScreenState();
}

class _CourierProfileScreenState extends State<CourierProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AuthProvider>().fetchProfile();
      context.read<CourierOrderProvider>().fetchMyCourierJobs();
      context.read<CourierOrderProvider>().fetchReviews();
    });
  }

  Future<void> _refresh() async {
    await context.read<AuthProvider>().fetchProfile();
    await context.read<CourierOrderProvider>().fetchMyCourierJobs();
    await context.read<CourierOrderProvider>().fetchReviews();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final courierProvider = context.watch<CourierOrderProvider>();
    
    final user = authProvider.user;
    final courierProfile = user?['courier_profile'];
    final completedJobs = courierProvider.completedJobs;

    final rating = double.tryParse(courierProfile?['rating']?.toString() ?? '0') ?? 0.0;
    final isVerified = courierProfile?['is_verified'] == 1 || courierProfile?['is_verified'] == true;
    final isOnline = user?['is_online'] == true || user?['is_online'] == 1;

    // Calculate total waste collected dynamically
    final totalWaste = completedJobs.fold<double>(0.0, (sum, job) {
      return sum + (double.tryParse(job.actualTotalWeight?.toString() ?? '0') ?? 0.0);
    });

    // Face photo URL builder
    final facePhotoPath = courierProfile?['face_photo'];
    final facePhotoUrl = facePhotoPath != null
        ? '${DioClient().baseUrl}/storage-proxy/$facePhotoPath'
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Profil Kurir'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: authProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              color: const Color(0xFF1B5E20),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Premium Avatar Card
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 54,
                                  backgroundColor: Colors.grey.shade100,
                                  backgroundImage: facePhotoUrl != null
                                      ? NetworkImage(facePhotoUrl)
                                      : null,
                                  child: facePhotoUrl == null
                                      ? const Icon(Icons.delivery_dining, size: 54, color: Color(0xFF1B5E20))
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: -2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isOnline ? const Color(0xFF2E7D32) : Colors.grey,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: Text(
                                    isOnline ? 'ONLINE' : 'OFFLINE',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                user?['name'] ?? 'Kurir EcoTrash',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              if (isVerified) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.verified, color: Colors.blue, size: 20),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: isVerified ? Colors.blue.withOpacity(0.08) : Colors.amber.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isVerified ? Colors.blue.withOpacity(0.2) : Colors.amber.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              isVerified ? 'Kurir Terverifikasi Resmi' : 'Menunggu Verifikasi Akun',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isVerified ? Colors.blue.shade700 : Colors.amber.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Green Statistics Card (Total Sampah Dikumpulkan & Total Deliveries)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF18572A),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.scale_rounded, color: Colors.white, size: 24),
                                const SizedBox(height: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'SAMPAH',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      'DIKUMPULKAN',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${totalWaste.toStringAsFixed(1)} kg',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 50,
                            width: 1,
                            color: Colors.white24,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 24),
                                const SizedBox(height: 8),
                                const Text(
                                  'TOTAL PENGIRIMAN',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  '${completedJobs.length} Kali',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 50,
                            width: 1,
                            color: Colors.white24,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 24),
                                const SizedBox(height: 8),
                                const Text(
                                  'RATING',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section 1: Informasi Akun
                    _buildSectionHeader('Informasi Akun', Icons.person_outline),
                    const SizedBox(height: 12),
                    Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              label: 'Alamat Email',
                              value: user?['email'] ?? '-',
                              icon: Icons.mail_outline,
                              iconColor: Colors.blue,
                            ),
                            const Divider(),
                            _buildInfoRow(
                              label: 'Nomor Handphone',
                              value: user?['phone'] ?? '-',
                              icon: Icons.phone_android_outlined,
                              iconColor: Colors.green,
                            ),
                            const Divider(),
                            _buildInfoRow(
                              label: 'Wilayah Kerja',
                              value: courierProfile?['city'] != null
                                  ? '${courierProfile['city']}, ${courierProfile['province']}'
                                  : '-',
                              icon: Icons.map_outlined,
                              iconColor: Colors.orange,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section 2: Informasi Kendaraan & KTP/SIM
                    _buildSectionHeader('Informasi Kendaraan & Identitas', Icons.motorcycle_outlined),
                    const SizedBox(height: 12),
                    Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              label: 'Tipe Kendaraan',
                              value: courierProfile?['vehicle_type'] == null
                                  ? '-'
                                  : (courierProfile?['vehicle_type']?.toString().toLowerCase().contains('mobil') == true ||
                                          courierProfile?['vehicle_type']?.toString().toLowerCase().contains('cargo') == true)
                                      ? 'EcoCargo'
                                      : 'EcoRide',
                              icon: Icons.commute_outlined,
                              iconColor: Colors.purple,
                            ),
                            const Divider(),
                            _buildInfoRow(
                              label: 'Plat Nomor Kendaraan',
                              value: courierProfile?['vehicle_plate'] ?? '-',
                              icon: Icons.tag,
                              iconColor: Colors.blueGrey,
                            ),
                            const Divider(),
                            _buildInfoRow(
                              label: 'Alamat Domisili',
                              value: courierProfile?['address'] ?? '-',
                              icon: Icons.home_work_outlined,
                              iconColor: Colors.brown,
                            ),
                            const Divider(),
                            _buildInfoRow(
                              label: 'Status Lisensi Mengemudi',
                              value: '',
                              icon: Icons.assignment_ind_outlined,
                              iconColor: Colors.teal,
                              valueWidget: ((courierProfile?['sim_number']?.toString() ?? '').isNotEmpty)
                                  ? Row(
                                      children: [
                                        Text(
                                          ((courierProfile?['vehicle_type']?.toString().toLowerCase() ?? '').contains('mobil') ||
                                                  (courierProfile?['vehicle_type']?.toString().toLowerCase() ?? '').contains('cargo'))
                                              ? 'SIM A (Terverifikasi)'
                                              : 'SIM C (Terverifikasi)',
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                      ],
                                    )
                                  : const Text(
                                      'Belum Terverifikasi',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const SizedBox(height: 12),

                    // Premium Logout Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: const Text('Keluar dari Akun Kurir Ini', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        await authProvider.logout();
                        if (mounted) {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                    ),

                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        'EcoTrash Courier v1.1.0',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1B5E20)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    Widget? valueWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 3),
                valueWidget ?? Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}