<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WalletTransaction extends Model
{
    protected $fillable = [
        'wallet_id',
        'type',
        'amount',
        'description',
        'status',
        'reference_order_id',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
    ];

    /* RELATIONSHIP */

    // Transaction belongs to wallet
    public function wallet(): BelongsTo
    {
        return $this->belongsTo(
            Wallet::class
        );
    }

    // Transaction belongs to order
    public function order(): BelongsTo
    {
        return $this->belongsTo(
            Order::class,
            'reference_order_id'
        );
    }
}