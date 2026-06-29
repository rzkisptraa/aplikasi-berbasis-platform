<?php

namespace Database\Seeders;

use App\Models\Role;
use Illuminate\Database\Seeder;

class RoleSeeder extends Seeder
{
    public function run(): void
    {
        $roles = [
            [
                'name' => 'SUPER_ADMIN',
                'slug' => 'super-admin'
            ],
            [
                'name' => 'ADMIN',
                'slug' => 'admin'
            ],
            [
                'name' => 'SELLER',
                'slug' => 'seller'
            ],
            [
                'name' => 'COURIER',
                'slug' => 'courier'
            ],
        ];

        foreach ($roles as $role) {
            Role::updateOrCreate(
                ['slug' => $role['slug']],
                $role
            );
        }
    }
}