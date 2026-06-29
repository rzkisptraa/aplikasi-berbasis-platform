<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Carbon\Carbon;
use Illuminate\Http\Request;

class OrderWebController extends Controller
{
    public function index(Request $request)
    {
        $query = Order::with([
            'seller',
            'courier',
            'sellerAddress'
        ]);

        /* Search */

        if ($request->search) {

            $search = $request->search;

            $query->where(function ($q) use ($search) {

                $q->where(
                    'order_code',
                    'like',
                    "%{$search}%"
                )

                ->orWhereHas(
                    'seller',
                    function ($seller) use ($search) {

                        $seller->where(
                            'name',
                            'like',
                            "%{$search}%"
                        );
                    }
                )

                ->orWhereHas(
                    'courier',
                    function ($courier) use ($search) {

                        $courier->where(
                            'name',
                            'like',
                            "%{$search}%"
                        );
                    }
                );
            });
        }

        /* Filter Status */

        if (
            $request->status &&
            $request->status !== 'ALL'
        ) {
            $query->where(
                'status',
                $request->status
            );
        }

        /* Data Pesanan */

        $orders = $query
            ->latest()
            ->paginate(10)
            ->withQueryString();

        /* Statistik */

        $totalOrders =
            Order::count();

        $pendingOrders =
            Order::where(
                'status',
                'PENDING'
            )->count();

        $pickedUpOrders =
            Order::where(
                'status',
                'PICKED_UP'
            )->count();

        $deliveredOrders =
            Order::where(
                'status',
                'DELIVERED'
            )->count();

        $completedOrders =
            Order::where(
                'status',
                'COMPLETED'
            )->count();

        $cancelledOrders =
            Order::where(
                'status',
                'CANCELLED'
            )->count();

        $revenue =
            Order::where(
                'status',
                'COMPLETED'
            )->sum(
                'total_price'
            );

        /* Statistik Chart (7 Hari) */

        $chartLabels = [];
        $chartData = [];

        $hariIndonesia = [
            'Min',
            'Sen',
            'Sel',
            'Rab',
            'Kam',
            'Jum',
            'Sab',
        ];

        for ($i = 6; $i >= 0; $i--) {

            $date =
                Carbon::now()
                ->subDays($i);

            $chartLabels[] =
                $hariIndonesia[
                    $date->dayOfWeek
                ];

            $chartData[] =
                Order::whereDate(
                    'created_at',
                    $date
                )->count();
        }

        return view(
            'orders.index',
            [

                'orders' =>
                    $orders,

                'totalOrders' =>
                    $totalOrders,

                'pendingOrders' =>
                    $pendingOrders,

                'pickedUpOrders' =>
                    $pickedUpOrders,

                'deliveredOrders' =>
                    $deliveredOrders,

                'completedOrders' =>
                    $completedOrders,

                'cancelledOrders' =>
                    $cancelledOrders,

                'revenue' =>
                    $revenue,

                'chartLabels' =>
                    $chartLabels,

                'chartData' =>
                    $chartData,
            ]
        );
    }

    public function show($id)
    {
        $order = Order::with([
            'seller',
            'courier',
            'sellerAddress',
            'items.wasteCategory'
        ])->findOrFail($id);

        return view(
            'orders.show',
            compact('order')
        );
    }
}