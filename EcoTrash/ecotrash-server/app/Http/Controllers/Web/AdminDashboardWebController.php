<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\CourierProfile;
use App\Models\Order;
use App\Models\User;
use App\Models\Withdrawal;
use Carbon\Carbon;

class AdminDashboardWebController extends Controller
{
    public function index()
    {
        $range =
            request()->get(
                'range',
                'all'
            );

        $startDate =
            match ($range) {

                'today' =>
                Carbon::today(),

                'week' =>
                Carbon::now()->startOfWeek(),

                'month' =>
                Carbon::now()->startOfMonth(),

                default =>
                null
            };

        /* Base Query */

        $ordersQuery =
            Order::query();

        $withdrawalsQuery =
            Withdrawal::query();

        if ($startDate) {
            $withdrawalsQuery
                ->whereDate(
                    'created_at',
                    '>=',
                    $startDate
                );
        }

        /* Filtered Subqueries */

        $totalOrdersQuery = clone $ordersQuery;
        $pendingQuery = clone $ordersQuery;
        $pickedUpQuery = clone $ordersQuery;
        $deliveredQuery = clone $ordersQuery;
        $completedQuery = clone $ordersQuery;
        $cancelledQuery = clone $ordersQuery;

        if ($startDate) {
            $totalOrdersQuery->whereDate('created_at', '>=', $startDate);
            $completedQuery->whereDate('completed_at', '>=', $startDate);
            $cancelledQuery->whereDate('cancelled_at', '>=', $startDate);
        }

        /* KPI */

        $totalRevenue =
            $completedQuery
                ->where(
                    'status',
                    'COMPLETED'
                )
                ->sum(
                    'total_price'
                );

        $totalOrders =
            $totalOrdersQuery
                ->count();

        /* Order Summary */

        $orderSummary = [

            'pending' =>
                $pendingQuery
                    ->where(
                        'status',
                        'PENDING'
                    )
                    ->count(),

            'picked_up' =>
                $pickedUpQuery
                    ->where(
                        'status',
                        'PICKED_UP'
                    )
                    ->count(),

            'delivered' =>
                $deliveredQuery
                    ->where(
                        'status',
                        'DELIVERED'
                    )
                    ->count(),

            'completed' =>
                $completedQuery
                    ->where(
                        'status',
                        'COMPLETED'
                    )
                    ->count(),

            'cancelled' =>
                $cancelledQuery
                    ->where(
                        'status',
                        'CANCELLED'
                    )
                    ->count(),
        ];

        /* Chart Data */

        $chartLabels = [];
        $chartData = [];

        if ($range === 'today') {

            for ($hour = 0; $hour < 24; $hour++) {

                $chartLabels[] =
                    str_pad(
                        $hour,
                        2,
                        '0',
                        STR_PAD_LEFT
                    ) . ':00';

                $count =
                    Order::whereDate(
                        'created_at',
                        Carbon::today()
                    )
                        ->whereRaw(
                            'EXTRACT(HOUR FROM created_at) = ?',
                            [$hour]
                        )
                        ->count();

                $chartData[] = $count;
            }
        } elseif ($range === 'week') {

            $hariIndonesia = [
                'Sen',
                'Sel',
                'Rab',
                'Kam',
                'Jum',
                'Sab',
                'Min'
            ];

            for ($i = 0; $i < 7; $i++) {

                $day =
                    Carbon::now()
                        ->startOfWeek()
                        ->copy()
                        ->addDays($i);

                $chartLabels[] =
                    $hariIndonesia[$i];

                $chartData[] =
                    Order::whereDate(
                        'created_at',
                        $day
                    )->count();
            }
        } elseif ($range === 'month') {

            for ($week = 1; $week <= 4; $week++) {

                $chartLabels[] =
                    'Minggu ' . $week;

                $start =
                    Carbon::now()
                        ->startOfMonth()
                        ->addWeeks(
                            $week - 1
                        );

                $end =
                    (clone $start)
                        ->copy()
                        ->endOfWeek();

                $chartData[] =
                    Order::whereBetween(
                        'created_at',
                        [
                            $start,
                            $end
                        ]
                    )->count();
            }
        } else {

            $bulanIndonesia = [
                1 => 'Jan',
                2 => 'Feb',
                3 => 'Mar',
                4 => 'Apr',
                5 => 'Mei',
                6 => 'Jun',
                7 => 'Jul',
                8 => 'Agu',
                9 => 'Sep',
                10 => 'Okt',
                11 => 'Nov',
                12 => 'Des',
            ];

            $chartLabels = [];
            $chartData = [];

            for ($i = 5; $i >= 0; $i--) {

                $date =
                    \Carbon\Carbon::create(
                        now()->year,
                        now()->month,
                        1
                    )->subMonths($i);

                $chartLabels[] =
                    $bulanIndonesia[
                        $date->month
                    ];

                $chartData[] =
                    Order::whereYear(
                        'created_at',
                        $date->year
                    )
                        ->whereMonth(
                            'created_at',
                            $date->month
                        )
                        ->count();
            }
        }

        /* Recent Data */

        $recentOrders =
            (clone $totalOrdersQuery)
                ->with([
                    'seller'
                ])
                ->latest()
                ->take(5)
                ->get();

        $recentWithdrawals =
            (clone $withdrawalsQuery)
                ->with([
                    'user'
                ])
                ->latest()
                ->take(5)
                ->get();

        /* Top Couriers */

        $topCouriers =
            CourierProfile::with([
                'user'
            ])
                ->orderByDesc(
                    'rating'
                )
                ->take(5)
                ->get();

        /* Top Sellers */
        $topSellers = User::whereHas('role', function ($query) {
                $query->where('slug', 'seller');
            })
            ->withCount(['sellerOrders as completed_orders_count' => function ($query) {
                $query->where('status', 'COMPLETED');
            }])
            ->orderByDesc('completed_orders_count')
            ->take(5)
            ->get();

        return view(
            'dashboard.index',
            [

                'range' =>
                    $range,

                'totalUsers' =>
                    User::count(),

                'totalOrders' =>
                    $totalOrders,

                'totalCouriers' => User::whereHas(
                    'role',
                    function ($query) {
                        $query->where('slug', 'courier');
                    }
                )->count(),

                'revenue' =>
                    $totalRevenue,

                'recentOrders' =>
                    $recentOrders,

                'recentWithdrawals' =>
                    $recentWithdrawals,

                'topCouriers' =>
                    $topCouriers,

                'topSellers' =>
                    $topSellers,

                'orderSummary' =>
                    $orderSummary,

                'chartLabels' =>
                    $chartLabels,

                'chartData' =>
                    $chartData,
            ]
        );
    }
}