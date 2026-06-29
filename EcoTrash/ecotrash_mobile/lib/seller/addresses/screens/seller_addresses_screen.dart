import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import '../providers/seller_address_provider.dart';
import '../models/seller_address_model.dart';

class SellerAddressesScreen extends StatefulWidget {
  const SellerAddressesScreen({super.key});

  @override
  State<SellerAddressesScreen> createState() => _SellerAddressesScreenState();
}

class _SellerAddressesScreenState extends State<SellerAddressesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SellerAddressProvider>().fetchAddresses();
    });
  }

  Future<void> addAddress() async {
    final labelController = TextEditingController();
    final addressController = TextEditingController();
    final latController = TextEditingController(text: '-6.9174'); // Default Bandung Latitude
    final lngController = TextEditingController(text: '107.6191'); // Default Bandung Longitude
    bool isDefault = false;

    final provider = context.read<SellerAddressProvider>();

    // Asynchronously try to fetch live GPS location to pre-populate coordinates
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
        Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 3),
        );
        latController.text = pos.latitude.toString();
        lngController.text = pos.longitude.toString();
      }
    } catch (_) {}

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Tambah Alamat Baru'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: labelController,
                      decoration: const InputDecoration(
                        labelText: 'Label Alamat',
                        hintText: 'Contoh: Rumah / Kantor / Kos',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Alamat Lengkap',
                        hintText: 'Jalan, RT/RW, Nomor, Kecamatan',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: latController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Latitude (Garis Lintang)',
                        hintText: 'Contoh: -6.9174',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: lngController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Longitude (Garis Bujur)',
                        hintText: 'Contoh: 107.6191',
                      ),
                    ),
                    const SizedBox(height: 14),
                    CheckboxListTile(
                      title: const Text('Jadikan Alamat Utama', style: TextStyle(fontSize: 14)),
                      value: isDefault,
                      activeColor: Colors.green,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setDialogState(() {
                          isDefault = val ?? false;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Koordinat di atas dideteksi otomatis via GPS. Anda dapat menyesuaikannya agar peta berjalan akurat.',
                      style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    try {
                      final label = labelController.text.trim();
                      final addr = addressController.text.trim();
                      final double lat = double.tryParse(latController.text) ?? -6.9174;
                      final double lng = double.tryParse(lngController.text) ?? 107.6191;

                      if (label.isEmpty || addr.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Label dan Alamat tidak boleh kosong'), backgroundColor: Colors.orange),
                        );
                        return;
                      }

                      await provider.addAddress(
                        label: label,
                        address: addr,
                        latitude: lat,
                        longitude: lng,
                        isDefault: isDefault,
                      );

                      if (!mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Alamat berhasil ditambahkan'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> editAddress(SellerAddressModel item) async {
    final labelController = TextEditingController(text: item.label);
    final addressController = TextEditingController(text: item.address);
    final latController = TextEditingController(text: item.latitude.toString());
    final lngController = TextEditingController(text: item.longitude.toString());
    bool isDefault = item.isDefault;

    final provider = context.read<SellerAddressProvider>();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Edit Alamat'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: labelController,
                      decoration: const InputDecoration(
                        labelText: 'Label Alamat',
                        hintText: 'Contoh: Rumah / Kantor / Kos',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Alamat Lengkap',
                        hintText: 'Jalan, RT/RW, Nomor, Kecamatan',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: latController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Latitude (Garis Lintang)',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: lngController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Longitude (Garis Bujur)',
                      ),
                    ),
                    const SizedBox(height: 14),
                    CheckboxListTile(
                      title: const Text('Jadikan Alamat Utama', style: TextStyle(fontSize: 14)),
                      value: isDefault,
                      activeColor: Colors.green,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setDialogState(() {
                          isDefault = val ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    try {
                      final label = labelController.text.trim();
                      final addr = addressController.text.trim();
                      final double lat = double.tryParse(latController.text) ?? item.latitude;
                      final double lng = double.tryParse(lngController.text) ?? item.longitude;

                      if (label.isEmpty || addr.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Label dan Alamat tidak boleh kosong'), backgroundColor: Colors.orange),
                        );
                        return;
                      }

                      await provider.updateAddress(
                        id: item.id,
                        label: label,
                        address: addr,
                        latitude: lat,
                        longitude: lng,
                        isDefault: isDefault,
                      );

                      if (!mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Alamat berhasil diperbarui'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SellerAddressProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alamat Saya'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Alamat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: addAddress,
      ),
      body: Container(
        color: const Color(0xFFF9F9F9),
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.addresses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off_outlined, size: 72, color: Colors.grey.withOpacity(0.4)),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum ada alamat terdaftar',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tambahkan alamat penjemputan sampah Anda.',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: provider.addresses.length,
                    itemBuilder: (context, index) {
                      final item = provider.addresses[index];
                      final bool isDefault = item.isDefault;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isDefault ? Colors.green : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        elevation: 2,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: isDefault
                              ? null
                              : () async {
                                  // Set default when tapped
                                  await provider.updateAddress(
                                    id: item.id,
                                    label: item.label,
                                    address: item.address,
                                    latitude: item.latitude,
                                    longitude: item.longitude,
                                    isDefault: true,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${item.label} dijadikan alamat utama'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          item.label.toLowerCase().contains('kantor')
                                              ? Icons.business
                                              : item.label.toLowerCase().contains('kos')
                                                  ? Icons.home_work
                                                  : Icons.home,
                                          color: isDefault ? Colors.green : Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          item.label,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    if (isDefault)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'Utama',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  item.address,
                                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Koordinat: ${item.latitude}, ${item.longitude}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: 'monospace'),
                                ),
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (!isDefault)
                                      TextButton.icon(
                                        onPressed: () async {
                                          await provider.updateAddress(
                                            id: item.id,
                                            label: item.label,
                                            address: item.address,
                                            latitude: item.latitude,
                                            longitude: item.longitude,
                                            isDefault: true,
                                          );
                                        },
                                        icon: const Icon(Icons.star_border, size: 18, color: Colors.green),
                                        label: const Text('Jadikan Utama', style: TextStyle(color: Colors.green, fontSize: 12)),
                                      ),
                                    TextButton.icon(
                                      onPressed: () => editAddress(item),
                                      icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                                      label: const Text('Edit', style: TextStyle(color: Colors.blue, fontSize: 12)),
                                    ),
                                    TextButton.icon(
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (_) {
                                            return AlertDialog(
                                              title: const Text('Hapus Alamat?'),
                                              content: Text('Apakah Anda yakin ingin menghapus alamat "${item.label}"?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: const Text('Batal'),
                                                ),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                  onPressed: () => Navigator.pop(context, true),
                                                  child: const Text('Hapus'),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (confirm == true) {
                                          await provider.deleteAddress(item.id);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Alamat berhasil dihapus'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                      label: const Text('Hapus', style: TextStyle(color: Colors.red, fontSize: 12)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
