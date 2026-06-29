<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class WasteCategory extends Model
{
    use SoftDeletes;
    protected $fillable = [
        'name',
        'description',
        'price_per_kg',
        'is_active',
    ];

    protected $casts = [
        'price_per_kg' => 'decimal:2',
        'is_active' => 'boolean',
    ];

    // Category has many order items
    public function orderItems(): HasMany
    {
        return $this->hasMany(
            OrderItem::class
        );
    }
}