<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\User;
use App\Models\OrderItem;
use App\Models\SellerAddress;
use App\Models\WasteCategory;
use App\Models\Wallet;
use App\Models\WalletTransaction;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;


class OrderController extends Controller
{
    private function createNotification(
        int $userId,
        string $title,
        string $message,
        array $data = []
    ): void {

        Notification::create([
            'user_id' =>
                $userId,

            'title' =>
                $title,

            'message' =>
                $message,

            'type' =>
                'ORDER',

            'data' =>
                $data,

            'is_read' =>
                false,
        ]);
    }

    /*GET ALL MY ORDERS*/
    public function index(Request $request)
    {
        $user = $request->user();

        $orders = Order::with([
            'items.wasteCategory',
            'sellerAddress',
            'courier',
            'seller'
        ])
            ->when($user->role_id == 3, function ($query) use ($user) {
                return $query->where('seller_id', $user->id);
            })
            ->when($user->role_id == 4, function ($query) use ($user) {
                return $query->where('courier_id', $user->id);
            })
            ->latest()
            ->get();

        return response()->json([

            'message' =>
                'Orders fetched successfully',

            'data' =>
                $orders
        ]);
    }

    /*AVAILABLE ORDERS FOR COURIER*/
    public function availableOrders(Request $request)
    {
        $user = $request->user();
        $courierProfile = $user->courierProfile;
        $courierVehicle = $courierProfile ? $courierProfile->vehicle_type : 'EcoRide';

        $orders = Order::with([
            'sellerAddress',
            'items.wasteCategory',
            'seller'
        ])
            ->where('status', 'PENDING')
            ->whereNull('courier_id')
            ->where(function ($query) use ($courierVehicle) {
                $isCargo = str_contains(strtolower($courierVehicle), 'mobil') || str_contains(strtolower($courierVehicle), 'cargo');
                if ($isCargo) {
                    $query->where('vehicle_type', 'EcoCargo');
                } else {
                    $query->where('vehicle_type', 'EcoRide');
                }
            })
            ->latest()
            ->get();

        return response()->json([
            'message' =>
                'Available orders fetched successfully',

            'data' => $orders
        ]);
    }

    /*SHOW DETAIL*/
    public function show(
        Request $request,
        string $id
    ) {
        $user = $request->user();

        $order = Order::with([
            'items.wasteCategory',
            'sellerAddress',
            'courier',
            'seller'
        ])
            ->when($user->role_id == 3, function ($query) use ($user) {
                return $query->where('seller_id', $user->id);
            })
            ->when($user->role_id == 4, function ($query) use ($user) {
                return $query->where('courier_id', $user->id);
            })
            ->find($id);

        if (!$order) {

            return response()->json([
                'message' =>
                    'Order not found'
            ], 404);
        }

        return response()->json([

            'message' =>
                'Order fetched successfully',

            'data' =>
                $order
        ]);
    }

