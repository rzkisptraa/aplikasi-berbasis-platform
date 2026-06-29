<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Wallet;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Withdrawal;
use App\Models\SellerAddress;
use App\Models\WasteCategory;
use App\Models\CourierProfile;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;

class DemoDataSeeder extends Seeder
{
    public function run(): void
    {
        $this->seedSellerAddresses();

        $this->seedWallets();

        $this->seedCourierProfiles();

        $this->seedOrders();

        $this->seedWithdrawals();
    }

    /* SELLER ADDRESS */
    private function seedSellerAddresses(): void
    {
        $sellers = User::where('role_id', 3)->get();

        $bandungLocations = [

            [
                'label' => 'Rumah',
                'address' => 'Jl Demo Seller Bandung',
                'latitude' => -6.9175000,
                'longitude' => 107.6191000,
            ],

            [
                'label' => 'Rumah',
                'address' => 'Jl Buah Batu Bandung',
                'latitude' => -6.9386000,
                'longitude' => 107.6330000,
            ],

            [
                'label' => 'Rumah',
                'address' => 'Jl Antapani Bandung',
                'latitude' => -6.9147000,
                'longitude' => 107.6607000,
            ],

            [
                'label' => 'Rumah',
                'address' => 'Jl Cibiru Bandung',
                'latitude' => -6.9259000,
                'longitude' => 107.7170000,
            ],

            [
                'label' => 'Rumah',
                'address' => 'Jl Kopo Bandung',
                'latitude' => -6.9468000,
                'longitude' => 107.5730000,
            ],
        ];

        foreach ($sellers as $index => $seller) {

            $location = $bandungLocations[$index];

            SellerAddress::updateOrCreate(
                [
                    'seller_id' => $seller->id,
                ],
                [
                    'label' => $location['label'],
                    'address' => $location['address'],
                    'latitude' => $location['latitude'],
                    'longitude' => $location['longitude'],
                    'is_default' => true,
                ]
            );
        }
    }

    /*WALLET*/

    private function seedWallets(): void
    {
        $sellers = User::where('role_id', 3)->get();

        $balances = [
            79841,
            87143,
            87516,
            43500,
            125000,
        ];

        foreach ($sellers as $index => $seller) {

            Wallet::updateOrCreate(
                [
                    'user_id' => $seller->id,
                ],
                [
                    'balance' => $balances[$index],
                ]
            );
        }
    }

    /* COURIER PROFILE */

    private function seedCourierProfiles(): void
    {
        $couriers = User::where('role_id', 4)->get();

        $profiles = [

            [
                'vehicle_type' => 'EcoRide',
                'vehicle_plate' => 'D7330ABC',
            ],

            [
                'vehicle_type' => 'EcoRide',
                'vehicle_plate' => 'D7302ABC',
            ],

            [
                'vehicle_type' => 'EcoCargo',
                'vehicle_plate' => 'D5709ABC',
            ],

            [
                'vehicle_type' => 'EcoCargo',
                'vehicle_plate' => 'D5453ABC',
            ],

            [
                'vehicle_type' => 'EcoRide',
                'vehicle_plate' => 'D1234ABC',
            ],

            [
                'vehicle_type' => 'EcoRide',
                'vehicle_plate' => 'D9999BUB',
            ],
        ];

        $ktpImages = ['ktp.jpg', 'ktp2.jpg', 'ktp3.jpg', 'ktp4.jpg', 'ktp5.jpg', 'ktp6.jpg'];
        $simImages = ['sim.jpg', 'sim2.jpg', 'sim3.jpg', 'sim4.jpg', 'sim5.jpg', 'sim6.jpg'];
        $selfieImages = ['selfie.jpg', 'selfie2.jpg', 'selfie3.jpg', 'selfie4.jpg', 'selfie5.jpg', 'selfie6.jpg'];

        foreach ($couriers as $index => $courier) {

            $profile = $profiles[$index];

            CourierProfile::updateOrCreate(
                [
                    'user_id' => $courier->id,
                ],
                [
                    'vehicle_type' => $profile['vehicle_type'],
                    'vehicle_plate' => $profile['vehicle_plate'],

                    'ktp_number' => '3201' . rand(100000000000, 999999999999),
                    'sim_number' => 'SIM' . rand(1000000, 9999999),

                    'ktp_photo' =>
                        'couriers/ktp/' . $ktpImages[$index],

                    'sim_photo' =>
                        'couriers/sim/' . $simImages[$index],

                    'face_photo' =>
                        'couriers/selfie/' . $selfieImages[$index],

                    'address' => 'Bandung',
                    'city' => 'Bandung',
                    'province' => 'Jawa Barat',

                    'rating' => 0.0,

                    'is_verified' => true,

                    'current_latitude' => -6.9175000,
                    'current_longitude' => 107.6191000,
                ]
            );
        }
    }

