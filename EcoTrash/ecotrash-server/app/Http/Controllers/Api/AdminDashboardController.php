<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\User;
use App\Models\Withdrawal;
use App\Models\WalletTransaction;
use App\Models\CourierProfile;

class AdminDashboardController extends Controller
{
    public function index()
    {
        /*REVENUE*/
        $totalRevenue =
            Order::where(
                'status',
                'COMPLETED'
            )
                ->sum(
                    'total_price'
                );

        $todayRevenue =
            Order::where(
                'status',
                'COMPLETED'
            )
                ->whereDate(
                    'completed_at',
                    today()
                )
                ->sum(
                    'total_price'
                );

        /*WALLET PAYOUT*/
        $totalWalletPayout =
            WalletTransaction::where(
                'type',
                'DEBIT'
            )
                ->sum(
                    'amount'
                );

        /*COURIER RATING*/
        $avgCourierRating =
            CourierProfile::where(
                'rating',
                '>',
                0
            )
                ->avg(
                    'rating'
                );

        return response()->json([

            'message' =>
                'Dashboard fetched successfully',

            'data' => [

                // USER
                'total_users' =>
                    User::count(),

                'total_sellers' =>
                    User::where(
                        'role_id',
                        3
                    )->count(),

                'total_couriers' =>
                    User::where(
                        'role_id',
                        4
                    )->count(),

                'active_couriers' =>
                    User::where(
                        'role_id',
                        4
                    )
                        ->where(
                            'is_online',
                            true
                        )
                        ->count(),

                // ORDER
                'total_orders' =>
                    Order::count(),

                'completed_orders' =>
                    Order::where(
                        'status',
                        'COMPLETED'
                    )->count(),

                'pending_orders' =>
                    Order::where(
                        'status',
                        'PENDING'
                    )->count(),

                'cancelled_orders' =>
                    Order::where(
                        'status',
                        'CANCELLED'
                    )->count(),

                'today_orders' =>
                    Order::whereDate(
                        'created_at',
                        today()
                    )->count(),

                // MONEY
                'total_revenue' =>
                    $totalRevenue,

                'today_revenue' =>
                    $todayRevenue,

                'total_wallet_payout' =>
                    $totalWalletPayout,

                // COURIER PERFORMANCE
                'avg_courier_rating' =>
                    round(
                        $avgCourierRating,
                        2
                    ),

                // WITHDRAWAL
                'pending_withdrawals' =>
                    Withdrawal::where(
                        'status',
                        'PENDING'
                    )->count(),

                'paid_withdrawals' =>
                    Withdrawal::where(
                        'status',
                        'PAID'
                    )->count(),
            ]
        ]);
    }

    public function recentOrders()
    {
        $orders =
            Order::with([
                'seller',
                'courier'
            ])
                ->latest('updated_at')
                ->take(10)
                ->get();

        return response()->json([

            'message' =>
                'Recent orders fetched successfully',

            'data' =>
                $orders
        ]);
    }

    public function recentWithdrawals()
    {
        $withdrawals =
            Withdrawal::with(
                'user'
            )
                ->latest()
                ->take(10)
                ->get();

        return response()->json([

            'message' =>
                'Recent withdrawals fetched successfully',

            'data' =>
                $withdrawals
        ]);
    }

    public function topCouriers()
    {
        $couriers =
            CourierProfile::with(
                'user'
            )
                ->get()
                ->map(function ($courier) {

                    $courier->completed_orders =
                        Order::where(
                            'courier_id',
                            $courier->user_id
                        )
                            ->where(
                                'status',
                                'COMPLETED'
                            )
                            ->count();

                    return $courier;
                })
                ->sortByDesc(
                    function ($courier) {

                        return
                            ($courier->totalWasteCollected() * 100)
                            + $courier->rating;
                    }
                )
                ->take(5)
                ->values();

        return response()->json([

            'message' =>
                'Top couriers fetched successfully',

            'data' =>
                $couriers
        ]);
    }

    public function topSellers()
    {
        $sellers =
            User::where(
                'role_id',
                3
            )
                ->withCount([
                    'sellerOrders as completed_orders' =>
                        function ($query) {
                            $query->where(
                                'status',
                                'COMPLETED'
                            );
                        }
                ])
                ->orderByDesc(
                    'completed_orders'
                )
                ->take(10)
                ->get();

        return response()->json([

            'message' =>
                'Top sellers fetched successfully',

            'data' =>
                $sellers
        ]);
    }
}