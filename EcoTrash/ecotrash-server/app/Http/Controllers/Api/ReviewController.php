<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Review;
use Illuminate\Http\Request;

class ReviewController extends Controller
{
    /*CREATE REVIEW*/
    public function store(
        Request $request
    ) {

        $user =
            $request->user();

        //ONLY SELLER
        if (
            $user->role_id != 3
        ) {

            return response()->json([
                'message' =>
                    'Only seller can review'
            ], 403);
        }

        $validated =
            $request->validate([

                'order_id' =>
                    'required|exists:orders,id',

                'rating' =>
                    'required|integer|min:1|max:5',

                'comment' =>
                    'nullable|string|max:1000',
            ]);

        //FIND ORDER
        $order =
            Order::where(
                'id',
                $validated[
                    'order_id'
                ]
            )
                ->where(
                    'seller_id',
                    $user->id
                )
                ->first();

        if (!$order) {

            return response()->json([
                'message' =>
                    'Order not found'
            ], 404);
        }

        //ORDER MUST COMPLETED
        if (
            $order->status
            !== 'COMPLETED'
        ) {

            return response()->json([
                'message' =>
                    'Order not completed'
            ], 422);
        }

        //PREVENT DUPLICATE
        $alreadyReviewed =
            Review::where(
                'order_id',
                $order->id
            )
                ->exists();

        if (
            $alreadyReviewed
        ) {

            return response()->json([
                'message' =>
                    'Review already exists'
            ], 422);
        }

        //CREATE REVIEW
        $review =
            Review::create([

                'seller_id' =>
                    $user->id,

                'courier_id' =>
                    $order->courier_id,

                'order_id' =>
                    $order->id,

                'rating' =>
                    $validated[
                        'rating'
                    ],

                'comment' =>
                    $validated[
                        'comment'
                    ] ?? null,
            ]);

        //UPDATE COURIER SCORE
        $courierProfile =
            $order
                ->courier
                    ?->courierProfile;

        if (
            $courierProfile
        ) {

            $avgRating =
                Review::where(
                    'courier_id',
                    $order->courier_id
                )
                    ->avg(
                        'rating'
                    );

            $courierProfile
                ->update([

                    'rating' =>
                        round(
                            $avgRating,
                            2
                        ),
                ]);
        }

        return response()->json([
            'message' =>
                'Review created successfully',

            'data' =>
                $review->load([
                    'seller',
                    'courier',
                    'order'
                ])
        ], 201);
    }

    /*COURIER REVIEWS*/
    public function myReceivedReviews(
        Request $request
    ) {

        $reviews =
            Review::with([
                'seller',
                'courier',
                'order'
            ])
                ->where(
                    'courier_id',
                    $request
                        ->user()
                        ->id
                )
                ->latest()
                ->get();

        return response()->json([

            'message' =>
                'Reviews fetched successfully',

            'data' =>
                $reviews
        ]);
    }
}