<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Review extends Model
{
    protected $fillable = [
        'seller_id',
        'courier_id',
        'order_id',
        'rating',
        'comment',
    ];

    protected $casts = [
        'rating' => 'integer',
    ];

    // Seller who gives review
    public function seller(): BelongsTo
    {
        return $this->belongsTo(
            User::class,
            'seller_id'
        );
    }

    // Courier reviewed
    public function courier(): BelongsTo
    {
        return $this->belongsTo(
            User::class,
            'courier_id'
        );
    }

    // Related order
    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }
}