    /*CREATE ORDER*/
    public function store(Request $request)
    {
        $validated = $request->validate([
            'seller_address_id' =>
                'required|exists:seller_addresses,id',

            'vehicle_type' =>
                'required|string|in:EcoRide,EcoCargo',

            'pickup_notes' =>
                'nullable|string',

            'latitude' =>
                'required|numeric',

            'longitude' =>
                'required|numeric',

            'items' =>
                'required|array|min:1',

            'items.*.waste_category_id' =>
                'required|exists:waste_categories,id',

            'items.*.estimated_weight' =>
                'required|numeric|min:0.1',
        ]);

        $address = SellerAddress::where(
            'seller_id',
            $request->user()->id
        )->findOrFail(
                $validated['seller_address_id']
            );

        // CHECK ACTIVE SELLER ORDER (ANTI-SPAM DISABLED)
        // Seller can now have multiple active orders to support large garbage volumes.

        //CHECK AVAILABLE COURIER WITH MATCHING VEHICLE TYPE
        $availableCourier = User::whereHas(
            'role',
            function ($query) {
                $query->where(
                    'name',
                    'COURIER'
                );
            }
        )
            ->whereHas('courierProfile', function ($query) use ($validated) {
                if ($validated['vehicle_type'] === 'EcoRide') {
                    $query->whereRaw('LOWER(vehicle_type) not like ?', ['%mobil%'])
                          ->whereRaw('LOWER(vehicle_type) not like ?', ['%cargo%']);
                } else {
                    $query->where(function ($q) {
                        $q->whereRaw('LOWER(vehicle_type) like ?', ['%mobil%'])
                          ->orWhereRaw('LOWER(vehicle_type) like ?', ['%cargo%']);
                    });
                }
            })
            ->where('is_active', true)
            ->where('is_online', true)
            ->exists();

        if (!$availableCourier) {
            $vehicleLabel = $validated['vehicle_type'] === 'EcoCargo' ? 'EcoCargo' : 'EcoRide';
            return response()->json([
                'message' =>
                    "Tidak ada kurir dengan kendaraan {$vehicleLabel} tersedia saat ini"
            ], 422);
        }

        DB::beginTransaction();

        try {

            $nextId = (\App\Models\Order::max('id') ?? 0) + 1;
            $orderCode =
                'ORD-' .
                str_pad(
                    $nextId,
                    5,
                    '0',
                    STR_PAD_LEFT
                );

            $estimatedTotalWeight = 0;
            $estimatedTotalPrice = 0;

            $order = Order::create([
                'order_code' => $orderCode,
                'seller_id' =>
                    $request->user()->id,

                'seller_address_id' =>
                    $address->id,

                'status' => 'PENDING',
                'vehicle_type' =>
                    $validated['vehicle_type'],

                'pickup_notes' =>
                    $validated['pickup_notes']
                    ?? null,

                'latitude' =>
                    $validated['latitude'],

                'longitude' =>
                    $validated['longitude'],

                'estimated_total_weight' => 0,
                'actual_total_weight' => 0,
                'estimated_total_price' => 0,
                'total_price' => 0,
            ]);

            foreach (
                $validated['items']
                as $item
            ) {

                $category =
                    WasteCategory::findOrFail(
                        $item[
                            'waste_category_id'
                        ]
                    );

                $subtotal =
                    $category->price_per_kg *
                    $item[
                        'estimated_weight'
                    ];

                OrderItem::create([
                    'order_id' =>
                        $order->id,

                    'waste_category_id' =>
                        $category->id,

                    'estimated_weight' =>
                        $item[
                            'estimated_weight'
                        ],

                    'actual_weight' => 0,

                    'price_per_kg' =>
                        $category->price_per_kg,

                    'subtotal' =>
                        $subtotal,
                ]);

                $estimatedTotalWeight +=
                    $item[
                        'estimated_weight'
                    ];

                $estimatedTotalPrice +=
                    $subtotal;
            }

            $order->update([
                'estimated_total_weight' =>
                    $estimatedTotalWeight,

                'estimated_total_price' =>
                    $estimatedTotalPrice,
            ]);

            DB::commit();

            return response()->json([
                'message' =>
                    'Order created successfully',

                'data' =>
                    $order->load([
                        'items.wasteCategory',
                        'sellerAddress'
                    ])
            ], 201);

        } catch (\Exception $e) {

            DB::rollBack();

            return response()->json([
                'message' =>
                    'Failed to create order',

                'error' =>
                    $e->getMessage()
            ], 500);
        }
    }

