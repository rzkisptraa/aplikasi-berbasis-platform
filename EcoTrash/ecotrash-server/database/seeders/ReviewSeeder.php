<?php

namespace Database\Seeders;

use App\Models\Review;
use App\Models\Order;
use App\Models\User;
use Illuminate\Database\Seeder;

class ReviewSeeder extends Seeder
{
    /**
     * Seed reviews untuk COMPLETED orders.
     * Rating akan otomatis diupdate ke courier_profile.rating
     * berdasarkan ReviewController logic.
     */
    public function run(): void
    {
        // Get all COMPLETED orders
        $completedOrders = Order::where('status', 'COMPLETED')
            ->with('seller', 'courier')
            ->get();

        if ($completedOrders->isEmpty()) {
            $this->command->info('No completed orders found to create reviews.');
            return;
        }

        $reviewCount = 0;

        foreach ($completedOrders as $order) {
            // Skip if order doesn't have seller and courier
            if (!$order->seller || !$order->courier) {
                continue;
            }

            // Check if review already exists
            $existingReview = Review::where(
                'order_id',
                $order->id
            )->exists();

            if ($existingReview) {
                continue;
            }

            // Create review
            Review::create([
                'seller_id' => $order->seller->id,
                'courier_id' => $order->courier->id,
                'order_id' => $order->id,
                'rating' => $this->getReviewRating($order->courier),
                'comment' => $this->getRandomComment(),
            ]);

            // Update courier rating and performance based on ReviewController logic
            $this->updateCourierMetrics($order->courier->id);

            $reviewCount++;
        }

        $this->command->info("✅ Created {$reviewCount} reviews for completed orders.");
    }

    /**
     * Get a realistic review rating for demo data based on courier.
     */
    private function getReviewRating($courier): int
    {
        if (str_contains($courier->email, 'courier1')) {
            return 5;
        }
        if (str_contains($courier->email, 'courier3')) {
            return 4;
        }
        return rand(4, 5);
    }

    /**
     * Get random comment for review.
     */
    private function getRandomComment(): string
    {
        $comments = [
            'Kurir sangat profesional dan tepat waktu.',
            'Pengambilan sampah rapi dan cepat.',
            'Pelayanan yang memuaskan, terima kasih.',
            'Kurir ramah dan penuh tanggung jawab.',
            'Sampah tertangani dengan baik.',
            'Proses pickup sangat lancar.',
            'Sangat puas dengan layanannya.',
            'Kurir dapat diandalkan.',
        ];

        return $comments[array_rand($comments)];
    }

    /**
     * Update courier rating and performance score based on review data.
     */
    private function updateCourierMetrics($courierId): void
    {
        $courier = User::where('role_id', 4)
            ->where('id', $courierId)
            ->first();

        if (!$courier || !$courier->courierProfile) {
            return;
        }

        $avgRating = Review::where(
            'courier_id',
            $courierId
        )->avg('rating');

        $courier->courierProfile->update([
            'rating' => round($avgRating, 2),
        ]);
    }
}
