import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../orders/providers/seller_order_provider.dart';

class ReviewCourierDialog extends StatefulWidget {
  final int orderId;
  final int courierId;
  final String courierName;

  const ReviewCourierDialog({
    super.key,
    required this.orderId,
    required this.courierId,
    required this.courierName,
  });

  @override
  State<ReviewCourierDialog> createState() => _ReviewCourierDialogState();
}

class _ReviewCourierDialogState extends State<ReviewCourierDialog> {
  int _selectedRating = 5;
  final TextEditingController _commentController = TextEditingController();

  Future<void> _submit() async {
    try {
      final orderProvider = context.read<SellerOrderProvider>();
      await orderProvider.submitReview(
        orderId: widget.orderId,
        courierId: widget.courierId,
        rating: _selectedRating,
        comment: _commentController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terima kasih! Ulasan berhasil dikirim.'),
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
    final orderProvider = context.watch<SellerOrderProvider>();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Column(
        children: [
          const Icon(Icons.rate_review, color: Colors.green, size: 40),
          const SizedBox(height: 12),
          Text(
            'Ulas Kurir ${widget.courierName}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Bagaimana pengalaman penjemputan sampah oleh kurir kami? Berikan penilaian Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            
            // Interactive 5 Star Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starVal = index + 1;
                final isSel = _selectedRating >= starVal;
                return IconButton(
                  iconSize: 36,
                  icon: Icon(
                    isSel ? Icons.star_rounded : Icons.star_border_rounded,
                    color: isSel ? Colors.orange : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedRating = starVal;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            
            // Comment input box
            TextField(
              controller: _commentController,
              maxLines: 3,
              maxLength: 200,
              decoration: const InputDecoration(
                labelText: 'Komentar Ulasan',
                hintText: 'Tulis tanggapan Anda mengenai kurir (sopan, cepat, dll)...',
              ),
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
            minimumSize: const Size(120, 44),
            backgroundColor: Colors.green,
          ),
          onPressed: orderProvider.isLoading ? null : _submit,
          child: orderProvider.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('Kirim Ulasan'),
        ),
      ],
    );
  }
}
