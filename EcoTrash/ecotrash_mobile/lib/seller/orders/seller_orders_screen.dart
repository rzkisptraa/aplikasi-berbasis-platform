import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/seller_order_provider.dart';
import 'screens/seller_order_detail_screen.dart';
import '../../../shared/models/order_model.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SellerOrderProvider>().fetchOrders();
    });
  }

  Future<void> _refresh() async {
    await context.read<SellerOrderProvider>().fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<SellerOrderProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pesanan Saya'),
          bottom: const TabBar(
            indicatorColor: Colors.green,
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Aktif'),
              Tab(text: 'Riwayat'),
            ],
          ),
        ),
        body: orderProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refresh,
                child: TabBarView(
                  children: [
                    _buildOrderList(orderProvider.activeOrders, 'Belum ada pesanan aktif.'),
                    _buildOrderList(orderProvider.historyOrders, 'Belum ada riwayat pesanan.'),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> list, String emptyMessage) {
    if (list.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_outlined, size: 70, color: Colors.grey.withOpacity(0.4)),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final order = list[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SellerOrderDetailScreen(orderId: order.id),
                ),
              );
            },
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getStatusBg(order.status),
                shape: BoxShape.circle,
              ),
              child: Icon(_getStatusIcon(order.status), color: _getStatusColor(order.status)),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderCode,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  _getStatusLabel(order.status),
                  style: TextStyle(
                    color: _getStatusColor(order.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  order.sellerAddress?.address ?? 'Alamat penjemputan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Berat: ${order.estimatedTotalWeight} kg | ${order.vehicleType == 'EcoCargo' ? 'EcoCargo' : 'EcoRide'}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      order.status == 'COMPLETED'
                          ? 'Total: Rp ${order.totalPrice.toInt()}'
                          : 'Estimasi: Rp ${order.estimatedTotalPrice.toInt()}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
    if (status == 'COMPLETED') return Icons.check_circle_outline;
    return Icons.cancel_outlined;
  }

  String _getStatusLabel(String status) {
    if (status == 'PENDING') return 'Menunggu';
    if (status == 'ACCEPTED') return 'Diterima';
    if (status == 'PICKED_UP') return 'Diambil';
    if (status == 'DELIVERED') return 'Gudang';
    if (status == 'COMPLETED') return 'Selesai';
    return 'Dibatalkan';
  }
}