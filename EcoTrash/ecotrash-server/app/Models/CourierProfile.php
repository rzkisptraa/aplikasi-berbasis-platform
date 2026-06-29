<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CourierProfile extends Model
{
    protected $fillable = [

        'user_id',

        /* Vehicle */

        'vehicle_type',
        'vehicle_plate',

        /* Identity */

        'ktp_number',
        'ktp_photo',

        'sim_number',
        'sim_photo',

        'face_photo',

        /*
        |--------------------------------------------------------------------------
        | Address
        |--------------------------------------------------------------------------
        */

        'address',
        'city',
        'province',

        /*
        |--------------------------------------------------------------------------
        | Metrics
        |--------------------------------------------------------------------------
        */

        'rating',
        'is_verified',

        /*
        |--------------------------------------------------------------------------
        | Realtime Location
        |--------------------------------------------------------------------------
        */

        'current_latitude',
        'current_longitude',
    ];

    protected $casts = [
        'is_verified' => 'boolean',

        'rating' => 'float',

        'current_latitude' => 'decimal:7',
        'current_longitude' => 'decimal:7',
    ];

    // Courier profile belongs to user
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    // Calculate total waste collected by this courier
    public function totalWasteCollected()
    {
        return $this->user?->courierOrders()
            ->whereIn('status', ['PICKED_UP', 'DELIVERED', 'COMPLETED'])
            ->sum('actual_total_weight') ?? 0;
    }
}