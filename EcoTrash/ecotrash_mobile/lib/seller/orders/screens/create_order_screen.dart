import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/seller_order_provider.dart';
import '../../addresses/providers/seller_address_provider.dart';
import '../../addresses/models/seller_address_model.dart';
import '../../addresses/screens/seller_addresses_screen.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  SellerAddressModel? _selectedAddress;
  final TextEditingController _notesController = TextEditingController();
  final Map<int, double> _weights = {}; // maps wasteCategoryId to weight
  final Map<int, TextEditingController> _controllers = {};
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String _selectedVehicleType = 'EcoRide';

  String _formatWeight(double w) {
    if (w == 0.0) return '';
    if (w == w.roundToDouble()) {
      return w.round().toString();
    }
    return w.toStringAsFixed(1);
  }

  TextEditingController _getController(int catId, double currentW) {
    if (!_controllers.containsKey(catId)) {
      _controllers[catId] = TextEditingController(text: _formatWeight(currentW));
    }
    return _controllers[catId]!;
  }

  @override
  void dispose() {
    _notesController.dispose();
    for (var ctrl in _controllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _checkWeightLimit() {
    double totalWeight = 0.0;
    _weights.forEach((_, w) => totalWeight += w);
    if (totalWeight > 30.0 && _selectedVehicleType != 'EcoCargo') {
      setState(() {
        _selectedVehicleType = 'EcoCargo';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Total berat > 30 kg. Kendaraan otomatis dialihkan ke EcoCargo.'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showVehicleInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.green),
            SizedBox(width: 8),
            Text('Bagaimana memilih?', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih EcoRide jika total sampah kurang dari 30 kg dan mudah dibawa oleh satu orang.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            SizedBox(height: 12),
            Text(
              'Pilih EcoCargo jika sampah lebih dari 30 kg, terdiri dari banyak karung, atau memiliki ukuran besar seperti kardus, besi, dan barang elektronik.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleOption({
    required String title,
    required String subtitle,
    required String capacity,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withOpacity(0.04) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          capacity,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.green : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final addrProvider = context.read<SellerAddressProvider>();
      await addrProvider.fetchAddresses();
      
      // Auto-select default address if exists
      if (addrProvider.addresses.isNotEmpty) {
        setState(() {
          _selectedAddress = addrProvider.addresses.firstWhere(
            (e) => e.isDefault,
            orElse: () => addrProvider.addresses.first,
          );
        });
      }
    });
  }

  double get _totalEstimatePrice {
    double total = 0.0;
    final categories = context.read<SellerOrderProvider>().categories;
    for (var cat in categories) {
      final w = _weights[cat.id] ?? 0.0;
      total += w * cat.pricePerKg;
    }
    return total;
  }

  double get _totalEstimateWeight {
    double total = 0.0;
    _weights.forEach((_, w) => total += w);
    return total;
  }

  Future<void> _submit() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih alamat penjemputan terlebih dahulu'), backgroundColor: Colors.orange),
      );
      return;
    }

    final itemsPayload = <Map<String, dynamic>>[];
    _weights.forEach((catId, weight) {
      if (weight > 0) {
        itemsPayload.add({
          'waste_category_id': catId,
          'estimated_weight': weight,
        });
      }
    });

    if (itemsPayload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan tentukan minimal 1 item sampah dengan berat > 0 kg'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_totalEstimateWeight > 30 && _selectedVehicleType == 'EcoRide') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Total berat melebihi 30 kg. Silakan pilih kendaraan EcoCargo.'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      final orderProvider = context.read<SellerOrderProvider>();
      await orderProvider.createOrder(
        addressId: _selectedAddress!.id,
        notes: _notesController.text.trim(),
        latitude: _selectedAddress!.latitude,
        longitude: _selectedAddress!.longitude,
        items: itemsPayload,
        vehicleType: _selectedVehicleType,
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesanan berhasil dibuat! Menunggu kurir mengambil.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception:', '').trim()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final addrProvider = context.watch<SellerAddressProvider>();
    final orderProvider = context.watch<SellerOrderProvider>();
    final categories = orderProvider.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jual Sampah'),
      ),
      body: orderProvider.isLoading || addrProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Pilih Alamat Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Alamat Penjemputan',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () async {
                          final oldSelectedId = _selectedAddress?.id;
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SellerAddressesScreen()),
                          );
                          // Refresh addresses
                          await addrProvider.fetchAddresses();
                          
                          // Re-select matching address object from newly fetched list
                          if (oldSelectedId != null && addrProvider.addresses.isNotEmpty) {
                            setState(() {
                              _selectedAddress = addrProvider.addresses.firstWhere(
                                (e) => e.id == oldSelectedId,
                                orElse: () => addrProvider.addresses.firstWhere(
                                  (e) => e.isDefault,
                                  orElse: () => addrProvider.addresses.first,
                                ),
                              );
                            });
                          } else if (addrProvider.addresses.isNotEmpty) {
                            setState(() {
                              _selectedAddress = addrProvider.addresses.firstWhere(
                                (e) => e.isDefault,
                                orElse: () => addrProvider.addresses.first,
                              );
                            });
                          } else {
                            setState(() {
                              _selectedAddress = null;
                            });
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          backgroundColor: Colors.green.withOpacity(0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.edit_location_alt_outlined, size: 14, color: Colors.green),
                            SizedBox(width: 4),
                            Text(
                              'Kelola',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  addrProvider.addresses.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.red.withOpacity(0.15)),
                          ),
                          child: const Text(
                            'Anda belum membuat alamat. Silakan klik Kelola Alamat untuk menambah alamat penjemputan.',
                            style: TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<SellerAddressModel>(
                              isExpanded: true,
                              value: _selectedAddress != null && addrProvider.addresses.any((e) => e.id == _selectedAddress!.id)
                                  ? addrProvider.addresses.firstWhere((e) => e.id == _selectedAddress!.id)
                                  : null,
                              hint: const Text('Pilih Alamat Penjemputan'),
                              items: addrProvider.addresses.map((addr) {
                                return DropdownMenuItem<SellerAddressModel>(
                                  value: addr,
                                  child: Text(
                                    '[${addr.label}] ${addr.address}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedAddress = val;
                                });
                              },
                            ),
                          ),
                        ),

                  const SizedBox(height: 28),

                  // 2. Kategori Sampah List
                  const Text(
                    'Pilih Sampah & Berat (kg)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  categories.isEmpty
                      ? const Center(child: Text('Kategori sampah tidak tersedia'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            final currentW = _weights[cat.id] ?? 0.0;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cat.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _currencyFormat.format(cat.pricePerKg) + ' / kg',
                                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Incremental Counter
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outline, color: Colors.green),
                                          onPressed: currentW <= 0
                                              ? null
                                              : () {
                                                  final newW = (currentW - 0.5 < 0) ? 0.0 : (currentW - 0.5);
                                                  setState(() {
                                                    _weights[cat.id] = newW;
                                                    _checkWeightLimit();
                                                  });
                                                  _getController(cat.id, currentW).text = _formatWeight(newW);
                                                },
                                        ),
                                        SizedBox(
                                          width: 70,
                                          height: 40,
                                          child: TextField(
                                            controller: _getController(cat.id, currentW),
                                            textAlign: TextAlign.center,
                                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black87,
                                            ),
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.grey.shade50,
                                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                              isDense: true,
                                              hintText: '0',
                                              hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: const BorderSide(color: Colors.green, width: 1.5),
                                              ),
                                            ),
                                            onChanged: (val) {
                                              double parsed = double.tryParse(val) ?? 0.0;
                                              if (parsed < 0) parsed = 0.0;
                                              _weights[cat.id] = parsed;
                                              _checkWeightLimit();
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                          onPressed: () {
                                            final newW = currentW + 0.5;
                                            setState(() {
                                              _weights[cat.id] = newW;
                                              _checkWeightLimit();
                                            });
                                            _getController(cat.id, currentW).text = _formatWeight(newW);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                  const SizedBox(height: 24),

                  // 2.5 Pilih Kendaraan
                  Row(
                    children: [
                      const Text(
                        'Pilih Kendaraan Penjemputan',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.info_outline, size: 20, color: Colors.grey),
                        onPressed: _showVehicleInfoDialog,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _buildVehicleOption(
                    title: 'EcoRide',
                    subtitle: 'Untuk sampah ringan dan jumlah sedikit',
                    capacity: 'Maksimal 30 kg',
                    isSelected: _selectedVehicleType == 'EcoRide',
                    onTap: () {
                      if (_totalEstimateWeight > 30) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Berat sampah > 30 kg. Wajib menggunakan EcoCargo.'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }
                      setState(() {
                        _selectedVehicleType = 'EcoRide';
                      });
                    },
                  ),

                  _buildVehicleOption(
                    title: 'EcoCargo',
                    subtitle: 'Untuk sampah berat atau jumlah banyak',
                    capacity: '31 kg - 500 kg',
                    isSelected: _selectedVehicleType == 'EcoCargo',
                    onTap: () {
                      setState(() {
                        _selectedVehicleType = 'EcoCargo';
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // 3. Catatan penjemputan
                  const Text(
                    'Catatan Penjemputan (Opsional)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Misal: Penjemputan setelah jam 5 sore atau gerbang abu-abu.',
                    ),
                  ),

                  const SizedBox(height: 36),

                  // 4. Ringkasan & Submit
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withOpacity(0.18)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Estimasi Berat', style: TextStyle(color: Colors.grey)),
                            Text('${_totalEstimateWeight.toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Estimasi Pendapatan',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                            Text(
                              _currencyFormat.format(_totalEstimatePrice),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: orderProvider.isLoading ? null : _submit,
                    child: const Text('Kirim Pesanan Sekarang'),
                  ),
                ],
              ),
            ),
    );
  }
}
