<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        /*
        |--------------------------------------------------------------------------
        | SUPER ADMIN
        |--------------------------------------------------------------------------
        */

        User::updateOrCreate(
            ['email' => 'superadmin@ecotrash.com'],
            [
                'role_id' => 1,
                'name' => 'Super Admin',
                'phone' => '081111111111',
                'password' => Hash::make('password'),
                'is_active' => true,
                'is_online' => true,
                'profile_photo' => null,
            ]
        );

        /*
        |--------------------------------------------------------------------------
        | ADMIN
        |--------------------------------------------------------------------------
        */

        $admins = [
            [
                'name' => 'Admin 1',
                'email' => 'admin1@ecotrash.com',
                'phone' => '081222222221',
                'is_online' => true,
            ],
            [
                'name' => 'Admin 2',
                'email' => 'admin2@ecotrash.com',
                'phone' => '081222222222',
                'is_online' => false,
            ],
            [
                'name' => 'Admin 3',
                'email' => 'admin3@ecotrash.com',
                'phone' => '081222222223',
                'is_online' => false,
            ],
        ];

        foreach ($admins as $admin) {

            User::updateOrCreate(
                ['email' => $admin['email']],
                [
                    'role_id' => 2,
                    'name' => $admin['name'],
                    'phone' => $admin['phone'],
                    'password' => Hash::make('password'),
                    'is_active' => true,
                    'is_online' => $admin['is_online'],
                    'profile_photo' => null,
                ]
            );
        }

        /*
        |--------------------------------------------------------------------------
        | SELLER
        |--------------------------------------------------------------------------
        */

        for ($i = 1; $i <= 5; $i++) {

            User::updateOrCreate(
                ['email' => "seller{$i}@ecotrash.com"],
                [
                    'role_id' => 3,
                    'name' => "Seller {$i}",
                    'phone' => '08233333333' . $i,
                    'password' => Hash::make('password'),
                    'is_active' => true,
                    'is_online' => rand(0, 1),
                    'profile_photo' => null,
                ]
            );
        }

        /*
        |--------------------------------------------------------------------------
        | COURIER
        |--------------------------------------------------------------------------
        */

        $couriers = [
            [
                'name' => 'Courier 1',
                'online' => true,
                'active' => true,
            ],
            [
                'name' => 'Courier 2',
                'online' => false,
                'active' => false,
            ],
            [
                'name' => 'Courier 3',
                'online' => false,
                'active' => true,
            ],
            [
                'name' => 'Courier 4',
                'online' => false,
                'active' => true,
            ],
            [
                'name' => 'Courier 5',
                'online' => false,
                'active' => false,
            ],
        ];

        foreach ($couriers as $index => $courier) {

            $number = $index + 1;

            User::updateOrCreate(
                [
                    'email' => "courier{$number}@ecotrash.com"
                ],
                [
                    'role_id' => 4,
                    'name' => $courier['name'],
                    'phone' => '08444444444' . $number,
                    'password' => Hash::make('password'),
                    'is_active' => $courier['active'],
                    'is_online' => $courier['online'],
                    'profile_photo' => null,
                ]
            );
        }
    }
}