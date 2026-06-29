import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/seller_notification_provider.dart';

class SellerNotificationsScreen extends StatefulWidget {
  const SellerNotificationsScreen({super.key});

  @override
  State<SellerNotificationsScreen> createState() => _SellerNotificationsScreenState();
}

class _SellerNotificationsScreenState extends State<SellerNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SellerNotificationProvider>().fetchNotifications();
    });
  }

  Future<void> _refresh() async {
    await context.read<SellerNotificationProvider>().fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SellerNotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          if (provider.notifications.any((n) => !n.isRead))
            TextButton.icon(
              icon: const Icon(Icons.mark_email_read, size: 18),
              label: const Text('Baca Semua'),
              onPressed: () async {
                await provider.markAllAsRead();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Semua notifikasi ditandai terbaca')),
                  );
                }
              },
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: provider.notifications.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_none, size: 64, color: Colors.grey.withOpacity(0.4)),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum ada notifikasi.',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: provider.notifications.length,
                      itemBuilder: (context, index) {
                        final notif = provider.notifications[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          color: notif.isRead ? Colors.white : const Color(0xFFE8F5E9),
                          child: ListTile(
                            onTap: () {
                              if (!notif.isRead) {
                                provider.markAsRead(notif.id);
                              }
                            },
                            contentPadding: const EdgeInsets.all(12),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: notif.isRead ? Colors.grey.withOpacity(0.12) : Colors.green.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                notif.isRead ? Icons.notifications_none : Icons.notifications_active,
                                color: notif.isRead ? Colors.grey : Colors.green,
                              ),
                            ),
                            title: Text(
                              notif.title,
                              style: TextStyle(
                                fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  notif.message,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: notif.isRead ? Colors.grey : Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  notif.createdAt.split('T').first + ' ' + (notif.createdAt.split('T').length > 1 ? notif.createdAt.split('T')[1].substring(0, 5) : ''),
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              ],
                            ),
                            trailing: !notif.isRead
                                ? const CircleAvatar(
                                    radius: 5,
                                    backgroundColor: Colors.green,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}