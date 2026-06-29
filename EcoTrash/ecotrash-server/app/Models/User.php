<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use App\Models\Wallet;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable;

    protected $fillable = [
        'role_id',
        'name',
        'email',
        'phone',
        'password',
        'profile_photo',
        'is_active',
        'is_online',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'is_active' => 'boolean',
            'is_online' => 'boolean',
        ];
    }

    protected static function booted()
    {
        static::created(function ($user) {

            // Auto create wallet for seller
            if (
                $user->role_id == 3
            ) {

                $user
                    ->wallet()
                    ->create([
                        'balance' => 0
                    ]);
            }
        });
    }

    /* RELATIONSHIPS */

    // User belongs to Role
    public function role(): BelongsTo
    {
        return $this->belongsTo(Role::class);
    }

    // Seller addresses
    public function sellerAddresses(): HasMany
    {
        return $this->hasMany(
            SellerAddress::class,
            'seller_id'
        );
    }

    // Courier profile
    public function courierProfile(): HasOne
    {
        return $this->hasOne(
            CourierProfile::class,
            'user_id'
        );
    }

    // Wallet
    public function wallet(): HasOne
    {
        return $this->hasOne(
            Wallet::class,
            'user_id'
        );
    }

    // Withdrawals
    public function withdrawals(): HasMany
    {
        return $this->hasMany(
            Withdrawal::class,
            'user_id'
        );
    }

    // Notifications
    public function notifications(): HasMany
    {
        return $this->hasMany(
            Notification::class,
            'user_id'
        );
    }

    // Orders created by seller
    public function sellerOrders(): HasMany
    {
        return $this->hasMany(Order::class, 'seller_id');
    }

    // Orders taken by courier
    public function courierOrders(): HasMany
    {
        return $this->hasMany(Order::class, 'courier_id');
    }

    // Reviews written
    public function reviewsGiven(): HasMany
    {
        return $this->hasMany(Review::class, 'seller_id');
    }

    // Reviews received
    public function reviewsReceived(): HasMany
    {
        return $this->hasMany(Review::class, 'courier_id');
    }
}