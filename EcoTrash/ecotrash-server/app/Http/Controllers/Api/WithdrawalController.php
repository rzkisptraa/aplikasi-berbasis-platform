<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\WalletTransaction;
use App\Models\Withdrawal;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class WithdrawalController extends Controller
{
    /*REQUEST WITHDRAWAL*/
    public function store(Request $request)
    {
        $validated = $request->validate([
            'bank_name' => 'required|string|max:100',
            'account_name' => 'required|string|max:100',
            'account_number' => 'required|string|max:100',
            'amount' => 'required|numeric|min:1000',
        ]);

        $user = $request->user();

        $wallet = $user->wallet;

        if (!$wallet) {
            return response()->json([
                'message' => 'Wallet not found'
            ], 404);
        }

        if ($wallet->balance < $validated['amount']) {
            return response()->json([
                'message' => 'Insufficient balance'
            ], 422);
        }

        DB::beginTransaction();

        try {

            $withdrawal = Withdrawal::create([
                'user_id' => $user->id,
                'bank_name' =>
                    $validated['bank_name'],

                'account_name' =>
                    $validated['account_name'],

                'account_number' =>
                    $validated['account_number'],

                'amount' =>
                    $validated['amount'],

                'status' => 'APPROVED',
                'processed_at' => now(),
            ]);

            $wallet->decrement(
                'balance',
                $validated['amount']
            );

            WalletTransaction::create([
                'wallet_id' => $wallet->id,
                'type' => 'WITHDRAW',
                'amount' =>
                    $validated['amount'],

                'description' =>
                    'Withdrawal request approved',

                'status' => 'SUCCESS',
            ]);

            DB::commit();

            return response()->json([
                'message' =>
                    'Withdrawal request processed instantly',

                'data' => $withdrawal
            ], 201);

        } catch (\Exception $e) {

            DB::rollBack();

            return response()->json([
                'message' =>
                    'Failed to process withdrawal',

                'error' =>
                    $e->getMessage()
            ], 500);
        }
    }

    /*GET MY WITHDRAWALS*/
    public function index(Request $request)
    {
        return response()->json([
            'data' => $request->user()
                ->withdrawals()
                ->latest()
                ->get()
        ]);
    }

}