<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Order extends Model
{
    protected $fillable = [
        'order_code',
        'seller_id',
        'courier_id',
        'seller_address_id',

        'status',
        'vehicle_type',
        'pickup_photo',
        'pickup_notes',
        'cancel_reason',

        'latitude',
        'longitude',

        'estimated_total_weight',
        'actual_total_weight',

        'estimated_total_price',
        'total_price',

        'picked_up_at',
        'delivered_at',
        'completed_at',
        'cancelled_at',
    ];

    protected $casts = [
        'estimated_total_weight' => 'decimal:2',
        'actual_total_weight' => 'decimal:2',
        'total_price' => 'decimal:2',
        'latitude' => 'decimal:7',
        'longitude' => 'decimal:7',

        'picked_up_at' => 'datetime',
        'delivered_at' => 'datetime',
        'completed_at' => 'datetime',
        'cancelled_at' => 'datetime',
    ];

    // Seller who created order
    public function seller(): BelongsTo
    {
        return $this->belongsTo(User::class, 'seller_id');
    }

    // Courier who handles order
    public function courier(): BelongsTo
    {
        return $this->belongsTo(User::class, 'courier_id');
    }

    // Pickup location
    public function sellerAddress(): BelongsTo
    {
        return $this->belongsTo(
            SellerAddress::class,
            'seller_address_id'
        );
    }

    // Order items
    public function items(): HasMany
    {
        return $this->hasMany(OrderItem::class);
    }

    public function getPickupPhotoUrlAttribute()
    {
        if (! $this->pickup_photo) {
            return null;
        }

        $photoPath = str_starts_with(
            $this->pickup_photo,
            'pickups/'
        )
            ? str_replace(
                'pickups/',
                'pickup/',
                $this->pickup_photo
            )
            : $this->pickup_photo;

        return asset('storage/' . $photoPath);
    }

    protected $appends = [
        'pickup_photo_url'
    ];

    // Number of items in the order
    public function getItemsCountAttribute(): int
    {
        return $this->items()->count();
    }

    // Sum of actual weights from order items (null-safe)
    public function getItemsTotalActualWeightAttribute(): float
    {
        return (float) $this->items()->sum('actual_weight');
    }
}