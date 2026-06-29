<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class OrderItem extends Model
{
    protected $fillable = [
        'order_id',
        'waste_category_id',
        'estimated_weight',
        'actual_weight',
        'price_per_kg',
        'subtotal',
    ];

    protected $casts = [
        'estimated_weight' => 'decimal:2',
        'actual_weight' => 'decimal:2',
        'price_per_kg' => 'decimal:2',
        'subtotal' => 'decimal:2',
    ];

    // Item belongs to order
    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }

    // Waste category
    public function wasteCategory(): BelongsTo
    {
        return $this->belongsTo(
            WasteCategory::class
        );
    }
}