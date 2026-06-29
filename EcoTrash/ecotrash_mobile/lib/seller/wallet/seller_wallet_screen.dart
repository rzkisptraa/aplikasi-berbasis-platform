import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/seller_wallet_provider.dart';
import '../withdrawals/screens/withdrawal_screen.dart';

class SellerWalletScreen extends StatefulWidget {
  const SellerWalletScreen({super.key});

  @override
  State<SellerWalletScreen> createState() => _SellerWalletScreenState();
}

class _SellerWalletScreenState extends State<SellerWalletScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SellerWalletProvider>().fetchWalletData();
    });
  }

  Future<void> _refresh() async {
    await context.read<SellerWalletProvider>().fetchWalletData();
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<SellerWalletProvider>();

    // Combine and sort transactions and withdrawals
    final List<Map<String, dynamic>> combinedList = [];

    for (final tx in walletProvider.transactions) {
      // Skip withdrawal-related transaction logs to avoid duplicates (they are already shown as Tarik Saldo)
      if (tx.type == 'WITHDRAW' ||
          tx.description.toLowerCase().contains('withdrawal') ||
          tx.description.toLowerCase().contains('tarik saldo')) {
        continue;
      }
      combinedList.add({
        'date': DateTime.tryParse(tx.createdAt) ?? DateTime(2000),
        'description': tx.description,
        'amount': tx.amount,
        'isCredit': tx.type == 'CREDIT',
        'isWithdrawal': false,
        'status': tx.status,
        'createdAt': tx.createdAt,
        'raw': tx,
      });
    }

    for (final wd in walletProvider.withdrawals) {
      combinedList.add({
        'date': DateTime.tryParse(wd.createdAt) ?? DateTime(2000),
        'description': 'Tarik Saldo (${wd.bankName})',
        'amount': wd.amount,
        'isCredit': false,
        'isWithdrawal': true,
        'status': wd.status,
        'createdAt': wd.createdAt,
        'raw': wd,
      });
    }

    // Sort descending by date
    combinedList.sort((a, b) => b['date'].compareTo(a['date']));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dompet Saya'),
      ),
      body: walletProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Premium Balance Board
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Saldo Dapat Ditarik',
                            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _currencyFormat.format(walletProvider.balance),
                            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.green,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            icon: const Icon(Icons.account_balance),
                            label: const Text('Tarik Saldo Rekening'),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const WithdrawalScreen()),
                              );
                              // Refresh wallet balance on back
                              await walletProvider.fetchWalletData();
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Transaction Logs Header
                    const Text(
                      'Riwayat Transaksi Dompet',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),

                    combinedList.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Column(
                                children: [
                                  Icon(Icons.receipt_long_outlined, size: 54, color: Colors.grey.withOpacity(0.4)),
                                  const SizedBox(height: 12),
                                  const Text('Belum ada transaksi dompet.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: combinedList.length,
                            itemBuilder: (context, index) {
                              final item = combinedList[index];
                              
                              if (item['isWithdrawal'] == true) {
                                final wd = item['raw'];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.arrow_downward,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Tarik Saldo (${wd.bankName})',
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        wd.createdAt.split('T').first,
                                                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: _getWdBg(wd.status),
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: Text(
                                                          _getWdLabel(wd.status),
                                                          style: TextStyle(
                                                            color: _getWdColor(wd.status),
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 8,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              '-${_currencyFormat.format(wd.amount)}',
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (wd.adminNotes != null && wd.adminNotes!.isNotEmpty) ...[
                                          const SizedBox(height: 10),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'Catatan Admin: ${wd.adminNotes}',
                                              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                final tx = item['raw'];
                                final isCredit = tx.type == 'CREDIT';
                                final sign = isCredit ? '+' : '-';
                                final txColor = isCredit ? Colors.green : Colors.red;
                                final txIcon = isCredit ? Icons.arrow_upward : Icons.arrow_downward;

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    leading: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: txColor.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        txIcon,
                                        color: txColor,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      tx.description,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      tx.createdAt.split('T').first,
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                    trailing: Text(
                                      '$sign${_currencyFormat.format(tx.amount)}',
                                      style: TextStyle(
                                        color: txColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Color _getWdBg(String status) {
    if (status == 'PENDING') return Colors.orange.withOpacity(0.12);
    if (status == 'APPROVED' || status == 'PAID') return Colors.green.withOpacity(0.12);
    return Colors.red.withOpacity(0.12);
  }

  Color _getWdColor(String status) {
    if (status == 'PENDING') return Colors.orange;
    if (status == 'APPROVED' || status == 'PAID') return Colors.green;
    return Colors.red;
  }

  String _getWdLabel(String status) {
    if (status == 'PENDING') return 'Menunggu';
    if (status == 'APPROVED') return 'Disetujui';
    if (status == 'PAID') return 'Lunas';
    return 'Ditolak';
  }
}