<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class WalletController extends Controller
{
    /*GET MY WALLET*/
    public function myWallet(
        Request $request
    ) {
        $wallet =
            $request->user()
                ->wallet()
                ->with([
                    'transactions' => function ($query) {
                        $query
                            ->latest()
                            ->take(5);
                    }
                ])
                ->first();

        $recentWithdrawals =
            $request->user()
                ->withdrawals()
                ->latest()
                ->take(5)
                ->get();

        return response()->json([

            'message' =>
                'Wallet fetched successfully',

            'data' => [

                'balance' =>
                    $wallet?->balance ?? 0,

                'recent_transactions' =>
                    $wallet?->transactions ?? [],

                'recent_withdrawals' =>
                    $recentWithdrawals,
            ]
        ]);
    }

    /*GET TRANSACTIONS ONLY*/
    public function transactions(Request $request)
    {
        $wallet = $request->user()->wallet;

        return response()->json([
            'message' =>
                'Transactions fetched successfully',

            'data' => $wallet
                ? $wallet->transactions()
                    ->latest()
                    ->get()
                : [],
        ]);
    }

    public function summary(
        Request $request
    ) {
        $wallet =
            $request->user()
                ->wallet()
                ->first();

        if (!$wallet) {

            return response()->json([
                'message' =>
                    'Wallet not found'
            ], 404);
        }

        $totalIncome =
            $wallet
                ->transactions()
                ->where(
                    'type',
                    'CREDIT'
                )
                ->sum(
                    'amount'
                );

        $totalWithdraw =
            $request->user()
                ->withdrawals()
                ->whereIn(
                    'status',
                    [
                        'APPROVED',
                        'PAID'
                    ]
                )
                ->sum(
                    'amount'
                );

        $pendingWithdraw =
            $request->user()
                ->withdrawals()
                ->where(
                    'status',
                    'PENDING'
                )
                ->sum(
                    'amount'
                );

        return response()->json([

            'message' =>
                'Wallet summary fetched successfully',

            'data' => [

                'total_income' =>
                    $totalIncome,

                'total_withdraw' =>
                    $totalWithdraw,

                'pending_withdraw' =>
                    $pendingWithdraw,
            ]
        ]);
    }
}