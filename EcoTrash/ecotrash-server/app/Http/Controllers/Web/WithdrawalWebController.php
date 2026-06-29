<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Withdrawal;
use Illuminate\Http\Request;

class WithdrawalWebController extends Controller
{
    public function index(Request $request)
    {
        $query = Withdrawal::with('user');

        // Search
        if ($request->search) {

            $search = $request->search;

            $query->where(function ($q) use ($search) {

                $q->whereHas(
                    'user',
                    function ($userQuery) use ($search) {

                        $userQuery
                            ->where(
                                'name',
                                'like',
                                "%{$search}%"
                            )
                            ->orWhere(
                                'email',
                                'like',
                                "%{$search}%"
                            );
                    }
                )
                    ->orWhere(
                        'bank_name',
                        'like',
                        "%{$search}%"
                    );
            });
        }

        // Filter status
        if ($request->status) {

            $query->where(
                'status',
                $request->status
            );
        }

        $withdrawals =
            $query
                ->latest()
                ->paginate(10);

        return view(
            'withdrawals.index',
            [

                'withdrawals' =>
                    $withdrawals,

                'totalWithdrawals' =>
                    Withdrawal::count(),

                'pendingWithdrawals' =>
                    Withdrawal::where(
                        'status',
                        'PENDING'
                    )->count(),

                'approvedWithdrawals' =>
                    Withdrawal::where(
                        'status',
                        'APPROVED'
                    )->count(),

                'totalAmount' =>
                    Withdrawal::sum(
                        'amount'
                    ),
            ]
        );
    }

}