    public function cancel(
        Request $request,
        string $id
    ) {

        $validated = $request->validate([
            'cancel_reason' =>
                'required|string|max:255'
        ]);

        DB::beginTransaction();

        try {

            $user = $request->user();

            $order = Order::find($id);

            if (!$order) {

                DB::rollBack();

                return response()->json([
                    'message' =>
                        'Order not found'
                ], 404);
            }

            //SELLER CANCEL
            if ($user->role_id == 3) {

                if (
                    $order->seller_id !=
                    $user->id
                ) {

                    DB::rollBack();

                    return response()->json([
                        'message' =>
                            'Order tidak ditemukan'
                    ], 404);
                }

                if (
                    $order->status !==
                    'PENDING'
                ) {

                    DB::rollBack();

                    return response()->json([
                        'message' =>
                            'Order tidak dapat dibatalkan'
                    ], 422);
                }
            }

            //COURIER CANCEL
            if ($user->role_id == 4) {

                if (
                    $order->courier_id !=
                    $user->id
                ) {

                    DB::rollBack();

                    return response()->json([
                        'message' =>
                            'Order tidak ditemukan'
                    ], 404);
                }

                if (
                    !in_array(
                        $order->status,
                        [
                            'ACCEPTED',
                            'PICKED_UP'
                        ]
                    )
                ) {

                    DB::rollBack();

                    return response()->json([
                        'message' =>
                            'Order tidak dapat dibatalkan'
                    ], 422);
                }
            }

            $order->update([

                'status' =>
                    $user->role_id == 4
                    ? 'PENDING'
                    : 'CANCELLED',

                'courier_id' =>
                    $user->role_id == 4
                    ? null
                    : $order->courier_id,

                'cancel_reason' =>
                    $validated['cancel_reason'],

                'cancelled_at' =>
                    $user->role_id == 4
                    ? null
                    : now(),
            ]);

            if ($user->role_id == 4) {

                $this->createNotification(
                    $order->seller_id,
                    'Order Cancelled',
                    'Order dibatalkan courier',
                    [
                        'order_id' =>
                            $order->id,

                        'status' =>
                            'CANCELLED'
                    ]
                );
            }

            DB::commit();

            return response()->json([
                'message' =>
                    'Order cancelled successfully',

                'data' =>
                    $order->fresh()->load([
                        'seller',
                        'courier',
                        'items.wasteCategory',
                        'sellerAddress'
                    ])
            ]);

        } catch (\Exception $e) {

            DB::rollBack();

            return response()->json([
                'message' =>
                    'Failed to cancel order',

                'error' =>
                    $e->getMessage()
            ], 500);
        }
    }

    public function accept(
        Request $request,
        string $id
    ) {
        //COURIER ACTIVE CHECK
        if (
            !$request->user()
                ->is_active
        ) {

            return response()->json([
                'message' =>
                    'Courier account inactive'
            ], 403);
        }

        //CHECK ACTIVE COURIER ORDER
        $hasActiveOrder = Order::where(
            'courier_id',
            $request->user()->id
        )
            ->whereIn('status', [
                'ACCEPTED',
                'PICKED_UP',
                'DELIVERED'
            ])
            ->exists();

        if ($hasActiveOrder) {

            return response()->json([
                'message' =>
                    'Anda masih menangani order lain'
            ], 422);
        }

        $order = Order::lockForUpdate()
            ->where('id', $id)
            ->first();

        if (!$order) {

            return response()->json([
                'message' =>
                    'Order not found'
            ], 404);
        }

        if ($order->status !== 'PENDING') {

            return response()->json([
                'message' =>
                    'Order sudah diambil kurir lain'
            ], 422);
        }

        // Validate vehicle type match
        $courierProfile = $request->user()->courierProfile;
        $courierVehicle = $courierProfile ? $courierProfile->vehicle_type : 'EcoRide';
        $isCargoCourier = str_contains(strtolower($courierVehicle), 'mobil') || str_contains(strtolower($courierVehicle), 'cargo');
        $isCargoOrder = $order->vehicle_type === 'EcoCargo';

        if ($isCargoCourier !== $isCargoOrder) {
            return response()->json([
                'message' => 'Kendaraan Anda tidak cocok untuk penjemputan pesanan ini'
            ], 422);
        }

        $order->update([
            'courier_id' =>
                $request->user()->id,

            'status' =>
                'ACCEPTED',
        ]);

        $this->createNotification(
            $order->seller_id,
            'Order Accepted',
            'Pesanan kamu diterima courier',
            [
                'order_id' =>
                    $order->id,

                'status' =>
                    'ACCEPTED'
            ]
        );

        return response()->json([
            'message' =>
                'Order accepted successfully',

            'data' => $order->load([
                'seller',
                'courier',
                'items.wasteCategory',
                'sellerAddress'
            ])
        ]);
    }

