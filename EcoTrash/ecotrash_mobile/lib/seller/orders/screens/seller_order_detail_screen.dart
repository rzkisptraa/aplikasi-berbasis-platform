import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/seller_order_provider.dart';
import '../../../shared/models/order_model.dart';
import '../../reviews/screens/review_courier_dialog.dart';
import '../../../../core/network/dio_client.dart';

class SellerOrderDetailScreen extends StatefulWidget {
  final int orderId;
  const SellerOrderDetailScreen({super.key, required this.orderId});

  @override
  State<SellerOrderDetailScreen> createState() => _SellerOrderDetailScreenState();
}

class _SellerOrderDetailScreenState extends State<SellerOrderDetailScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SellerOrderProvider>().fetchOrders();
    });
  }

  void _cancelOrder(OrderModel order) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Batalkan Pesanan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Apakah Anda yakin ingin membatalkan pesanan ini? Masukkan alasannya di bawah ini.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Alasan Pembatalan',
                  hintText: 'Misal: Salah memilih alamat',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Alasan pembatalan harus diisi'), backgroundColor: Colors.red),
                  );
                  return;
                }

                try {
                  Navigator.pop(context);
                  await context.read<SellerOrderProvider>().cancelOrder(order.id, reason);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pesanan berhasil dibatalkan'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Batalkan'),
            ),
          ],
        );
      },
    );
  }

  void _giveReview(OrderModel order) {
    if (order.courier == null) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ReviewCourierDialog(
          orderId: order.id,
          courierId: order.courier!.id,
          courierName: order.courier!.name,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<SellerOrderProvider>();
    final orderList = orderProvider.orders.where((o) => o.id == widget.orderId);
    
    if (orderList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pesanan')),
        body: const Center(child: Text('Pesanan tidak ditemukan')),
      );
    }

    final order = orderList.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Status Tracker Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.orderCode,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusBg(order.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusLabel(order.status),
                          style: TextStyle(
                            color: _getStatusColor(order.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tahapan Status Penjemputan:',
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // Live Tracker Step Indicators
                  _buildTrackerTimeline(order.status),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kendaraan Penjemputan',
                        style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        order.vehicleType == 'EcoCargo' ? 'EcoCargo' : 'EcoRide',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: order.vehicleType == 'EcoCargo' ? Colors.blue.shade700 : Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Info Kurir (Jika Diterima)
            if (order.courier != null) ...[
              const Text(
                'Kurir Penjemput',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: Colors.green, size: 30),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  order.courier!.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.verified, color: Colors.blue, size: 16),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Plat: ${order.courier!.courierProfile?.vehiclePlate ?? "-"} (${order.courier!.courierProfile?.vehicleType ?? "-"})',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 3. Foto Penjemputan (Jika di-upload)
            if (order.pickupPhoto != null) ...[
              const Text(
                'Foto Penjemputan Sampah',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  image: DecorationImage(
                    image: NetworkImage(
                      // Prepend backend baseUrl with storage-proxy to bypass CORS policy
                      DioClient().baseUrl + '/storage-proxy/' + order.pickupPhoto!,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 4. Rincian Barang Sampah
            const Text(
              'Rincian Sampah',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.12)),
              ),
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order.items.length,
                    itemBuilder: (context, index) {
                      final item = order.items[index];
                      final catName = item.wasteCategory?.name ?? 'Kategori sampah';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(catName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  order.status == 'COMPLETED'
                                      ? '${item.actualWeight} kg (Aktual)'
                                      : '${item.estimatedWeight} kg (Estimasi)',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                Text(
                                  _currencyFormat.format(item.subtotal),
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pendapatan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(
                        order.status == 'COMPLETED'
                            ? _currencyFormat.format(order.totalPrice)
                            : _currencyFormat.format(order.estimatedTotalPrice) + ' (Est)',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 5. Catatan
            if (order.pickupNotes != null && order.pickupNotes!.isNotEmpty) ...[
              const Text(
                'Catatan Penjemputan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                order.pickupNotes!,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 24),
            ],

            // 6. Alasan Pembatalan
            if (order.status == 'CANCELLED' && order.cancelReason != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withOpacity(0.12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Alasan Pembatalan:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                    const SizedBox(height: 4),
                    Text(order.cancelReason!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Action Buttons
            if (order.status == 'PENDING') ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => _cancelOrder(order),
                child: const Text('Batalkan Pesanan'),
              ),
            ],

            if (order.status == 'COMPLETED') ...[
              ElevatedButton(
                onPressed: () => _giveReview(order),
                child: const Text('Berikan Ulasan Kurir'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrackerTimeline(String currentStatus) {
    final stages = ['PENDING', 'ACCEPTED', 'PICKED_UP', 'DELIVERED', 'COMPLETED'];
    final labels = ['Menunggu', 'Diterima', 'Diambil', 'Gudang', 'Selesai'];

    int activeIndex = stages.indexOf(currentStatus);
    if (currentStatus == 'CANCELLED') {
      activeIndex = -1; // Block steps since cancelled
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(stages.length, (index) {
        final isDone = activeIndex >= index;
        final isCurrent = activeIndex == index;
        
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDone
                    ? Colors.green
                    : isCurrent
                        ? Colors.green.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(stages[index]),
                color: isDone ? Colors.white : Colors.grey,
                size: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              labels[index],
              style: TextStyle(
                fontSize: 10,
                fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                color: isDone ? Colors.green : Colors.grey,
              ),
            ),
          ],
        );
      }),
    );
  }

  Color _getStatusBg(String status) {
    if (status == 'PENDING') return Colors.orange.withOpacity(0.12);
    if (status == 'ACCEPTED') return Colors.blue.withOpacity(0.12);
    if (status == 'PICKED_UP') return Colors.teal.withOpacity(0.12);
    if (status == 'DELIVERED') return Colors.indigo.withOpacity(0.12);
    if (status == 'COMPLETED') return Colors.green.withOpacity(0.12);
    return Colors.red.withOpacity(0.12);
  }

  Color _getStatusColor(String status) {
    if (status == 'PENDING') return Colors.orange;
    if (status == 'ACCEPTED') return Colors.blue;
    if (status == 'PICKED_UP') return Colors.teal;
    if (status == 'DELIVERED') return Colors.indigo;
    if (status == 'COMPLETED') return Colors.green;
    return Colors.red;
  }

  IconData _getStatusIcon(String status) {
    if (status == 'PENDING') return Icons.hourglass_empty;
    if (status == 'ACCEPTED') return Icons.local_shipping;
    if (status == 'PICKED_UP') return Icons.shopping_bag;
    if (status == 'DELIVERED') return Icons.warehouse;
    if (status == 'COMPLETED') return Icons.check_circle;
    return Icons.cancel;
  }

  String _getStatusLabel(String status) {
    if (status == 'PENDING') return 'Menunggu';
    if (status == 'ACCEPTED') return 'Diterima';
    if (status == 'PICKED_UP') return 'Diambil Kurir';
    if (status == 'DELIVERED') return 'Dikirim ke Gudang';
    if (status == 'COMPLETED') return 'Selesai';
    return 'Dibatalkan';
  }
}