    /*ORDERS*/

    private function seedOrders(): void
    {
        $sellers = User::where('role_id', 3)->get();

        $couriers = User::where('role_id', 4)->get()->values();

        $categories =
            WasteCategory::all();

        $pickupPhotos = [];
        for ($i = 1; $i <= 20; $i++) {
            $pickupPhotos[] = 'pickup/pickup' . $i . '.jpg';
        }

        $statuses = [
            'PENDING',
            'PENDING',
            'PENDING',
            'PENDING',

            'ACCEPTED',
            'ACCEPTED',
            'ACCEPTED',
            'ACCEPTED',

            'PICKED_UP',
            'PICKED_UP',
            'PICKED_UP',
            'PICKED_UP',

            'DELIVERED',
            'DELIVERED',
            'DELIVERED',

            'COMPLETED',
            'COMPLETED',
            'COMPLETED',
            'COMPLETED',
            'COMPLETED',
        ];

        $completedCount = 0;

        foreach ($statuses as $index => $status) {

            $seller =
                $sellers->random();

            $address =
                SellerAddress::where(
                    'seller_id',
                    $seller->id
                )->first();

            $estimatedWeight =
                rand(5, 45); // Generate some weights above 30 kg for Mobil

            $vehicleType = $estimatedWeight > 30 ? 'EcoCargo' : 'EcoRide';

            // Filter couriers to match vehicle type
            $matchingCouriers = $couriers->filter(function ($c) use ($vehicleType) {
                $profile = \App\Models\CourierProfile::where('user_id', $c->id)->first();
                $cVehicleType = $profile ? $profile->vehicle_type : 'EcoRide';
                return str_contains(strtolower($cVehicleType), strtolower($vehicleType));
            });

            if ($matchingCouriers->isEmpty()) {
                $matchingCouriers = $couriers;
            }

            $courier = $matchingCouriers->random();

            if ($status === 'COMPLETED') {
                $completedCount++;
            }

            $actualWeight =
                rand(5, 30);

            $estimatedPrice =
                rand(15000, 90000);

            $totalPrice =
                rand(15000, 90000);

            $createdAt =
                now()->subDays(20 - $index);

            $pickedUpAt = null;
            $deliveredAt = null;
            $completedAt = null;
            $cancelledAt = null;

            if (in_array(
                $status,
                [
                    'PICKED_UP',
                    'DELIVERED',
                    'COMPLETED'
                ]
            )) {
                $pickedUpAt =
                    (clone $createdAt)
                        ->addHours(rand(2, 18));
            }

            if (in_array(
                $status,
                [
                    'DELIVERED',
                    'COMPLETED'
                ]
            )) {
                $deliveredAt =
                    (clone $pickedUpAt)
                        ->addHours(rand(2, 18));
            }

            if ($status === 'COMPLETED') {
                $completedAt =
                    (clone $deliveredAt)
                        ->addHours(rand(2, 36));
            }

            if ($status === 'CANCELLED') {
                $cancelledAt =
                    (clone $createdAt)
                        ->addHours(rand(2, 24));
            }

            $order = Order::create([

                'order_code' =>
                    'ORD-' .
                    str_pad(
                        $index + 1,
                        5,
                        '0',
                        STR_PAD_LEFT
                    ),

                'seller_id' =>
                    $seller->id,

                'courier_id' =>
                    in_array(
                        $status,
                        [
                            'ACCEPTED',
                            'PICKED_UP',
                            'DELIVERED',
                            'COMPLETED'
                        ]
                    )
                    ? $courier->id
                    : null,

                'seller_address_id' =>
                    $address->id,

                'status' => $status,
                'vehicle_type' => $vehicleType,

                'pickup_photo' =>
                    in_array(
                        $status,
                        [
                            'PICKED_UP',
                            'DELIVERED',
                            'COMPLETED'
                        ]
                    )
                    ? $pickupPhotos[$index]
                    : null,

                'pickup_notes' =>
                    $status === 'CANCELLED'
                    ? null
                    : 'Pickup berjalan normal.',

                'cancel_reason' =>
                    $status === 'CANCELLED'
                    ? 'Seller membatalkan pesanan.'
                    : null,

                'latitude' =>
                    $address->latitude,

                'longitude' =>
                    $address->longitude,

                'estimated_total_weight' =>
                    $estimatedWeight,

                'actual_total_weight' =>
                    in_array(
                        $status,
                        [
                            'PICKED_UP',
                            'DELIVERED',
                            'COMPLETED'
                        ]
                    )
                    ? $actualWeight
                    : null,

                'estimated_total_price' =>
                    $estimatedPrice,

                'total_price' =>
                    in_array(
                        $status,
                        [
                            'DELIVERED',
                            'COMPLETED'
                        ]
                    )
                    ? $totalPrice
                    : 0,

                'picked_up_at' => $pickedUpAt,
                'delivered_at' => $deliveredAt,
                'completed_at' => $completedAt,
                'cancelled_at' => $cancelledAt,

                'created_at' => $createdAt,
                'updated_at' => $createdAt,
            ]);

            /* ORDER ITEMS */

            $total = 0;
            $estimatedSum = 0;
            $actualSum = 0;

            for ($i = 1; $i <= rand(1, 3); $i++) {

                $category =
                    $categories->random();

                $estimated =
                    rand(1, 10);

                $actual =
                    rand(1, 10);

                $subtotal =
                    $actual
                    * $category->price_per_kg;

                OrderItem::create([

                    'order_id' =>
                        $order->id,

                    'waste_category_id' =>
                        $category->id,

                    'estimated_weight' =>
                        $estimated,

                    'actual_weight' =>
                        in_array(
                            $status,
                            [
                                'PICKED_UP',
                                'DELIVERED',
                                'COMPLETED'
                            ]
                        )
                        ? $actual
                        : null,

                    'price_per_kg' =>
                        $category->price_per_kg,

                    'subtotal' =>
                        $subtotal,
                ]);

                $total += $subtotal;
                $estimatedSum += $estimated;
                $actualSum += in_array(
                    $status,
                    [
                        'PICKED_UP',
                        'DELIVERED',
                        'COMPLETED'
                    ]
                ) ? $actual : 0;
            }

            $updates = [
                'estimated_total_weight' => $estimatedSum ?: $order->estimated_total_weight,
            ];

            if (in_array($status, ['PICKED_UP', 'DELIVERED', 'COMPLETED'])) {
                $updates['actual_total_weight'] = $actualSum ?: $order->actual_total_weight;
            } else {
                $updates['actual_total_weight'] = null;
            }

            if (in_array($status, ['DELIVERED', 'COMPLETED'])) {
                $updates['total_price'] = $total;
            } else {
                $updates['total_price'] = 0;
            }

            $order->update($updates);
        }
    }

    /* WITHDRAWALS */

    private function seedWithdrawals(): void
    {
        $sellers =
            User::where(
                'role_id',
                3
            )->get();

        $statuses = [

            'PENDING',
            'APPROVED',
            'PAID',
            'REJECTED',
            'PAID',
        ];

        foreach (
            $statuses
            as $index => $status
        ) {

            Withdrawal::create([

                'user_id' =>
                    $sellers->random()->id,

                'bank_name' =>
                    'BCA',

                'account_name' =>
                    'Seller Demo',

                'account_number' =>
                    '1234567890',

                'amount' =>
                    rand(
                        30000,
                        250000
                    ),

                'status' =>
                    $status,

                'admin_notes' =>
                    match ($status) {

                        'REJECTED'
                        =>
                        'Nomor rekening tidak valid.',

                        'APPROVED'
                        =>
                        'Menunggu transfer.',

                        'PAID'
                        =>
                        'Dana berhasil ditransfer.',

                        default
                        => null
                    },

                'processed_at' =>
                    in_array(
                        $status,
                        [
                            'APPROVED',
                            'PAID',
                            'REJECTED'
                        ]
                    )
                    ? now()
                    : null,
            ]);
        }
    }
}