    public function pickup(
        Request $request,
        string $id
    ) {
        try {

            $order = Order::where(
                'courier_id',
                $request->user()->id
            )
                ->where(
                    'status',
                    'ACCEPTED'
                )
                ->find($id);

            if (!$order) {

                return response()->json([
                    'message' =>
                        'Order not found'
                ], 404);
            }

            $validated = $request->validate([
                'pickup_photo' =>
                    'required|image|mimes:jpg,jpeg,png,webp|max:5120'
            ], [
                'pickup_photo.required' => 'Foto bukti penjemputan wajib diunggah.',
                'pickup_photo.image' => 'File yang diunggah harus berupa gambar.',
                'pickup_photo.mimes' => 'Format gambar harus berupa jpg, jpeg, png, atau webp.',
                'pickup_photo.max' => 'Ukuran foto tidak boleh lebih dari 5 MB.',
            ]);

            $photoPath = null;

            if (
                $request->hasFile(
                    'pickup_photo'
                )
            ) {

                $photoPath =
                    $request
                        ->file(
                            'pickup_photo'
                        )
                        ->store(
                            'pickup',
                            'public'
                        );
            }

            $order->update([
                'status' =>
                    'PICKED_UP',

                'pickup_photo' =>
                    $photoPath,

                'picked_up_at' =>
                    now(),
            ]);

            $this->createNotification(
                $order->seller_id,
                'Order Picked Up',
                'Courier sedang mengambil sampahmu',
                [
                    'order_id' =>
                        $order->id,

                    'status' =>
                        'PICKED_UP'
                ]
            );

            return response()->json([
                'message' =>
                    'Order picked up successfully',

                'data' =>
                    $order->fresh()->load([
                        'seller',
                        'courier',
                        'items.wasteCategory',
                        'sellerAddress'
                    ])
            ]);

        } catch (\Illuminate\Validation\ValidationException $e) {
            \Log::info('Validation failed during pickup: ' . json_encode($e->errors()));

            return response()->json([
                'message' =>
                    $e->validator->errors()->first(),

                'errors' =>
                    $e->errors(),

                'error' =>
                    $e->getMessage()
            ], 422);

        } catch (\Exception $e) {

            return response()->json([
                'message' =>
                    'Failed to pickup order',

                'error' =>
                    $e->getMessage()
            ], 500);
        }
    }

    public function deliver(
        Request $request,
        string $id
    ) {
        $order = Order::where(
            'courier_id',
            $request->user()->id
        )
            ->where(
                'status',
                'PICKED_UP'
            )
            ->find($id);

        if (!$order) {

            return response()->json([
                'message' =>
                    'Order not found'
            ], 404);
        }

        $order->update([
            'status' =>
                'DELIVERED',

            'delivered_at' =>
                now(),
        ]);

        $this->createNotification(
            $order->seller_id,
            'Order Delivered',
            'Pesanan berhasil dikirim ke gudang',
            [
                'order_id' =>
                    $order->id,

                'status' =>
                    'DELIVERED'
            ]
        );

        return response()->json([
            'message' =>
                'Order delivered successfully',

            'data' => $order->load([
                'seller',
                'courier',
                'items.wasteCategory',
                'sellerAddress'
            ])
        ]);
    }

