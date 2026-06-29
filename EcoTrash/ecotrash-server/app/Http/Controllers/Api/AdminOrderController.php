<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;

class AdminOrderController
    extends Controller
{
    public function index(
        Request $request
    ) {

        $query = Order::with([
            'seller',
            'courier',
            'sellerAddress',
            'items.wasteCategory'
        ]);

        // FILTER STATUS
        if (
            $request->filled(
                'status'
            )
        ) {

            $query->where(
                'status',
                $request->status
            );
        }

        // FILTER SELLER
        if (
            $request->filled(
                'seller_id'
            )
        ) {

            $query->where(
                'seller_id',
                $request->seller_id
            );
        }

        // FILTER COURIER
        if (
            $request->filled(
                'courier_id'
            )
        ) {

            $query->where(
                'courier_id',
                $request->courier_id
            );
        }

        // SEARCH ORDER CODE
        if (
            $request->filled(
                'search'
            )
        ) {

            $query->where(
                'order_code',
                'like',
                '%' .
                $request->search .
                '%'
            );
        }

        // FILTER DATE
        if (
            $request->filled(
                'date'
            )
        ) {

            $query->whereDate(
                'created_at',
                $request->date
            );
        }

        return response()->json([
            'data' =>
                $query
                ->latest()
                ->paginate(10)
        ]);
    }
}