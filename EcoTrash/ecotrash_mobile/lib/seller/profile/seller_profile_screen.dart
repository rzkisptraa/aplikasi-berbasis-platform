import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/dio_client.dart';
import '../../../shared/auth/providers/auth_provider.dart';
import '../orders/providers/seller_order_provider.dart';
import '../wallet/providers/seller_wallet_provider.dart';
import '../addresses/screens/seller_addresses_screen.dart';

class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({super.key});

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final _passFormKey = GlobalKey<FormState>();
  final TextEditingController currentPassController = TextEditingController();
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  bool _isEditing = false;
  String _selectedAvatar = 'assets/images/seller1.jpg';
  List<int>? _pickedImageBytes;
  String? _pickedImageName;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final authProvider = context.read<AuthProvider>();
      await authProvider.fetchProfile();
      _initializeFields();
      await _loadSavedAvatar();
      
      // Fetch stats data
      context.read<SellerOrderProvider>().fetchOrders();
      context.read<SellerWalletProvider>().fetchWalletData();
    });
  }

  void _initializeFields() {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      nameController.text = user['name'] ?? '';
      phoneController.text = user['phone'] ?? '';
    }
  }

  Future<void> _loadSavedAvatar() async {
    final user = context.read<AuthProvider>().user;
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('selected_seller_avatar');
    if (saved != null) {
      setState(() {
        _selectedAvatar = saved;
      });
      return;
    }

    String defaultAvatar = 'assets/images/seller1.jpg';
    if (user != null && user['name'] != null) {
      final name = user['name'].toString().toLowerCase();
      if (name.contains('1')) {
        defaultAvatar = 'assets/images/seller1.jpg';
      } else if (name.contains('2')) {
        defaultAvatar = 'assets/images/seller2.jpg';
      } else if (name.contains('3')) {
        defaultAvatar = 'assets/images/seller3.png';
      } else if (name.contains('4')) {
        defaultAvatar = 'assets/images/seller4.jpg';
      } else if (name.contains('5')) {
        defaultAvatar = 'assets/images/seller5.jpg';
      }
    }
    setState(() {
      _selectedAvatar = defaultAvatar;
    });
  }



  Future<void> _pickImage() async {
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
                'Pilih Sumber Foto Profil',
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
                            Icon(Icons.camera_alt_rounded, color: Colors.green, size: 32),
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
                            Icon(Icons.photo_library_rounded, color: Colors.green, size: 32),
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

    final bytes = await image.readAsBytes();
    setState(() {
      _pickedImageBytes = bytes;
      _pickedImageName = image.name;
    });
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.updateProfile(
        name: nameController.text.trim(),
        email: authProvider.user?['email'] ?? '',
        phone: phoneController.text.trim(),
        photoBytes: _pickedImageBytes,
        photoName: _pickedImageName,
      );

      setState(() {
        _isEditing = false;
        _pickedImageBytes = null;
        _pickedImageName = null;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  void _showChangePasswordDialog() {
    currentPassController.clear();
    newPassController.clear();
    confirmPassController.clear();

    showDialog(
      context: context,
      builder: (context) {
        final authProvider = context.watch<AuthProvider>();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: const [
              Icon(Icons.lock, color: Colors.green),
              SizedBox(width: 10),
              Text('Ubah Password'),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _passFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: currentPassController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password Saat Ini'),
                    validator: (v) => v == null || v.isEmpty ? 'Password saat ini wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: newPassController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password Baru'),
                    validator: (v) => v == null || v.length < 8 ? 'Password baru minimal 8 karakter' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmPassController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Konfirmasi Password Baru'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Konfirmasi password wajib diisi';
                      if (v != newPassController.text) return 'Konfirmasi password tidak cocok';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: authProvider.isLoading ? null : () async {
                if (!_passFormKey.currentState!.validate()) return;
                try {
                  await authProvider.changePassword(
                    currentPassword: currentPassController.text,
                    newPassword: newPassController.text,
                    newPasswordConfirmation: confirmPassController.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password berhasil diubah'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString().replaceAll('Exception:', '').trim()), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: authProvider.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final orderProvider = context.watch<SellerOrderProvider>();
    final user = authProvider.user;

    // Calculate dynamic stats
    final completedOrders = orderProvider.orders.where((o) => o.status == 'COMPLETED').toList();
    final int setoranCount = completedOrders.length;
    final double totalWeight = completedOrders.fold(0.0, (sum, o) => sum + (o.actualTotalWeight ?? o.estimatedTotalWeight));
    final double totalEarnings = completedOrders.fold(0.0, (sum, o) => sum + o.totalPrice);

    // Eco badge logic
    String badgeName = 'Eco Beginner';
    Color badgeColor = Colors.grey;
    if (totalWeight >= 100) {
      badgeName = 'Eco Warrior';
      badgeColor = Colors.orange;
    } else if (totalWeight >= 50) {
      badgeName = 'Eco Hero';
      badgeColor = Colors.green;
    } else if (totalWeight >= 10) {
      badgeName = 'Eco Supporter';
      badgeColor = Colors.teal;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Akun'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: authProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: user == null
                  ? const Center(child: Text('Gagal memuat profil'))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Avatar Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Circular avatar with local asset load + error fallback
                              // Circular avatar with local asset load + error fallback / preview / network
                              GestureDetector(
                                onTap: _isEditing ? _pickImage : null,
                                child: Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.green, width: 3),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          )
                                        ]
                                      ),
                                      child: CircleAvatar(
                                        radius: 48,
                                        backgroundColor: Colors.white,
                                        child: ClipOval(
                                          child: _pickedImageBytes != null
                                              ? Image.memory(
                                                  Uint8List.fromList(_pickedImageBytes!),
                                                  fit: BoxFit.cover,
                                                  width: 96,
                                                  height: 96,
                                                )
                                              : (user['profile_photo'] != null
                                                  ? Image.network(
                                                      '${DioClient().baseUrl}/storage-proxy/${user['profile_photo']}',
                                                      fit: BoxFit.cover,
                                                      width: 96,
                                                      height: 96,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return const Icon(Icons.person, size: 54, color: Colors.green);
                                                      },
                                                    )
                                                  : Image.asset(
                                                      _selectedAvatar,
                                                      fit: BoxFit.cover,
                                                      width: 96,
                                                      height: 96,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return const Icon(Icons.person, size: 54, color: Colors.green);
                                                      },
                                                    )),
                                        ),
                                      ),
                                    ),
                                    if (_isEditing)
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                user['name'] ?? 'Seller EcoTrash',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: badgeColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: badgeColor.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  badgeName.toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Stats Dashboard Section
                        const Text(
                          'Performa Penjualan Sampah',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.9,
                          children: [
                            _buildStatCard(
                              title: 'Total Setoran',
                              value: '$setoranCount',
                              unit: '',
                              icon: Icons.recycling,
                              color: Colors.green,
                            ),
                            _buildStatCard(
                              title: 'Total Berat',
                              value: 'kg ${totalWeight.toStringAsFixed(1).replaceAll('.0', '')}',
                              unit: '',
                              icon: Icons.scale_outlined,
                              color: Colors.teal,
                            ),
                            _buildStatCard(
                              title: 'Pendapatan',
                              value: _currencyFormat.format(totalEarnings),
                              unit: '',
                              icon: Icons.wallet,
                              color: Colors.blue,
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // Alamat Saya Card (Requirement 2 - Moved Address to Profile)
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.location_on, color: Colors.blue),
                            ),
                            title: const Text('Kelola Alamat Saya', style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: const Text('Tambah, ubah, hapus alamat penjemputan'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SellerAddressesScreen()),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Form Profil
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Biodata Diri',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 16),

                              // Nama Lengkap
                              TextFormField(
                                controller: nameController,
                                enabled: _isEditing,
                                decoration: const InputDecoration(
                                  labelText: 'Nama Lengkap',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (value) => value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
                              ),
                              const SizedBox(height: 16),

                              // Email (Read Only always)
                              TextFormField(
                                initialValue: user['email'] ?? '',
                                enabled: false,
                                decoration: const InputDecoration(
                                  labelText: 'Alamat Email',
                                  prefixIcon: Icon(Icons.email_outlined),
                                  fillColor: Color(0xFFF1F1F1),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Nomor Telepon
                              TextFormField(
                                controller: phoneController,
                                enabled: _isEditing,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'Nomor Telepon',
                                  prefixIcon: Icon(Icons.phone_outlined),
                                ),
                                validator: (value) => value == null || value.isEmpty ? 'Nomor telepon tidak boleh kosong' : null,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Edit Buttons or Save
                        if (!_isEditing) ...[
                          OutlinedButton.icon(
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit Biodata Profil'),
                            onPressed: () {
                              setState(() {
                                _isEditing = true;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.key),
                            label: const Text('Ubah Password Akun'),
                            onPressed: _showChangePasswordDialog,
                          ),
                        ] else ...[
                          ElevatedButton.icon(
                            icon: const Icon(Icons.save),
                            label: const Text('Simpan Pembaruan'),
                            onPressed: _updateProfile,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            child: const Text('Batal'),
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _pickedImageBytes = null;
                                _pickedImageName = null;
                                _initializeFields(); // Restore fields
                              });
                            },
                          ),
                        ],

                        const SizedBox(height: 36),

                        // Logout Button
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          icon: const Icon(Icons.logout),
                          label: const Text('Keluar dari Akun'),
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
                            'EcoTrash Mobile v1.0.0\n© 2026 Universitas Telkom',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          if (unit.isNotEmpty)
            Text(
              unit,
              style: const TextStyle(fontSize: 8, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}