    public function complete(
        Request $request,
        string $id
    ) {
        $validated = $request->validate([
            'items' =>
                'required|array|min:1',

            'items.*.order_item_id' =>
                'required|exists:order_items,id',

            'items.*.actual_weight' =>
                'required|numeric|min:0.1|max:100',
        ]);

        DB::beginTransaction();

        try {

            $order = Order::with([
                'items',
                'seller'
            ])
                ->where(
                    'courier_id',
                    $request->user()->id
                )
                ->where(
                    'status',
                    'DELIVERED'
                )
                ->find($id);

            if (!$order) {

                return response()->json([
                    'message' =>
                        'Order not found'
                ], 404);
            }

            $actualTotalWeight = 0;
            $totalPrice = 0;

            foreach (
                $validated['items']
                as $item
            ) {

                $orderItem =
                    OrderItem::with(
                        'wasteCategory'
                    )
                        ->where(
                            'order_id',
                            $order->id
                        )
                        ->findOrFail(
                            $item['order_item_id']
                        );

                $subtotal =
                    $orderItem
                        ->wasteCategory
                        ->price_per_kg
                    *
                    $item[
                        'actual_weight'
                    ];

                $orderItem->update([
                    'actual_weight' =>
                        $item[
                            'actual_weight'
                        ],

                    'subtotal' =>
                        $subtotal,
                ]);

                $actualTotalWeight +=
                    $item[
                        'actual_weight'
                    ];

                $totalPrice +=
                    $subtotal;
            }

            if ($totalPrice <= 0) {

                DB::rollBack();

                return response()->json([
                    'message' =>
                        'Invalid total price'
                ], 422);
            }

            $order->update([
                'status' =>
                    'COMPLETED',

                'actual_total_weight' =>
                    $actualTotalWeight,

                'total_price' =>
                    $totalPrice,

                'completed_at' =>
                    now(),
            ]);

            $this->createNotification(
                $order->seller_id,
                'Order Completed',
                'Pesanan selesai dan saldo wallet telah masuk',
                [
                    'order_id' =>
                        $order->id,

                    'status' =>
                        'COMPLETED',

                    'amount' =>
                        $totalPrice
                ]
            );

            $wallet =
                Wallet::firstOrCreate([
                    'user_id' =>
                        $order
                            ->seller_id
                ]);

            $wallet->increment(
                'balance',
                $totalPrice
            );

            WalletTransaction::create([
                'wallet_id' => $wallet->id,

                'type' => 'CREDIT',

                'amount' => $totalPrice,

                'description' =>
                    'Income from order ' .
                    $order->order_code,

                'status' => 'SUCCESS',

                'reference_order_id' =>
                    $order->id,
            ]);

            DB::commit();

            return response()->json([
                'message' =>
                    'Order completed successfully',

                'data' =>
                    $order->fresh()->load([
                        'items.wasteCategory',
                        'seller',
                        'courier',
                        'sellerAddress'
                    ])
            ]);

        } catch (\Exception $e) {

            DB::rollBack();

            return response()->json([
                'message' =>
                    'Failed to complete order',

                'error' =>
                    $e->getMessage()
            ], 500);
        }
    }

    public function map(
        Request $request,
        string $id
    ) {

        $user =
            $request->user();

        $order =
            Order::with([
                'sellerAddress',
                'courier.courierProfile'
            ])
                ->find($id);

        if (!$order) {

            return response()->json([
                'message' =>
                    'Order not found'
            ], 404);
        }

        //ACCESS CONTROL
        if (

            $user->role_id == 3 &&
            $order->seller_id != $user->id

        ) {

            return response()->json([
                'message' =>
                    'Order not found'
            ], 404);
        }

        if (

            $user->role_id == 4 &&
            $order->courier_id != $user->id

        ) {

            return response()->json([
                'message' =>
                    'Order not found'
            ], 404);
        }

        return response()->json([

            'message' =>
                'Map data fetched successfully',

            'data' => [

                'order_id' =>
                    $order->id,

                'status' =>
                    $order->status,

                'seller_location' => [

                    'latitude' =>
                        $order
                            ->sellerAddress
                                ?->latitude,

                    'longitude' =>
                        $order
                            ->sellerAddress
                                ?->longitude,
                ],

                'courier_location' => [

                    'latitude' =>
                        $order
                            ->courier
                            ?->courierProfile
                                ?->current_latitude,

                    'longitude' =>
                        $order
                            ->courier
                            ?->courierProfile
                                ?->current_longitude,
                ],
            ]
        ]);
    }

}