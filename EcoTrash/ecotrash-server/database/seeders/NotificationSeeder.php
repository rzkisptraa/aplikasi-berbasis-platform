<?php

namespace Database\Seeders;

use App\Models\Notification;
use App\Models\User;
use App\Models\Order;
use Illuminate\Database\Seeder;

class NotificationSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Fetch some users
        $sellers = User::where('role_id', 3)->get();
        $couriers = User::where('role_id', 4)->get();
        $orders = Order::all();

        if ($sellers->isEmpty() || $orders->isEmpty()) {
            return;
        }

        $notificationCount = 0;

        // Create sample notifications for sellers
        foreach ($sellers as $seller) {
            $sellerOrders = $orders->where('seller_id', $seller->id);
            if ($sellerOrders->isEmpty()) {
                continue;
            }

            // Unread notification
            $order = $sellerOrders->first();
            Notification::create([
                'user_id' => $seller->id,
                'title' => 'Pesanan Diterima Kurir',
                'message' => "Pesanan Anda {$order->order_code} telah diterima oleh kurir.",
                'type' => 'ORDER',
                'is_read' => false,
                'data' => [
                    'order_id' => $order->id,
                    'status' => 'ACCEPTED'
                ],
                'created_at' => now()->subMinutes(15),
            ]);

            // Read notification
            $order2 = $sellerOrders->last();
            Notification::create([
                'user_id' => $seller->id,
                'title' => 'Penjemputan Selesai',
                'message' => "Sampah pada pesanan {$order2->order_code} telah berhasil dijemput.",
                'type' => 'ORDER',
                'is_read' => true,
                'data' => [
                    'order_id' => $order2->id,
                    'status' => 'PICKED_UP'
                ],
                'created_at' => now()->subHours(2),
                'read_at' => now()->subHours(1),
            ]);

            $notificationCount += 2;
        }

        // Create sample notifications for couriers
        foreach ($couriers as $courier) {
            $courierOrders = $orders->where('courier_id', $courier->id);
            if ($courierOrders->isEmpty()) {
                continue;
            }

            $order = $courierOrders->first();
            Notification::create([
                'user_id' => $courier->id,
                'title' => 'Tugas Penjemputan Baru',
                'message' => "Anda mendapat tugas baru untuk menjemput sampah pada pesanan {$order->order_code}.",
                'type' => 'ORDER',
                'is_read' => false,
                'data' => [
                    'order_id' => $order->id,
                    'status' => 'ACCEPTED'
                ],
                'created_at' => now()->subMinutes(30),
            ]);

            $notificationCount++;
        }

        $this->command->info("✅ Created {$notificationCount} sample notifications.");
    }
}
