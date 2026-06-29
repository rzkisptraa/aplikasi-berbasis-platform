import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../wallet/providers/seller_wallet_provider.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedBankName;
  final List<String> _bankOptions = [
    'BCA',
    'Mandiri',
    'BNI',
    'BRI',
    'GoPay',
    'OVO',
    'Dana',
    'LinkAja',
  ];
  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Future<void> _submitWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;

    final walletProvider = context.read<SellerWalletProvider>();
    final amount = double.tryParse(amountController.text) ?? 0.0;

    if (amount > walletProvider.balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saldo Anda tidak mencukupi untuk melakukan penarikan ini'), backgroundColor: Colors.red),
      );
      return;
    }

    if (amount < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal penarikan adalah Rp 10.000'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      await walletProvider.requestWithdrawal(
        bankName: _selectedBankName ?? '',
        accountName: accountNameController.text.trim(),
        accountNumber: accountNumberController.text.trim(),
        amount: amount,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengajuan penarikan dana berhasil dikirim! Menunggu konfirmasi admin.'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset form
      setState(() {
        _selectedBankName = null;
      });
      accountNameController.clear();
      accountNumberController.clear();
      amountController.clear();
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
    final walletProvider = context.watch<SellerWalletProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Penarikan Saldo'),
      ),
      body: walletProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sisa Saldo Widget
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.withOpacity(0.15)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Saldo Tersedia:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            _currencyFormat.format(walletProvider.balance),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bank Name Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedBankName,
                      decoration: const InputDecoration(
                        labelText: 'Nama Bank / E-Wallet',
                        prefixIcon: Icon(Icons.account_balance),
                      ),
                      hint: const Text('Pilih Bank / E-Wallet'),
                      items: _bankOptions.map((String bank) {
                        return DropdownMenuItem<String>(
                          value: bank,
                          child: Text(bank),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedBankName = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama bank wajib dipilih';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Rekening number
                    TextFormField(
                      controller: accountNumberController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Nomor Rekening / No. Telepon',
                        prefixIcon: Icon(Icons.credit_card),
                        hintText: 'Masukkan nomor rekening bank',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor rekening wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Nama Pemilik Rekening
                    TextFormField(
                      controller: accountNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Pemilik Rekening',
                        prefixIcon: Icon(Icons.person_outline),
                        hintText: 'Masukkan nama sesuai buku tabungan',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama pemilik rekening wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Nominal Tarik
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Nominal Penarikan (Rupiah)',
                        prefixIcon: Icon(Icons.monetization_on_outlined),
                        hintText: 'Minimal Rp 10.000',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nominal penarikan wajib diisi';
                        }
                        final parsed = double.tryParse(value);
                        if (parsed == null || parsed <= 0) {
                          return 'Nominal tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    ElevatedButton(
                      onPressed: _submitWithdrawal,
                      child: const Text('Tarik Saldo Rekening'),
                    ),

                    const SizedBox(height: 36),

                    // Riwayat Pengajuan Withdrawal
                    const Text(
                      'Riwayat Pengajuan Penarikan',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),

                    walletProvider.withdrawals.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Text('Belum ada riwayat penarikan.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: walletProvider.withdrawals.length,
                            itemBuilder: (context, index) {
                              final wd = walletProvider.withdrawals[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${wd.bankName} - ${wd.accountNumber}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getWdBg(wd.status),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              _getWdLabel(wd.status),
                                              style: TextStyle(
                                                color: _getWdColor(wd.status),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Atas Nama: ${wd.accountName}',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            wd.createdAt.split('T').first,
                                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                                          ),
                                          Text(
                                            _currencyFormat.format(wd.amount),
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                                          ),
                                        ],
                                      ),
                                      if (wd.adminNotes != null && wd.adminNotes!.isNotEmpty) ...[
                                        const SizedBox(height: 10),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(10),
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
